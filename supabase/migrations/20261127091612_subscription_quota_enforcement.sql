-- AnoTara V2 follow-up: Subscription plans and quota enforcement.
-- Intended for the EXISTING V2 schema (after 20261123000000 and 20261123160000).
-- Historical migrations stay unchanged; apply this forward migration ONCE.
--
-- What this migration does
--   1. Enforces plan limits INSIDE the database, using triggers, for:
--        - active groups a user owns          (subscription_plans.max_groups)
--        - active members in one group        (subscription_plans.max_members_per_group)
--        - active (upcoming/ongoing) trips    (subscription_plans.max_active_trips)
--      AI generations were already enforced by anotara_request_itinerary_generation;
--      that function now shares the same plan/period helpers as the usage screen.
--   2. Records usage: a usage_events row for every group and trip created
--      (AI requests were already recorded).
--   3. Adds anotara_get_subscription_usage() for the Manage Subscription screen.
--
-- Why triggers? A trigger runs for EVERY insert/update on the table, whether it
-- comes from the Flutter app, a direct REST call, or another RPC. So the limits
-- cannot be bypassed by calling the backend directly.
--
-- Whose plan applies?
--   - Groups / active trips / AI: the plan of the user who creates them.
--   - Members per group: the plan of the group's owner (groups.created_by).
--   A NULL limit in subscription_plans means "unlimited".
--
-- Existing data is never deleted or changed. If a user is already above a limit
-- (for example after a paid plan expires), everything they have is kept; they
-- simply cannot ADD more until they are back under the limit or upgrade.
--
-- Errors raised for a reached limit use HINT 'quota_exceeded:<quota>' so the
-- app can recognise them (PostgrestException.hint in Flutter).

BEGIN;
SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '60s';

DO $guard$
BEGIN
  IF to_regprocedure('public.anotara_current_entitlements()') IS NULL
     OR to_regprocedure('public.anotara_request_itinerary_generation(uuid,jsonb)') IS NULL
     OR to_regprocedure('public.anotara_add_group_creator()') IS NULL THEN
    RAISE EXCEPTION 'STOP: this migration requires the AnoTara V2 schema';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.subscription_plans WHERE id = 'free') THEN
    RAISE EXCEPTION 'STOP: the free plan row is missing from subscription_plans';
  END IF;
  IF to_regprocedure('public.anotara_get_subscription_usage()') IS NOT NULL THEN
    RAISE EXCEPTION 'STOP: quota enforcement is already installed. Refusing to reapply.';
  END IF;
END;
$guard$;

-- ============================================================================
-- 1. PLAN LOOKUP HELPERS (internal, not callable by the app)
-- ============================================================================

-- Returns the plan limits for ANY user. Falls back to the Free plan when the
-- user has no active, unexpired subscription. Internal only, because triggers
-- need to look up the group OWNER's plan, not just the caller's.
CREATE OR REPLACE FUNCTION public.anotara_entitlements_for(p_user_id uuid)
RETURNS jsonb
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = ''
AS $fn$
DECLARE
  v_plan public.subscription_plans%ROWTYPE;
  v_plan_id text;
  v_period_start timestamptz;
  v_period_end timestamptz;
BEGIN
  IF p_user_id IS NULL THEN
    RAISE EXCEPTION 'A user is required to look up plan limits';
  END IF;

  SELECT p.id, s.current_period_start, s.current_period_end
    INTO v_plan_id, v_period_start, v_period_end
  FROM public.subscriptions s
  JOIN public.subscription_plans p ON p.id = s.plan_id
  WHERE s.user_id = p_user_id
    AND s.status IN ('active','trialing')
    AND p.is_active = true
    AND s.current_period_end > now()
    AND (s.current_period_start IS NULL OR s.current_period_start <= now())
  ORDER BY s.current_period_end DESC
  LIMIT 1;

  IF v_plan_id IS NULL THEN
    v_plan_id := 'free';
    v_period_start := NULL;
    v_period_end := NULL;
  END IF;

  SELECT * INTO v_plan FROM public.subscription_plans WHERE id = v_plan_id;
  IF v_plan.id IS NULL THEN
    RAISE EXCEPTION 'Free plan is missing';
  END IF;

  RETURN pg_catalog.jsonb_build_object(
    'plan_id', v_plan.id,
    'name', v_plan.name,
    'max_groups', v_plan.max_groups,
    'max_members_per_group', v_plan.max_members_per_group,
    'max_active_trips', v_plan.max_active_trips,
    'ai_generations_limit', v_plan.ai_generations_per_month,
    'features', v_plan.features,
    'period_start', v_period_start,
    'period_end', v_period_end
  );
END;
$fn$;

-- The existing client RPC keeps its name and output; it now reuses the helper.
CREATE OR REPLACE FUNCTION public.anotara_current_entitlements()
RETURNS jsonb
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = ''
AS $fn$
DECLARE
  v_uid uuid := (SELECT auth.uid());
BEGIN
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'Sign-in required' USING ERRCODE = '28000';
  END IF;
  RETURN public.anotara_entitlements_for(v_uid);
END;
$fn$;

-- The AI quota window. Trip Pass counts from its own 30-day subscription
-- period; Free and Plus count per calendar month (Asia/Manila time).
CREATE OR REPLACE FUNCTION public.anotara_ai_usage_window(p_entitlements jsonb)
RETURNS TABLE(window_start timestamptz, window_end timestamptz)
LANGUAGE plpgsql STABLE SET search_path = ''
AS $fn$
DECLARE
  v_month_start timestamp :=
    date_trunc('month', now() AT TIME ZONE 'Asia/Manila');
BEGIN
  IF p_entitlements->>'plan_id' = 'trip_pass' THEN
    window_start := (p_entitlements->>'period_start')::timestamptz;
    window_end := (p_entitlements->>'period_end')::timestamptz;
    IF window_start IS NULL THEN
      RAISE EXCEPTION 'Trip Pass period is not configured';
    END IF;
  ELSE
    window_start := v_month_start AT TIME ZONE 'Asia/Manila';
    window_end := (v_month_start + interval '1 month') AT TIME ZONE 'Asia/Manila';
  END IF;
  RETURN NEXT;
END;
$fn$;

REVOKE ALL ON FUNCTION public.anotara_entitlements_for(uuid)
  FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.anotara_ai_usage_window(jsonb)
  FROM PUBLIC, anon, authenticated;

-- ============================================================================
-- 2. LIMIT ENFORCEMENT (triggers)
-- ============================================================================

-- 2a. Active groups owned by a user.
CREATE OR REPLACE FUNCTION public.anotara_enforce_group_quota()
RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $fn$
DECLARE
  v_entitlements jsonb;
  v_limit integer;
  v_used integer;
BEGIN
  -- On UPDATE, only re-check when a group becomes active again or changes owner.
  IF TG_OP = 'UPDATE' THEN
    IF NEW.archived_at IS NOT NULL
       OR (OLD.archived_at IS NULL AND OLD.created_by = NEW.created_by) THEN
      RETURN NEW;
    END IF;
  END IF;

  -- One quota check at a time per user, so two fast requests cannot both
  -- squeeze into the last free slot.
  PERFORM pg_advisory_xact_lock(hashtextextended(NEW.created_by::text, 98));

  v_entitlements := public.anotara_entitlements_for(NEW.created_by);
  v_limit := (v_entitlements->>'max_groups')::integer;
  IF v_limit IS NULL THEN
    RETURN NEW; -- unlimited
  END IF;

  SELECT count(*) INTO v_used
  FROM public.groups g
  WHERE g.created_by = NEW.created_by
    AND g.archived_at IS NULL
    AND g.id <> NEW.id;

  IF v_used >= v_limit THEN
    RAISE EXCEPTION 'Your % plan allows % active group(s). Upgrade your plan to create more groups.',
      v_entitlements->>'name', v_limit
      USING ERRCODE = 'P0001', HINT = 'quota_exceeded:groups';
  END IF;
  RETURN NEW;
END;
$fn$;

DROP TRIGGER IF EXISTS anotara_quota_groups ON public.groups;
CREATE TRIGGER anotara_quota_groups
  BEFORE INSERT OR UPDATE OF archived_at, created_by ON public.groups
  FOR EACH ROW EXECUTE FUNCTION public.anotara_enforce_group_quota();

-- 2b. Active members in one group (limit comes from the group OWNER's plan).
-- Covers every way to join: the creator trigger, invite codes, invitations,
-- and a "left" member becoming active again.
CREATE OR REPLACE FUNCTION public.anotara_enforce_group_member_quota()
RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $fn$
DECLARE
  v_owner uuid;
  v_entitlements jsonb;
  v_limit integer;
  v_used integer;
BEGIN
  IF NEW.status <> 'active' THEN
    RETURN NEW; -- leaving or being removed never needs a quota check
  END IF;
  IF TG_OP = 'UPDATE' AND OLD.status = 'active' AND OLD.group_id = NEW.group_id THEN
    RETURN NEW; -- already counted (e.g. a role or timestamp change)
  END IF;

  -- Lock the group row so two people cannot join the last seat at once.
  SELECT g.created_by INTO v_owner
  FROM public.groups g
  WHERE g.id = NEW.group_id
  FOR UPDATE;
  IF v_owner IS NULL THEN
    RETURN NEW; -- the foreign key will reject an unknown group
  END IF;

  v_entitlements := public.anotara_entitlements_for(v_owner);
  v_limit := (v_entitlements->>'max_members_per_group')::integer;
  IF v_limit IS NULL THEN
    RETURN NEW; -- unlimited
  END IF;

  SELECT count(*) INTO v_used
  FROM public.group_members gm
  WHERE gm.group_id = NEW.group_id
    AND gm.status = 'active'
    AND gm.user_id <> NEW.user_id;

  IF v_used >= v_limit THEN
    RAISE EXCEPTION 'This group is full. The organizer''s % plan allows % members per group.',
      v_entitlements->>'name', v_limit
      USING ERRCODE = 'P0001', HINT = 'quota_exceeded:members_per_group';
  END IF;
  RETURN NEW;
END;
$fn$;

DROP TRIGGER IF EXISTS anotara_quota_group_members ON public.group_members;
CREATE TRIGGER anotara_quota_group_members
  BEFORE INSERT OR UPDATE OF status, group_id ON public.group_members
  FOR EACH ROW EXECUTE FUNCTION public.anotara_enforce_group_member_quota();

-- 2c. Active trips (status upcoming/ongoing) created by a user.
CREATE OR REPLACE FUNCTION public.anotara_enforce_active_trip_quota()
RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $fn$
DECLARE
  v_entitlements jsonb;
  v_limit integer;
  v_used integer;
BEGIN
  IF NEW.status NOT IN ('upcoming','ongoing') THEN
    RETURN NEW; -- completed/cancelled trips do not use a slot
  END IF;
  IF TG_OP = 'UPDATE'
     AND OLD.status IN ('upcoming','ongoing')
     AND OLD.created_by = NEW.created_by THEN
    RETURN NEW; -- e.g. upcoming -> ongoing, still the same slot
  END IF;

  PERFORM pg_advisory_xact_lock(hashtextextended(NEW.created_by::text, 98));

  v_entitlements := public.anotara_entitlements_for(NEW.created_by);
  v_limit := (v_entitlements->>'max_active_trips')::integer;
  IF v_limit IS NULL THEN
    RETURN NEW; -- unlimited
  END IF;

  SELECT count(*) INTO v_used
  FROM public.trips t
  WHERE t.created_by = NEW.created_by
    AND t.status IN ('upcoming','ongoing')
    AND t.id <> NEW.id;

  IF v_used >= v_limit THEN
    RAISE EXCEPTION 'Your % plan allows % active trip(s). Complete or cancel a trip, or upgrade your plan.',
      v_entitlements->>'name', v_limit
      USING ERRCODE = 'P0001', HINT = 'quota_exceeded:active_trips';
  END IF;
  RETURN NEW;
END;
$fn$;

DROP TRIGGER IF EXISTS anotara_quota_trips ON public.trips;
CREATE TRIGGER anotara_quota_trips
  BEFORE INSERT OR UPDATE OF status, created_by ON public.trips
  FOR EACH ROW EXECUTE FUNCTION public.anotara_enforce_active_trip_quota();

-- 2d. AI generations: same rules as before, now sharing the helpers above so
-- the usage screen and the enforcement always agree.
CREATE OR REPLACE FUNCTION public.anotara_request_itinerary_generation(
  p_trip_id uuid, p_input_data jsonb DEFAULT '{}'::jsonb
) RETURNS uuid
LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $fn$
DECLARE
  v_uid uuid := (SELECT auth.uid());
  v_entitlements jsonb;
  v_limit integer;
  v_count integer;
  v_window timestamptz;
  v_id uuid;
BEGIN
  IF v_uid IS NULL OR NOT public.anotara_p3_manage_trip(p_trip_id) THEN
    RAISE EXCEPTION 'Only an active organizer may request an AI itinerary for an open trip';
  END IF;
  IF p_input_data IS NULL OR pg_catalog.jsonb_typeof(p_input_data) <> 'object'
     OR length(p_input_data::text) > 16000 THEN
    RAISE EXCEPTION 'Invalid AI request';
  END IF;

  -- Serialize usage checks by user to avoid simultaneous quota overruns.
  PERFORM pg_advisory_xact_lock(hashtextextended(v_uid::text, 97));
  v_entitlements := public.anotara_entitlements_for(v_uid);
  v_limit := (v_entitlements->>'ai_generations_limit')::integer;
  IF v_limit IS NULL THEN
    RAISE EXCEPTION 'AI quota is not configured';
  END IF;
  SELECT w.window_start INTO v_window
  FROM public.anotara_ai_usage_window(v_entitlements) w;

  SELECT count(*) INTO v_count
  FROM public.usage_events ue
  WHERE ue.user_id = v_uid
    AND ue.event_type = 'ai_itinerary_generation'
    AND ue.created_at >= v_window;
  IF v_count >= v_limit THEN
    RAISE EXCEPTION 'AI generation limit reached for this plan period'
      USING ERRCODE = 'P0001', HINT = 'quota_exceeded:ai_generations';
  END IF;

  INSERT INTO public.itinerary_generations(trip_id, requested_by, status, input_data)
  VALUES (p_trip_id, v_uid, 'draft', p_input_data)
  RETURNING id INTO v_id;
  INSERT INTO public.usage_events(user_id, trip_id, event_type, metadata)
  VALUES (v_uid, p_trip_id, 'ai_itinerary_generation',
          pg_catalog.jsonb_build_object('request_id', v_id, 'state', 'queued'));
  RETURN v_id;
END;
$fn$;

REVOKE ALL ON FUNCTION
  public.anotara_enforce_group_quota(),
  public.anotara_enforce_group_member_quota(),
  public.anotara_enforce_active_trip_quota()
FROM PUBLIC, anon, authenticated;

-- ============================================================================
-- 3. RECORD USAGE
-- ============================================================================
-- usage_events is the audit log of what each user has created. Limits for
-- groups/trips/members are counted from the live tables (so a completed trip
-- frees its slot); the AI quota is counted from usage_events.
CREATE OR REPLACE FUNCTION public.anotara_record_usage_event()
RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $fn$
BEGIN
  IF TG_TABLE_NAME = 'groups' THEN
    INSERT INTO public.usage_events(user_id, event_type, metadata)
    VALUES (NEW.created_by, 'group_created',
            pg_catalog.jsonb_build_object('group_id', NEW.id));
  ELSIF TG_TABLE_NAME = 'trips' THEN
    INSERT INTO public.usage_events(user_id, trip_id, event_type, metadata)
    VALUES (NEW.created_by, NEW.id, 'trip_created',
            pg_catalog.jsonb_build_object('group_id', NEW.group_id));
  END IF;
  RETURN NULL;
END;
$fn$;
REVOKE ALL ON FUNCTION public.anotara_record_usage_event()
  FROM PUBLIC, anon, authenticated;

DROP TRIGGER IF EXISTS anotara_usage_group_created ON public.groups;
CREATE TRIGGER anotara_usage_group_created
  AFTER INSERT ON public.groups
  FOR EACH ROW EXECUTE FUNCTION public.anotara_record_usage_event();

DROP TRIGGER IF EXISTS anotara_usage_trip_created ON public.trips;
CREATE TRIGGER anotara_usage_trip_created
  AFTER INSERT ON public.trips
  FOR EACH ROW EXECUTE FUNCTION public.anotara_record_usage_event();

-- Usage rows are written only by trusted database code. Table INSERT is
-- already revoked; also drop the legacy V1 policy so it can never be reused.
DROP POLICY IF EXISTS usage_events_insert_own ON public.usage_events;
REVOKE INSERT, UPDATE, DELETE ON public.usage_events
  FROM PUBLIC, anon, authenticated;

-- Speeds up the "how many active trips do I have" count.
CREATE INDEX IF NOT EXISTS anotara_trips_creator_status_idx
  ON public.trips (created_by, status);

-- ============================================================================
-- 4. USAGE SUMMARY FOR THE MANAGE SUBSCRIPTION SCREEN
-- ============================================================================
-- Returns, for the signed-in user:
-- {
--   "plan_id": "free", "plan_name": "Free", "period_start": null, "period_end": null,
--   "groups":          { "used": 1, "limit": 1 },
--   "active_trips":    { "used": 0, "limit": 1 },
--   "ai_generations":  { "used": 2, "limit": 3, "period_start": "...", "resets_at": "..." },
--   "members_per_group": { "limit": 8,
--       "groups": [ { "group_id": "...", "group_name": "...", "used": 5 } ] }
-- }
-- "limit": null means unlimited. members_per_group lists the groups the user owns.
CREATE OR REPLACE FUNCTION public.anotara_get_subscription_usage()
RETURNS jsonb
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = ''
AS $fn$
DECLARE
  v_uid uuid := (SELECT auth.uid());
  v_entitlements jsonb;
  v_window_start timestamptz;
  v_window_end timestamptz;
  v_groups_used integer;
  v_trips_used integer;
  v_ai_used integer;
  v_member_groups jsonb;
BEGIN
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'Sign-in required' USING ERRCODE = '28000';
  END IF;

  v_entitlements := public.anotara_entitlements_for(v_uid);
  SELECT w.window_start, w.window_end INTO v_window_start, v_window_end
  FROM public.anotara_ai_usage_window(v_entitlements) w;

  SELECT count(*) INTO v_groups_used
  FROM public.groups g
  WHERE g.created_by = v_uid AND g.archived_at IS NULL;

  SELECT count(*) INTO v_trips_used
  FROM public.trips t
  WHERE t.created_by = v_uid AND t.status IN ('upcoming','ongoing');

  SELECT count(*) INTO v_ai_used
  FROM public.usage_events ue
  WHERE ue.user_id = v_uid
    AND ue.event_type = 'ai_itinerary_generation'
    AND ue.created_at >= v_window_start;

  SELECT coalesce(
           pg_catalog.jsonb_agg(
             pg_catalog.jsonb_build_object(
               'group_id', g.id,
               'group_name', g.name,
               'used', (SELECT count(*) FROM public.group_members gm
                        WHERE gm.group_id = g.id AND gm.status = 'active'))
             ORDER BY g.created_at),
           '[]'::jsonb)
    INTO v_member_groups
  FROM public.groups g
  WHERE g.created_by = v_uid AND g.archived_at IS NULL;

  RETURN pg_catalog.jsonb_build_object(
    'plan_id', v_entitlements->>'plan_id',
    'plan_name', v_entitlements->>'name',
    'period_start', v_entitlements->'period_start',
    'period_end', v_entitlements->'period_end',
    'groups', pg_catalog.jsonb_build_object(
      'used', v_groups_used,
      'limit', v_entitlements->'max_groups'),
    'active_trips', pg_catalog.jsonb_build_object(
      'used', v_trips_used,
      'limit', v_entitlements->'max_active_trips'),
    'ai_generations', pg_catalog.jsonb_build_object(
      'used', v_ai_used,
      'limit', v_entitlements->'ai_generations_limit',
      'period_start', v_window_start,
      'resets_at', v_window_end),
    'members_per_group', pg_catalog.jsonb_build_object(
      'limit', v_entitlements->'max_members_per_group',
      'groups', v_member_groups)
  );
END;
$fn$;
REVOKE ALL ON FUNCTION public.anotara_get_subscription_usage()
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.anotara_get_subscription_usage()
  TO authenticated;

-- ============================================================================
-- 5. POSTCONDITIONS
-- ============================================================================
DO $verify$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'anotara_quota_groups'
                   AND tgrelid = 'public.groups'::regclass)
     OR NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'anotara_quota_group_members'
                   AND tgrelid = 'public.group_members'::regclass)
     OR NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'anotara_quota_trips'
                   AND tgrelid = 'public.trips'::regclass)
     OR to_regprocedure('public.anotara_get_subscription_usage()') IS NULL THEN
    RAISE EXCEPTION 'STOP: quota enforcement objects are missing';
  END IF;
  IF has_function_privilege('authenticated',
       'public.anotara_entitlements_for(uuid)', 'EXECUTE') THEN
    RAISE EXCEPTION 'STOP: internal entitlement lookup must not be client-callable';
  END IF;
  IF has_table_privilege('authenticated', 'public.usage_events', 'INSERT') THEN
    RAISE EXCEPTION 'STOP: clients must not be able to write usage_events';
  END IF;
END;
$verify$;

COMMIT;
NOTIFY pgrst, 'reload schema';
