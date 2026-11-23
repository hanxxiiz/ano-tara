-- ANOTARA V2: SINGLE-TRANSACTION DEPLOYMENT CANDIDATE (2026-11-23)
-- -----------------------------------------------------------------------------
-- FOR EXISTING ANOTARA *PRODUCTION* SUPABASE PROJECT ONLY, after verifying a
-- current full recovery plan and running the accompanying production preflight.
-- DO NOT apply if preflight returns STOP, if any feature rows have appeared,
-- or if any Phase 1-3 migrations have already been applied to production.
-- The original parts were exercised separately on local staging; the
-- consolidated single-transaction version was executed in the Supabase SQL Editor.
-- Existing production Auth, profiles, member_preferences and plans are retained.
-- The original auth signup trigger is expected and is NOT replaced here.
-- A transaction will ROLLBACK on a server SQL error, except that the client must
-- NOT invoke subsequent statements after an error. Do NOT paste partial chunks.
-- External AI workers, payment provider, push delivery and other app components
-- are NOT implemented by database functions alone.
-- -----------------------------------------------------------------------------

BEGIN;
SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '120s';

-- Fail closed if another deployment already installed any AnoTara V2 objects.
DO $deployment_guard$
DECLARE v_old_tables integer;
BEGIN
 SELECT count(*) INTO v_old_tables FROM pg_catalog.pg_tables
 WHERE schemaname='public' AND tablename IN
 ('member_availability','group_invite_codes','group_messages',
  'trip_location_permissions','anotara_code_redeem_attempts');
 IF v_old_tables<>0 OR to_regprocedure('public.anotara_redeem_group_code(text)') IS NOT NULL
    OR to_regprocedure('public.anotara_change_trip_status(uuid,text,text)') IS NOT NULL
 THEN
   RAISE EXCEPTION 'STOP: production already includes V2 objects or RPCs. Refusing to reapply.';
 END IF;
 IF (SELECT count(*) FROM pg_catalog.pg_tables WHERE schemaname='public')<>18 THEN
   RAISE EXCEPTION 'STOP: production public table inventory changed from the verified 18-table baseline.';
 END IF;
END;
$deployment_guard$;

-- ============================================================================
-- SOURCE 1: V2 FOUNDATION
-- Original reviewed file: anotara_v2_inventory_based_foundation_STAGING_ONLY.sql
-- ============================================================================
SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '90s';

-- Guard against any feature data added since the user's preflight results.
-- If there is any new data, pause and adapt migration rather than erasing it.
DO $baseline$
DECLARE
  feature_rows bigint;
  plan_count bigint;
BEGIN
  SELECT
    (SELECT count(*) FROM public.groups) +
    (SELECT count(*) FROM public.group_members) +
    (SELECT count(*) FROM public.group_invitations) +
    (SELECT count(*) FROM public.trips) +
    (SELECT count(*) FROM public.trip_members) +
    (SELECT count(*) FROM public.expenses) +
    (SELECT count(*) FROM public.expense_shares) +
    (SELECT count(*) FROM public.settlements) +
    (SELECT count(*) FROM public.location_shares) +
    (SELECT count(*) FROM public.meeting_points) +
    (SELECT count(*) FROM public.itinerary_generations) +
    (SELECT count(*) FROM public.itinerary_items) +
    (SELECT count(*) FROM public.notifications) +
    (SELECT count(*) FROM public.subscriptions) +
    (SELECT count(*) FROM public.usage_events)
  INTO feature_rows;
  SELECT count(*) INTO plan_count FROM public.subscription_plans;
  IF feature_rows <> 0 OR plan_count <> 3 THEN
    RAISE EXCEPTION 'Preflight changed: feature rows %, subscription plan count %. Stop for manual review.', feature_rows, plan_count;
  END IF;
  IF to_regprocedure('public.handle_new_user()') IS NULL THEN
    RAISE EXCEPTION 'Expected existing auth trigger function is missing';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname='on_auth_user_created'
      AND tgrelid='auth.users'::regclass AND NOT tgisinternal
  ) THEN
    RAISE EXCEPTION 'Existing auth signup trigger not found; aborting to protect signups';
  END IF;
END;
$baseline$;

-- Fail on incompatible or ambiguous data, rather than silently relabeling users.
DO $check$
BEGIN
  IF EXISTS (SELECT 1 FROM public.trips WHERE status = 'archived') THEN
    RAISE EXCEPTION 'Legacy archived trips exist; determine whether they are completed or something else before migrating';
  END IF;
  IF EXISTS (SELECT 1 FROM public.trip_members WHERE response = 'maybe') THEN
    RAISE EXCEPTION 'Legacy MAYBE trip responses exist; resolve them individually before migrating';
  END IF;
  IF EXISTS (SELECT 1 FROM public.expenses WHERE length(btrim(currency::text)) <> 3)
     OR EXISTS (SELECT 1 FROM public.settlements WHERE length(btrim(currency::text)) <> 3) THEN
    RAISE EXCEPTION 'A currency value is not 3 letters; inspect existing currency data before converting it to char(3)';
  END IF;
END;
$check$;

-- 1. Current trip lifecycle labels, not the old draft/planned/active/archived set.
ALTER TABLE public.trips DROP CONSTRAINT IF EXISTS trips_status_check;
UPDATE public.trips SET status = CASE status
  WHEN 'draft' THEN 'upcoming'
  WHEN 'planned' THEN 'upcoming'
  WHEN 'active' THEN 'ongoing'
  ELSE status END
WHERE status IN ('draft','planned','active');
ALTER TABLE public.trips ALTER COLUMN status SET DEFAULT 'upcoming';
ALTER TABLE public.trips ADD CONSTRAINT trips_status_check
  CHECK (status IN ('upcoming','ongoing','completed','cancelled'));
ALTER TABLE public.trips ADD COLUMN IF NOT EXISTS timezone_name text NOT NULL DEFAULT 'Asia/Manila';
ALTER TABLE public.trips ADD COLUMN IF NOT EXISTS cancelled_at timestamptz;
ALTER TABLE public.trips ADD COLUMN IF NOT EXISTS cancelled_by uuid REFERENCES auth.users(id) ON DELETE SET NULL;
ALTER TABLE public.trips ADD COLUMN IF NOT EXISTS cancellation_reason text;
ALTER TABLE public.trips ADD COLUMN IF NOT EXISTS completed_at timestamptz;
COMMENT ON COLUMN public.trips.status IS 'Upcoming / ongoing / completed / cancelled. Production should schedule or atomically calculate state transitions.';

-- 2. Trip RSVP is a response, not membership. Not Going remains a member.
ALTER TABLE public.trip_members DROP CONSTRAINT IF EXISTS trip_members_response_check;
ALTER TABLE public.trip_members ADD CONSTRAINT trip_members_response_check
  CHECK (response IN ('pending','going','not_going'));
ALTER TABLE public.trip_members ADD COLUMN IF NOT EXISTS membership_status text NOT NULL DEFAULT 'active';
ALTER TABLE public.trip_members ADD COLUMN IF NOT EXISTS left_at timestamptz;
ALTER TABLE public.trip_members ADD COLUMN IF NOT EXISTS removed_at timestamptz;
ALTER TABLE public.trip_members DROP CONSTRAINT IF EXISTS trip_members_membership_status_check;
ALTER TABLE public.trip_members ADD CONSTRAINT trip_members_membership_status_check
  CHECK (membership_status IN ('active','left','removed'));
ALTER TABLE public.group_members DROP CONSTRAINT IF EXISTS group_members_status_check;
ALTER TABLE public.group_members ADD CONSTRAINT group_members_status_check
  CHECK (status IN ('active','left','removed'));

-- The current Add Expense screens expose only Equal and Custom splits.
ALTER TABLE public.expenses DROP CONSTRAINT IF EXISTS expenses_split_method_check;
ALTER TABLE public.expenses ADD CONSTRAINT expenses_split_method_check
  CHECK (split_method IN ('equal','custom'));

-- 3. Actual attached schema says `currency character`, not char(3).
-- Perform the correction without guessing what historical one-letter values mean.
ALTER TABLE public.expenses ALTER COLUMN currency DROP DEFAULT;
ALTER TABLE public.expenses ALTER COLUMN currency TYPE char(3) USING currency::text::char(3);
ALTER TABLE public.expenses ALTER COLUMN currency SET DEFAULT 'PHP';
ALTER TABLE public.settlements ALTER COLUMN currency DROP DEFAULT;
ALTER TABLE public.settlements ALTER COLUMN currency TYPE char(3) USING currency::text::char(3);
ALTER TABLE public.settlements ALTER COLUMN currency SET DEFAULT 'PHP';

-- 4. Date-specific availability. A member can tap MANY dates, one row per date.
-- DO NOT DROP member_preferences.usual_free_days: already used by Flutter.
-- That field remains legacy recurring weekdays; the group calendar uses this new table.
CREATE TABLE IF NOT EXISTS public.member_availability (
  group_id uuid NOT NULL REFERENCES public.groups(id),
  user_id uuid NOT NULL REFERENCES auth.users(id),
  available_on date NOT NULL,
  status text NOT NULL CHECK (status IN ('available','busy','not_available','maybe')),
  updated_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (group_id,user_id,available_on),
  CONSTRAINT member_availability_group_member_fk
    FOREIGN KEY (group_id,user_id) REFERENCES public.group_members(group_id,user_id)
);
CREATE INDEX IF NOT EXISTS member_availability_group_date_idx
  ON public.member_availability (group_id,available_on,status);
ALTER TABLE public.member_availability ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS anotara_availability_select ON public.member_availability;
CREATE POLICY anotara_availability_select ON public.member_availability
FOR SELECT TO authenticated USING (
  public.is_group_member(group_id)
  AND EXISTS (
    SELECT 1 FROM public.group_members owner_gm
    WHERE owner_gm.group_id=member_availability.group_id
      AND owner_gm.user_id=member_availability.user_id
      AND owner_gm.status='active'
  )
);
DROP POLICY IF EXISTS anotara_availability_insert ON public.member_availability;
CREATE POLICY anotara_availability_insert ON public.member_availability
FOR INSERT TO authenticated WITH CHECK (
  user_id=(SELECT auth.uid()) AND public.is_group_member(group_id)
);
DROP POLICY IF EXISTS anotara_availability_update ON public.member_availability;
CREATE POLICY anotara_availability_update ON public.member_availability
FOR UPDATE TO authenticated
USING (user_id=(SELECT auth.uid()) AND public.is_group_member(group_id))
WITH CHECK (user_id=(SELECT auth.uid()) AND public.is_group_member(group_id));
DROP POLICY IF EXISTS anotara_availability_delete ON public.member_availability;
CREATE POLICY anotara_availability_delete ON public.member_availability
FOR DELETE TO authenticated USING (user_id=(SELECT auth.uid()) AND public.is_group_member(group_id));
REVOKE ALL ON public.member_availability FROM PUBLIC, anon, authenticated;
GRANT SELECT,INSERT,UPDATE,DELETE ON public.member_availability TO authenticated;

-- 5. One current code per group. Group code is distinct from addressed invitations.
-- 12 hex characters (48 random bits) rather than the five-character mockup.
-- A rate-limited server endpoint is needed before enabling internet-facing redemption.
CREATE TABLE IF NOT EXISTS public.group_invite_codes (
  group_id uuid PRIMARY KEY REFERENCES public.groups(id),
  code text NOT NULL UNIQUE CHECK (code ~ '^[A-F0-9]{12}$'),
  created_by uuid REFERENCES auth.users(id),
  created_at timestamptz NOT NULL DEFAULT now(),
  expires_at timestamptz,
  CHECK (expires_at IS NULL OR expires_at > created_at)
);
ALTER TABLE public.group_invite_codes ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS anotara_group_codes_organizer_read ON public.group_invite_codes;
CREATE POLICY anotara_group_codes_organizer_read ON public.group_invite_codes
FOR SELECT TO authenticated USING (public.is_group_admin(group_id));
REVOKE ALL ON public.group_invite_codes FROM PUBLIC,anon,authenticated;
GRANT SELECT ON public.group_invite_codes TO authenticated;

-- 6. Persistent chat, scoped to active members of the same group.
CREATE TABLE IF NOT EXISTS public.group_messages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  group_id uuid NOT NULL REFERENCES public.groups(id),
  sender_id uuid NOT NULL REFERENCES auth.users(id),
  message_text text NOT NULL CHECK (length(btrim(message_text)) BETWEEN 1 AND 5000),
  created_at timestamptz NOT NULL DEFAULT now(),
  edited_at timestamptz
);
CREATE INDEX IF NOT EXISTS anotara_group_messages_group_recent
  ON public.group_messages (group_id,created_at DESC);
ALTER TABLE public.group_messages ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS anotara_group_messages_read ON public.group_messages;
CREATE POLICY anotara_group_messages_read ON public.group_messages
FOR SELECT TO authenticated USING (public.is_group_member(group_id));
DROP POLICY IF EXISTS anotara_group_messages_send ON public.group_messages;
CREATE POLICY anotara_group_messages_send ON public.group_messages
FOR INSERT TO authenticated WITH CHECK (
  sender_id=(SELECT auth.uid()) AND public.is_group_member(group_id)
);
REVOKE ALL ON public.group_messages FROM PUBLIC,anon,authenticated;
GRANT SELECT,INSERT ON public.group_messages TO authenticated;

-- 7. Separate live-location opt-in, distinct from RSVP.
CREATE TABLE IF NOT EXISTS public.trip_location_permissions (
  trip_id uuid NOT NULL,
  user_id uuid NOT NULL,
  enabled boolean NOT NULL DEFAULT false,
  updated_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY(trip_id,user_id),
  FOREIGN KEY(trip_id,user_id) REFERENCES public.trip_members(trip_id,user_id)
);
ALTER TABLE public.trip_location_permissions ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS anotara_loc_consent_read ON public.trip_location_permissions;
CREATE POLICY anotara_loc_consent_read ON public.trip_location_permissions
FOR SELECT TO authenticated USING (user_id=(SELECT auth.uid()));
-- No direct write grants yet: location consent and location_shares RLS
-- must be deployed together so Not Going never gets access to live locations.
REVOKE ALL ON public.trip_location_permissions FROM PUBLIC,anon,authenticated;
GRANT SELECT ON public.trip_location_permissions TO authenticated;

-- 8. Preserve expense ownership and settled financial records across departures.
-- References to auth.users are independent of group_members/trip_members rows.
-- A deletion of a group or trip containing expenses is blocked until a
-- deliberate archive/export/retention workflow has been implemented.
CREATE OR REPLACE FUNCTION public.anotara_prevent_financial_history_delete()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $body$
BEGIN
  IF TG_TABLE_NAME = 'trips' AND EXISTS (
    SELECT 1 FROM public.expenses e WHERE e.trip_id=OLD.id
  ) THEN
    RAISE EXCEPTION 'Cannot delete trip with expense history; retain or export financial records first';
  END IF;
  IF TG_TABLE_NAME = 'groups' AND EXISTS (
    SELECT 1 FROM public.trips t JOIN public.expenses e ON e.trip_id=t.id
    WHERE t.group_id=OLD.id
  ) THEN
    RAISE EXCEPTION 'Cannot delete group with expense history; retain or export financial records first';
  END IF;
  RETURN OLD;
END;
$body$;
DROP TRIGGER IF EXISTS anotara_keep_trip_financial_history ON public.trips;
CREATE TRIGGER anotara_keep_trip_financial_history
BEFORE DELETE ON public.trips FOR EACH ROW
EXECUTE FUNCTION public.anotara_prevent_financial_history_delete();
DROP TRIGGER IF EXISTS anotara_keep_group_financial_history ON public.groups;
CREATE TRIGGER anotara_keep_group_financial_history
BEFORE DELETE ON public.groups FOR EACH ROW
EXECUTE FUNCTION public.anotara_prevent_financial_history_delete();
REVOKE ALL ON FUNCTION public.anotara_prevent_financial_history_delete() FROM PUBLIC,anon,authenticated;

-- 9. Correct helper semantics: Not Going = active trip member.
-- Previously is_trip_member excluded 'not_going', incorrectly hiding expenses.
-- IMPORTANT: Existing live-location policies referencing is_trip_member must
-- be rewritten BEFORE letting clients use live location (separate Phase 2).
CREATE OR REPLACE FUNCTION public.is_trip_member(target_trip_id uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = '' AS $body$
  SELECT EXISTS (
    SELECT 1
    FROM public.trip_members tm
    JOIN public.trips t ON t.id=tm.trip_id
    JOIN public.group_members gm
      ON gm.group_id=t.group_id AND gm.user_id=tm.user_id
    WHERE tm.trip_id=target_trip_id
      AND tm.user_id=(SELECT auth.uid())
      AND tm.membership_status='active' AND gm.status='active'
  );
$body$;
REVOKE ALL ON FUNCTION public.is_trip_member(uuid) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.is_trip_member(uuid) TO authenticated;

-- 10. Do NOT open up existing permissions: safely deny legacy live location
-- reads until consent-aware policies are reviewed and applied in Phase 2.
-- Existing location policies may vary; this RESTRICTIVE policy applies even
-- when other PERMISSIVE select policies exist.
ALTER TABLE public.location_shares ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS anotara_location_phase1_private ON public.location_shares;
CREATE POLICY anotara_location_phase1_private ON public.location_shares
AS RESTRICTIVE FOR SELECT TO authenticated USING (false);
-- Also prevent new writes until phase 2 is implemented. No live-location
-- frontend exists yet according to the supplied development status.
REVOKE INSERT,UPDATE,DELETE ON public.location_shares FROM authenticated;

-- 11. Timestamp maintenance for changed feature rows.
-- Do not alter the existing auth/profile/preference triggers or functions.
CREATE OR REPLACE FUNCTION public.anotara_touch_updated_at()
RETURNS trigger LANGUAGE plpgsql SET search_path = '' AS $fn$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END;
$fn$;
REVOKE ALL ON FUNCTION public.anotara_touch_updated_at()
  FROM PUBLIC, anon, authenticated;

DROP TRIGGER IF EXISTS anotara_groups_touch ON public.groups;
CREATE TRIGGER anotara_groups_touch BEFORE UPDATE ON public.groups
  FOR EACH ROW EXECUTE FUNCTION public.anotara_touch_updated_at();
DROP TRIGGER IF EXISTS anotara_group_members_touch ON public.group_members;
CREATE TRIGGER anotara_group_members_touch BEFORE UPDATE ON public.group_members
  FOR EACH ROW EXECUTE FUNCTION public.anotara_touch_updated_at();
DROP TRIGGER IF EXISTS anotara_trips_touch ON public.trips;
CREATE TRIGGER anotara_trips_touch BEFORE UPDATE ON public.trips
  FOR EACH ROW EXECUTE FUNCTION public.anotara_touch_updated_at();
DROP TRIGGER IF EXISTS anotara_trip_members_touch ON public.trip_members;
CREATE TRIGGER anotara_trip_members_touch BEFORE UPDATE ON public.trip_members
  FOR EACH ROW EXECUTE FUNCTION public.anotara_touch_updated_at();
DROP TRIGGER IF EXISTS anotara_expenses_touch ON public.expenses;
CREATE TRIGGER anotara_expenses_touch BEFORE UPDATE ON public.expenses
  FOR EACH ROW EXECUTE FUNCTION public.anotara_touch_updated_at();
DROP TRIGGER IF EXISTS anotara_expense_shares_touch ON public.expense_shares;
CREATE TRIGGER anotara_expense_shares_touch BEFORE UPDATE ON public.expense_shares
  FOR EACH ROW EXECUTE FUNCTION public.anotara_touch_updated_at();
DROP TRIGGER IF EXISTS anotara_settlements_touch ON public.settlements;
CREATE TRIGGER anotara_settlements_touch BEFORE UPDATE ON public.settlements
  FOR EACH ROW EXECUTE FUNCTION public.anotara_touch_updated_at();
DROP TRIGGER IF EXISTS anotara_member_availability_touch ON public.member_availability;
CREATE TRIGGER anotara_member_availability_touch BEFORE UPDATE ON public.member_availability
  FOR EACH ROW EXECUTE FUNCTION public.anotara_touch_updated_at();
DROP TRIGGER IF EXISTS anotara_location_permissions_touch ON public.trip_location_permissions;
CREATE TRIGGER anotara_location_permissions_touch BEFORE UPDATE ON public.trip_location_permissions
  FOR EACH ROW EXECUTE FUNCTION public.anotara_touch_updated_at();

-- 12. Essential bootstrap: an organizer can create a group/trip and immediately see it.
-- This runs under a trusted trigger function, not client-issued membership writes.
CREATE OR REPLACE FUNCTION public.anotara_add_group_creator()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $fn$
BEGIN
  INSERT INTO public.group_members (group_id,user_id,role,status)
  VALUES (NEW.id,NEW.created_by,'organizer','active');
  RETURN NEW;
END;
$fn$;
REVOKE ALL ON FUNCTION public.anotara_add_group_creator()
  FROM PUBLIC,anon,authenticated;
DROP TRIGGER IF EXISTS anotara_new_group_creator ON public.groups;
CREATE TRIGGER anotara_new_group_creator AFTER INSERT ON public.groups
  FOR EACH ROW EXECUTE FUNCTION public.anotara_add_group_creator();

CREATE OR REPLACE FUNCTION public.anotara_add_trip_creator()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $fn$
BEGIN
  INSERT INTO public.trip_members
    (trip_id,user_id,response,added_by,membership_status)
  VALUES (NEW.id,NEW.created_by,'going',NEW.created_by,'active');
  RETURN NEW;
END;
$fn$;
REVOKE ALL ON FUNCTION public.anotara_add_trip_creator()
  FROM PUBLIC,anon,authenticated;
DROP TRIGGER IF EXISTS anotara_new_trip_creator ON public.trips;
CREATE TRIGGER anotara_new_trip_creator AFTER INSERT ON public.trips
  FOR EACH ROW EXECUTE FUNCTION public.anotara_add_trip_creator();

-- 13. Close legacy direct-write permissions that bypass business rules.
-- The old RLS policies are retained for existing SELECT functionality; a
-- separate RPC migration must restore controlled member/expense mutations.
-- Revoking table DML also blocks old insecure policies from being exercised.
REVOKE INSERT,UPDATE,DELETE ON
  public.group_members,
  public.trip_members,
  public.group_invitations,
  public.expenses,
  public.expense_shares,
  public.settlements
FROM PUBLIC,anon,authenticated;

-- Organizers can still edit group name/description and ordinary trip fields,
-- but may not directly set trip status, move trips to other groups, or hard delete.
REVOKE UPDATE,DELETE ON public.groups,public.trips
FROM PUBLIC,anon,authenticated;
GRANT UPDATE(name,description) ON public.groups TO authenticated;
GRANT UPDATE(
  name,description,starts_at,ends_at,destination_name,
  destination_latitude,destination_longitude,
  meeting_location_name,meeting_location_address,
  meeting_latitude,meeting_longitude,budget_per_person
) ON public.trips TO authenticated;

-- Limit notification edits to the read timestamp, not arbitrary recipient/content.
REVOKE UPDATE ON public.notifications FROM PUBLIC,anon,authenticated;
GRANT UPDATE(read_at) ON public.notifications TO authenticated;

-- A departing member must not remain visible through another member's
-- group-readable preference policy. Keep existing own-profile access.
DROP POLICY IF EXISTS preferences_select_own_or_group
  ON public.member_preferences;
CREATE POLICY preferences_select_own_or_group
ON public.member_preferences FOR SELECT TO authenticated USING (
  user_id = (SELECT auth.uid())
  OR (
    visibility = 'group_members'
    AND EXISTS (
      SELECT 1 FROM public.group_members gm
      WHERE gm.user_id = member_preferences.user_id
        AND gm.status = 'active'
        AND public.is_group_member(gm.group_id)
    )
  )
);

-- Existing RLS helpers are not a substitute for RPCs validating state changes.
-- The legacy authorization policies are intentionally not made MORE permissive.
-- Direct INSERT of public.groups / public.trips remains enabled; triggers
-- create the respective organizer/participant under trusted privileges.

-- ============================================================================
-- SOURCE 2: GROUP CODE ISSUANCE
-- Original reviewed file: anotara_v2_group_invite_code_issue_LOCAL_TEST.sql
-- ============================================================================
CREATE OR REPLACE FUNCTION public.anotara_rotate_group_invite_code(p_group_id uuid)
RETURNS TABLE(invite_code text, expires_at timestamptz)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $function$
DECLARE
  v_actor uuid := (SELECT auth.uid());
  v_new_code text;
  v_old_code text;
  v_expires timestamptz := now() + interval '7 days';
  v_attempt integer;
BEGIN
  IF v_actor IS NULL THEN
    RAISE EXCEPTION 'You must sign in to issue an invitation code'
      USING ERRCODE = '28000';
  END IF;

  -- Lock the owning group to serialize code rotation for that group.
  -- A SECURITY DEFINER function must check its caller explicitly.
  PERFORM 1
  FROM public.groups AS g
  JOIN public.group_members AS gm ON gm.group_id = g.id
  WHERE g.id = p_group_id
    AND g.archived_at IS NULL
    AND gm.user_id = v_actor
    AND gm.role = 'organizer'
    AND gm.status = 'active'
  FOR UPDATE OF g;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Only an active group organizer can generate an invitation code'
      USING ERRCODE = '42501';
  END IF;

  SELECT gc.code INTO v_old_code
  FROM public.group_invite_codes AS gc
  WHERE gc.group_id = p_group_id;

  -- 12 uppercase hexadecimal characters = 48 random bits.
  -- A collision with another group's code is retried.
  FOR v_attempt IN 1..10 LOOP
    v_new_code := upper(substr(replace(pg_catalog.gen_random_uuid()::text, '-', ''), 1, 12));
    IF v_new_code = v_old_code THEN
      CONTINUE;
    END IF;

    BEGIN
      INSERT INTO public.group_invite_codes
        (group_id, code, created_by, created_at, expires_at)
      VALUES
        (p_group_id, v_new_code, v_actor, now(), v_expires)
      ON CONFLICT (group_id) DO UPDATE SET
        code = excluded.code,
        created_by = excluded.created_by,
        created_at = excluded.created_at,
        expires_at = excluded.expires_at;

      invite_code := v_new_code;
      expires_at := v_expires;
      RETURN NEXT;
      RETURN;
    EXCEPTION WHEN unique_violation THEN
      -- Another group already has this code. Generate another.
      NULL;
    END;
  END LOOP;

  RAISE EXCEPTION 'Could not generate a unique invitation code; retry';
END;
$function$;

REVOKE ALL ON FUNCTION public.anotara_rotate_group_invite_code(uuid)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.anotara_rotate_group_invite_code(uuid)
  TO authenticated;

COMMENT ON FUNCTION public.anotara_rotate_group_invite_code(uuid)
  IS 'Organizer-only: creates/replaces the single current group invite code (7-day expiry). No redemption endpoint is provided.';

-- ============================================================================
-- SOURCE 3: PHASE 2A: GROUP MANAGEMENT AND RSVP
-- Original reviewed file: anotara_v2_phase2_groups_and_rsvp_LOCAL_ONLY.sql
-- ============================================================================
SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '90s';

-- Guard against applying this batch out of order.
DO $guard$
BEGIN
  IF to_regclass('public.group_invite_codes') IS NULL
     OR to_regclass('public.member_availability') IS NULL
     OR to_regclass('public.group_members') IS NULL
     OR to_regclass('public.group_invitations') IS NULL
     OR to_regclass('public.trip_members') IS NULL
     OR to_regprocedure('public.anotara_rotate_group_invite_code(uuid)') IS NULL
  THEN
    RAISE EXCEPTION 'Missing V2 foundation or code-generation RPC. Stop.';
  END IF;
END;
$guard$;

-- Track failed AND successful code attempts. An invalid code must NOT raise an
-- exception after this counter is incremented, or PostgreSQL would roll back
-- the rate-limit record too. This is per-account DB throttling, not IP throttling.
CREATE TABLE IF NOT EXISTS public.anotara_code_redeem_attempts (
  user_id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  window_started timestamptz NOT NULL DEFAULT now(),
  attempt_count integer NOT NULL DEFAULT 0 CHECK (attempt_count >= 0),
  last_attempt_at timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE public.anotara_code_redeem_attempts ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.anotara_code_redeem_attempts FROM PUBLIC, anon, authenticated;

-- One current code per group is already enforced by group_invite_codes PK.
-- Previously removed members cannot self-rejoin through a generic share code.
CREATE OR REPLACE FUNCTION public.anotara_redeem_group_code(p_code text)
RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $function$
DECLARE
  v_actor uuid := (SELECT auth.uid());
  v_attempts integer;
  v_group uuid;
  v_group_name text;
  v_status text;
  v_inserted integer;
BEGIN
  IF v_actor IS NULL THEN
    RAISE EXCEPTION 'Sign in to join a group' USING ERRCODE = '28000';
  END IF;

  -- Unique key serializes concurrent attempts from the same authenticated user.
  INSERT INTO public.anotara_code_redeem_attempts AS a
    (user_id, window_started, attempt_count, last_attempt_at)
  VALUES (v_actor, now(), 1, now())
  ON CONFLICT (user_id) DO UPDATE SET
    window_started = CASE
      WHEN a.window_started <= now() - interval '15 minutes' THEN now()
      ELSE a.window_started END,
    attempt_count = CASE
      WHEN a.window_started <= now() - interval '15 minutes' THEN 1
      ELSE a.attempt_count + 1 END,
    last_attempt_at = now()
  RETURNING attempt_count INTO v_attempts;

  IF v_attempts > 5 THEN
    RETURN pg_catalog.jsonb_build_object(
      'success', false, 'group_id', NULL,
      'message', 'Too many attempts. Try again after 15 minutes.');
  END IF;

  -- Lock group to serialize with organizer code rotation (which locks group).
  SELECT gc.group_id, g.name
  INTO v_group, v_group_name
  FROM public.group_invite_codes AS gc
  JOIN public.groups AS g ON g.id = gc.group_id
  WHERE gc.code = upper(btrim(coalesce(p_code, '')))
    AND gc.expires_at > now()
    AND g.archived_at IS NULL
  FOR UPDATE OF g;

  IF v_group IS NULL THEN
    RETURN pg_catalog.jsonb_build_object(
      'success', false, 'group_id', NULL,
      'message', 'Invalid or expired invitation code.');
  END IF;

  SELECT gm.status INTO v_status
  FROM public.group_members AS gm
  WHERE gm.group_id = v_group AND gm.user_id = v_actor
  FOR UPDATE;

  IF v_status = 'removed' THEN
    RETURN pg_catalog.jsonb_build_object(
      'success', false, 'group_id', NULL,
      'message', 'You cannot rejoin this group using a code.');
  ELSIF v_status = 'active' THEN
    RETURN pg_catalog.jsonb_build_object(
      'success', true, 'group_id', v_group, 'group_name', v_group_name,
      'message', 'You are already a group member.');
  ELSIF v_status = 'left' THEN
    UPDATE public.group_members AS gm
      SET status = 'active', role = 'member', joined_at = now()
    WHERE gm.group_id = v_group AND gm.user_id = v_actor
      AND gm.status = 'left';
  ELSE
    INSERT INTO public.group_members (group_id, user_id, role, status)
    VALUES (v_group, v_actor, 'member', 'active')
    ON CONFLICT (group_id, user_id) DO NOTHING;
    GET DIAGNOSTICS v_inserted = ROW_COUNT;
    -- Handles another transaction adding/removing the user concurrently.
    IF v_inserted = 0 THEN
      SELECT gm.status INTO v_status FROM public.group_members AS gm
        WHERE gm.group_id = v_group AND gm.user_id = v_actor;
      IF v_status <> 'active' THEN
        RETURN pg_catalog.jsonb_build_object(
          'success', false, 'group_id', NULL,
          'message', 'Membership needs organizer review.');
      END IF;
    END IF;
  END IF;

  RETURN pg_catalog.jsonb_build_object(
    'success', true, 'group_id', v_group, 'group_name', v_group_name,
    'message', 'Joined group successfully.');
END;
$function$;
REVOKE ALL ON FUNCTION public.anotara_redeem_group_code(text)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.anotara_redeem_group_code(text)
  TO authenticated;

-- Organizer sends an addressed invitation to an existing registered user.
-- Existing unexpired pending invitation is reused (no duplicates on repeats).
CREATE OR REPLACE FUNCTION public.anotara_send_group_invitation(
  p_group_id uuid, p_invitee_user_id uuid)
RETURNS uuid
LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $function$
DECLARE
  v_actor uuid := (SELECT auth.uid());
  v_invitation uuid;
  v_status text;
BEGIN
  IF v_actor IS NULL OR p_invitee_user_id IS NULL OR p_invitee_user_id = v_actor THEN
    RAISE EXCEPTION 'Invalid invitation request' USING ERRCODE = '22023';
  END IF;
  PERFORM 1
  FROM public.groups AS g
  JOIN public.group_members AS gm
    ON gm.group_id = g.id
  WHERE g.id = p_group_id
    AND g.archived_at IS NULL
    AND gm.user_id = v_actor
    AND gm.role = 'organizer' AND gm.status = 'active'
  FOR UPDATE OF g;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Only an active organizer can invite members'
      USING ERRCODE = '42501';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.profiles AS p WHERE p.id = p_invitee_user_id) THEN
    RAISE EXCEPTION 'Invitee does not have an account' USING ERRCODE = '22023';
  END IF;
  SELECT gm.status INTO v_status FROM public.group_members AS gm
  WHERE gm.group_id = p_group_id AND gm.user_id = p_invitee_user_id;
  IF v_status = 'active' THEN
    RAISE EXCEPTION 'User is already a member' USING ERRCODE = '22023';
  ELSIF v_status = 'removed' THEN
    RAISE EXCEPTION 'Removed members need organizer review before rejoining'
      USING ERRCODE = '42501';
  END IF;

  UPDATE public.group_invitations AS gi SET status = 'expired'
  WHERE gi.group_id = p_group_id
    AND gi.invitee_user_id = p_invitee_user_id
    AND gi.status = 'pending' AND gi.expires_at <= now();

  SELECT gi.id INTO v_invitation
  FROM public.group_invitations AS gi
  WHERE gi.group_id = p_group_id
    AND gi.invitee_user_id = p_invitee_user_id
    AND gi.status = 'pending' AND gi.expires_at > now()
  ORDER BY gi.created_at DESC LIMIT 1;
  IF v_invitation IS NOT NULL THEN
    RETURN v_invitation;
  END IF;

  INSERT INTO public.group_invitations
    (group_id, inviter_id, invitee_user_id, status, expires_at)
  VALUES
    (p_group_id, v_actor, p_invitee_user_id, 'pending', now() + interval '7 days')
  RETURNING id INTO v_invitation;
  RETURN v_invitation;
END;
$function$;
REVOKE ALL ON FUNCTION public.anotara_send_group_invitation(uuid,uuid)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.anotara_send_group_invitation(uuid,uuid)
  TO authenticated;

-- Only the invitee can accept/decline an addressed invitation.
CREATE OR REPLACE FUNCTION public.anotara_respond_group_invitation(
  p_invitation_id uuid, p_accept boolean)
RETURNS text
LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $function$
DECLARE
  v_actor uuid := (SELECT auth.uid());
  v_inv record;
  v_existing text;
BEGIN
  IF v_actor IS NULL OR p_accept IS NULL THEN
    RAISE EXCEPTION 'Sign in and select Accept or Decline'
      USING ERRCODE = '22023';
  END IF;
  SELECT gi.id, gi.group_id, gi.invitee_user_id, gi.status,
         gi.expires_at, g.archived_at
  INTO v_inv
  FROM public.group_invitations AS gi
  JOIN public.groups AS g ON g.id = gi.group_id
  WHERE gi.id = p_invitation_id
  FOR UPDATE OF gi, g;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Invitation not found' USING ERRCODE = '42501';
  END IF;
  IF v_inv.invitee_user_id IS DISTINCT FROM v_actor THEN
    RAISE EXCEPTION 'Invitation not found' USING ERRCODE = '42501';
  END IF;
  IF v_inv.status <> 'pending' THEN
    RETURN v_inv.status;
  END IF;
  IF v_inv.expires_at <= now() THEN
    UPDATE public.group_invitations SET status = 'expired' WHERE id = p_invitation_id;
    RETURN 'expired';
  END IF;
  IF v_inv.archived_at IS NOT NULL THEN
    UPDATE public.group_invitations SET status = 'cancelled' WHERE id = p_invitation_id;
    RETURN 'cancelled';
  END IF;
  IF NOT p_accept THEN
    UPDATE public.group_invitations SET status = 'declined' WHERE id = p_invitation_id;
    RETURN 'declined';
  END IF;

  SELECT gm.status INTO v_existing
  FROM public.group_members AS gm
  WHERE gm.group_id = v_inv.group_id AND gm.user_id = v_actor
  FOR UPDATE;
  IF v_existing = 'removed' THEN
    RAISE EXCEPTION 'Removed membership cannot be restored by invitation'
      USING ERRCODE = '42501';
  ELSIF v_existing = 'left' THEN
    UPDATE public.group_members AS gm
      SET status = 'active', role = 'member', joined_at = now()
    WHERE gm.group_id = v_inv.group_id AND gm.user_id = v_actor;
  ELSIF v_existing IS NULL THEN
    INSERT INTO public.group_members (group_id,user_id,role,status)
      VALUES (v_inv.group_id,v_actor,'member','active')
      ON CONFLICT (group_id,user_id) DO NOTHING;
  END IF;
  UPDATE public.group_invitations AS gi
    SET status = 'accepted', accepted_at = now()
  WHERE gi.id = p_invitation_id;
  RETURN 'accepted';
END;
$function$;
REVOKE ALL ON FUNCTION public.anotara_respond_group_invitation(uuid,boolean)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.anotara_respond_group_invitation(uuid,boolean)
  TO authenticated;

-- Group organizer adds an existing ACTIVE group member to an upcoming/ongoing
-- trip. If they were previously removed/left the trip, require a separate
-- explicit re-invitation workflow (do not silently reactivate history).
CREATE OR REPLACE FUNCTION public.anotara_add_trip_participant(
  p_trip_id uuid, p_user_id uuid)
RETURNS text
LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $function$
DECLARE
  v_actor uuid := (SELECT auth.uid());
  v_group uuid;
  v_existing text;
BEGIN
  IF v_actor IS NULL OR p_user_id IS NULL THEN
    RAISE EXCEPTION 'Invalid request' USING ERRCODE = '22023';
  END IF;
  SELECT t.group_id INTO v_group
  FROM public.trips AS t
  JOIN public.groups AS g ON g.id = t.group_id
  JOIN public.group_members AS gm ON gm.group_id = t.group_id
  WHERE t.id = p_trip_id
    AND t.status IN ('upcoming','ongoing')
    AND g.archived_at IS NULL
    AND gm.user_id = v_actor
    AND gm.role = 'organizer' AND gm.status = 'active'
  FOR UPDATE OF t;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Only an active organizer may add members to an upcoming/ongoing trip'
      USING ERRCODE = '42501';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM public.group_members AS gm
    WHERE gm.group_id = v_group
      AND gm.user_id = p_user_id AND gm.status = 'active'
  ) THEN
    RAISE EXCEPTION 'User must be an active member of this group'
      USING ERRCODE = '22023';
  END IF;
  SELECT tm.membership_status INTO v_existing
  FROM public.trip_members AS tm
  WHERE tm.trip_id = p_trip_id AND tm.user_id = p_user_id
  FOR UPDATE;
  IF v_existing = 'active' THEN
    RETURN 'already_member';
  ELSIF v_existing IN ('left','removed') THEN
    RETURN 'membership_review_required';
  END IF;
  INSERT INTO public.trip_members
    (trip_id,user_id,response,added_by,membership_status)
  VALUES (p_trip_id,p_user_id,'pending',v_actor,'active');
  RETURN 'added';
END;
$function$;
REVOKE ALL ON FUNCTION public.anotara_add_trip_participant(uuid,uuid)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.anotara_add_trip_participant(uuid,uuid)
  TO authenticated;

-- Member controls only their OWN RSVP, without getting direct UPDATE access.
-- Not Going is still an active member; no Maybe RSVP in V2.
CREATE OR REPLACE FUNCTION public.anotara_set_trip_rsvp(
  p_trip_id uuid, p_response text)
RETURNS text
LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $function$
DECLARE
  v_actor uuid := (SELECT auth.uid());
  v_response text;
BEGIN
  IF v_actor IS NULL THEN
    RAISE EXCEPTION 'Sign in to update your RSVP' USING ERRCODE = '28000';
  END IF;
  IF p_response IS NULL OR p_response NOT IN ('going','not_going') THEN
    RAISE EXCEPTION 'RSVP must be going or not_going' USING ERRCODE = '22023';
  END IF;
  UPDATE public.trip_members AS tm
     SET response = p_response, responded_at = now()
  FROM public.trips AS t
  JOIN public.groups AS g ON g.id = t.group_id
  JOIN public.group_members AS gm ON gm.group_id = t.group_id
  WHERE tm.trip_id = t.id
    AND tm.trip_id = p_trip_id
    AND tm.user_id = v_actor
    AND tm.membership_status = 'active'
    AND gm.user_id = v_actor AND gm.status = 'active'
    AND t.status IN ('upcoming','ongoing')
    AND g.archived_at IS NULL
  RETURNING tm.response INTO v_response;
  IF v_response IS NULL THEN
    RAISE EXCEPTION 'Trip unavailable, RSVP locked, or you are not an active member'
      USING ERRCODE = '42501';
  END IF;
  RETURN v_response;
END;
$function$;
REVOKE ALL ON FUNCTION public.anotara_set_trip_rsvp(uuid,text)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.anotara_set_trip_rsvp(uuid,text)
  TO authenticated;

-- Never regrant unrestricted direct DML to the protected tables.
REVOKE INSERT, UPDATE, DELETE ON
  public.group_members, public.group_invitations, public.trip_members
FROM PUBLIC, anon, authenticated;

-- ============================================================================
-- SOURCE 4: PHASE 2B: EXPENSES AND DEPARTURES
-- Original reviewed file: anotara_v2_phase2b_expenses_and_departures_LOCAL_ONLY.sql
-- ============================================================================
SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '90s';

DO $guard$
BEGIN
  IF to_regprocedure('public.anotara_set_trip_rsvp(uuid,text)') IS NULL
     OR to_regprocedure('public.anotara_redeem_group_code(text)') IS NULL
     OR to_regclass('public.trip_location_permissions') IS NULL
  THEN
    RAISE EXCEPTION 'Phase 2A or V2 foundation missing; stop.';
  END IF;
  -- Do not retrofit semantics to already-populated financial tables.
  IF EXISTS (SELECT 1 FROM public.expenses)
     OR EXISTS (SELECT 1 FROM public.expense_shares)
     OR EXISTS (SELECT 1 FROM public.settlements)
  THEN
    RAISE EXCEPTION 'Financial rows already exist. Review/manual migration required before Phase 2B.';
  END IF;
END;
$guard$;

-- Repayments are linked to their originating expense for auditability.
ALTER TABLE public.settlements ADD COLUMN IF NOT EXISTS expense_id uuid
  REFERENCES public.expenses(id);
CREATE UNIQUE INDEX IF NOT EXISTS anotara_one_paid_repayment_per_share
  ON public.settlements(expense_id, payer_id)
  WHERE expense_id IS NOT NULL AND status = 'paid';
CREATE INDEX IF NOT EXISTS anotara_expenses_trip_idx
  ON public.expenses(trip_id,created_at DESC);
CREATE INDEX IF NOT EXISTS anotara_shares_user_unsettled_idx
  ON public.expense_shares(user_id,is_settled);

-- The debtor AND the user who fronted the money must both settle all
-- nonzero unpaid shares before either may leave or be removed.
CREATE OR REPLACE FUNCTION public.anotara_has_unsettled_trip_obligations(
  p_trip_id uuid, p_user_id uuid)
RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = ''
AS $fn$
  SELECT EXISTS (
    SELECT 1
    FROM public.expenses e
    JOIN public.expense_shares s ON s.expense_id = e.id
    WHERE e.trip_id = p_trip_id
      AND NOT s.is_settled
      AND s.share_amount > 0
      AND s.user_id <> e.paid_by
      AND (s.user_id = p_user_id OR e.paid_by = p_user_id)
  );
$fn$;
REVOKE ALL ON FUNCTION public.anotara_has_unsettled_trip_obligations(uuid,uuid)
  FROM PUBLIC, anon, authenticated;

CREATE OR REPLACE FUNCTION public.anotara_has_unsettled_group_obligations(
  p_group_id uuid, p_user_id uuid)
RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = ''
AS $fn$
  SELECT EXISTS (
    SELECT 1 FROM public.trips t
    WHERE t.group_id = p_group_id
      AND public.anotara_has_unsettled_trip_obligations(t.id,p_user_id)
  );
$fn$;
REVOKE ALL ON FUNCTION public.anotara_has_unsettled_group_obligations(uuid,uuid)
  FROM PUBLIC, anon, authenticated;

-- Internal helper: input format
-- equal:  [{"user_id":"uuid"}, ...]
-- custom: [{"user_id":"uuid","amount":100.00}, ...]
-- Splits add up EXACTLY in cents. The expense payer's own share is
-- considered already paid at purchase, not a debt to themself.
CREATE OR REPLACE FUNCTION public.anotara_replace_expense_shares(
  p_expense_id uuid, p_trip_id uuid, p_paid_by uuid,
  p_amount numeric, p_split_method text, p_members jsonb)
RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $fn$
DECLARE
  v_count integer;
  v_distinct integer;
  v_cents bigint;
BEGIN
  IF p_amount IS NULL OR p_amount <= 0
     OR p_amount <> round(p_amount,2)
     OR p_split_method IS NULL
     OR p_split_method NOT IN ('equal','custom') THEN
    RAISE EXCEPTION 'Positive two-decimal amount and equal/custom split required'
      USING ERRCODE='22023';
  END IF;
  IF p_members IS NULL OR pg_catalog.jsonb_typeof(p_members) <> 'array'
     OR pg_catalog.jsonb_array_length(p_members) NOT BETWEEN 1 AND 100 THEN
    RAISE EXCEPTION 'Choose between 1 and 100 split participants'
      USING ERRCODE='22023';
  END IF;
  -- Type checks BEFORE casting JSON values to UUID/numeric.
  IF EXISTS (
    SELECT 1 FROM pg_catalog.jsonb_array_elements(p_members) AS x(item)
    WHERE pg_catalog.jsonb_typeof(x.item) <> 'object'
      OR x.item->>'user_id' IS NULL
      OR (p_split_method='custom' AND x.item->>'amount' IS NULL)
  ) THEN
    RAISE EXCEPTION 'Every split requires a user_id and custom splits require amount'
      USING ERRCODE='22023';
  END IF;
  SELECT count(*), count(DISTINCT (x.item->>'user_id')::uuid)
    INTO v_count, v_distinct
  FROM pg_catalog.jsonb_array_elements(p_members) AS x(item);
  IF v_count <> v_distinct THEN
    RAISE EXCEPTION 'Duplicate split participants' USING ERRCODE='22023';
  END IF;
  IF EXISTS (
    SELECT 1
    FROM pg_catalog.jsonb_array_elements(p_members) AS x(item)
    LEFT JOIN public.trip_members tm
      ON tm.trip_id=p_trip_id AND tm.user_id=(x.item->>'user_id')::uuid
    JOIN public.trips t ON t.id=p_trip_id
    LEFT JOIN public.group_members gm
      ON gm.group_id=t.group_id AND gm.user_id=(x.item->>'user_id')::uuid
    WHERE tm.membership_status IS DISTINCT FROM 'active'
       OR gm.status IS DISTINCT FROM 'active'
  ) THEN
    RAISE EXCEPTION 'Every split participant must be an active trip/group member'
      USING ERRCODE='22023';
  END IF;
  IF p_split_method='custom' THEN
    IF EXISTS (
      SELECT 1 FROM pg_catalog.jsonb_array_elements(p_members) AS x(item)
      WHERE (x.item->>'amount')::numeric < 0
         OR (x.item->>'amount')::numeric
              <> round((x.item->>'amount')::numeric,2)
    ) OR (
      SELECT sum((x.item->>'amount')::numeric)
      FROM pg_catalog.jsonb_array_elements(p_members) AS x(item)
    ) <> p_amount THEN
      RAISE EXCEPTION 'Custom shares must be nonnegative, two-decimal, and total the expense'
        USING ERRCODE='22023';
    END IF;
  END IF;

  v_cents := (p_amount * 100)::bigint;
  DELETE FROM public.expense_shares WHERE expense_id=p_expense_id;
  INSERT INTO public.expense_shares
    (expense_id,user_id,share_amount,share_value,is_settled,settled_at)
  SELECT p_expense_id, allocations.member_id, allocations.share_amount, NULL,
    (allocations.member_id=p_paid_by OR allocations.share_amount=0),
    CASE WHEN allocations.member_id=p_paid_by OR allocations.share_amount=0
      THEN now() ELSE NULL END
  FROM (
    SELECT members.member_id,
      CASE WHEN p_split_method='equal'
        THEN (
          floor(v_cents::numeric/v_count)
          + CASE WHEN members.rn <= mod(v_cents,v_count) THEN 1 ELSE 0 END
        ) / 100
        ELSE members.custom_amount END AS share_amount
    FROM (
      SELECT (x.item->>'user_id')::uuid AS member_id,
        (x.item->>'amount')::numeric AS custom_amount,
        row_number() OVER (ORDER BY (x.item->>'user_id')::uuid) AS rn
      FROM pg_catalog.jsonb_array_elements(p_members) AS x(item)
    ) AS members
  ) AS allocations;
END;
$fn$;
REVOKE ALL ON FUNCTION public.anotara_replace_expense_shares(uuid,uuid,uuid,numeric,text,jsonb)
  FROM PUBLIC, anon, authenticated;

-- Create an expense and all its shares atomically.
-- Locks the group row to serialize against leaves and removals.
CREATE OR REPLACE FUNCTION public.anotara_create_expense(
  p_trip_id uuid, p_description text, p_amount numeric,
  p_paid_by uuid, p_split_method text, p_members jsonb,
  p_category text DEFAULT NULL, p_notes text DEFAULT NULL)
RETURNS uuid
LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $fn$
DECLARE
  v_actor uuid := (SELECT auth.uid());
  v_group uuid;
  v_expense uuid;
BEGIN
  IF v_actor IS NULL THEN
    RAISE EXCEPTION 'Sign in to add an expense' USING ERRCODE='28000';
  END IF;
  SELECT t.group_id INTO v_group FROM public.trips t WHERE t.id=p_trip_id;
  IF v_group IS NULL THEN
    RAISE EXCEPTION 'Trip not found' USING ERRCODE='22023';
  END IF;
  PERFORM 1 FROM public.groups g
    WHERE g.id=v_group AND g.archived_at IS NULL FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Group is unavailable' USING ERRCODE='42501';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM public.trips t
    JOIN public.trip_members tm ON tm.trip_id=t.id
    JOIN public.group_members gm ON gm.group_id=t.group_id AND gm.user_id=tm.user_id
    WHERE t.id=p_trip_id AND t.status IN ('upcoming','ongoing')
      AND tm.user_id=v_actor AND tm.membership_status='active'
      AND gm.status='active'
  ) OR NOT EXISTS (
    SELECT 1 FROM public.trip_members tm
    JOIN public.trips t ON t.id=tm.trip_id
    JOIN public.group_members gm ON gm.group_id=t.group_id AND gm.user_id=tm.user_id
    WHERE tm.trip_id=p_trip_id AND tm.user_id=p_paid_by
      AND tm.membership_status='active' AND gm.status='active'
  ) THEN
    RAISE EXCEPTION 'An active member and active expense payer are required on an open trip'
      USING ERRCODE='42501';
  END IF;
  IF p_description IS NULL OR length(btrim(p_description)) NOT BETWEEN 1 AND 160
    OR p_amount IS NULL OR p_amount<=0 OR p_amount<>round(p_amount,2)
    OR (p_category IS NOT NULL AND length(p_category)>80) THEN
    RAISE EXCEPTION 'Invalid description, amount or category'
      USING ERRCODE='22023';
  END IF;
  INSERT INTO public.expenses
    (trip_id,paid_by,created_by,description,amount,currency,category,split_method,notes)
  VALUES (p_trip_id,p_paid_by,v_actor,btrim(p_description),p_amount,'PHP',
    nullif(btrim(p_category),''),p_split_method,p_notes)
  RETURNING id INTO v_expense;
  PERFORM public.anotara_replace_expense_shares(
    v_expense,p_trip_id,p_paid_by,p_amount,p_split_method,p_members);
  RETURN v_expense;
END;
$fn$;
REVOKE ALL ON FUNCTION public.anotara_create_expense(uuid,text,numeric,uuid,text,jsonb,text,text)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.anotara_create_expense(uuid,text,numeric,uuid,text,jsonb,text,text)
  TO authenticated;

-- Only the person who ADDED the expense may edit its amount/splits.
-- Lock the group before the expense for consistent concurrent operations.
CREATE OR REPLACE FUNCTION public.anotara_edit_expense(
  p_expense_id uuid, p_description text, p_amount numeric,
  p_split_method text, p_members jsonb,
  p_category text DEFAULT NULL, p_notes text DEFAULT NULL)
RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $fn$
DECLARE
  v_actor uuid := (SELECT auth.uid());
  v_trip uuid;
  v_group uuid;
  v_exp public.expenses%ROWTYPE;
BEGIN
  IF v_actor IS NULL THEN
    RAISE EXCEPTION 'Sign in to edit expenses' USING ERRCODE='28000';
  END IF;
  SELECT e.trip_id,t.group_id INTO v_trip,v_group
    FROM public.expenses e JOIN public.trips t ON t.id=e.trip_id
    WHERE e.id=p_expense_id;
  IF v_trip IS NULL THEN RAISE EXCEPTION 'Expense not found' USING ERRCODE='22023'; END IF;
  PERFORM 1 FROM public.groups g WHERE g.id=v_group AND g.archived_at IS NULL FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Group unavailable' USING ERRCODE='42501'; END IF;
  SELECT e.* INTO v_exp FROM public.expenses e WHERE e.id=p_expense_id FOR UPDATE;
  IF NOT FOUND OR v_exp.created_by <> v_actor
     OR NOT EXISTS (
       SELECT 1 FROM public.trips t
       JOIN public.trip_members tm ON tm.trip_id=t.id AND tm.user_id=v_actor
       JOIN public.group_members gm ON gm.group_id=t.group_id AND gm.user_id=v_actor
       WHERE t.id=v_trip AND t.status IN ('upcoming','ongoing')
         AND tm.membership_status='active' AND gm.status='active'
     ) THEN
    RAISE EXCEPTION 'Only the expense creator may edit an open trip expense'
      USING ERRCODE='42501';
  END IF;
  IF EXISTS (
    SELECT 1 FROM public.expense_shares s
    WHERE s.expense_id=p_expense_id AND s.user_id<>v_exp.paid_by AND s.is_settled
      AND s.share_amount>0
  ) OR EXISTS (SELECT 1 FROM public.settlements st WHERE st.expense_id=p_expense_id) THEN
    RAISE EXCEPTION 'Expense cannot be edited after a repayment has been recorded'
      USING ERRCODE='42501';
  END IF;
  IF p_description IS NULL OR length(btrim(p_description)) NOT BETWEEN 1 AND 160
     OR p_amount IS NULL OR p_amount <=0 OR p_amount<>round(p_amount,2)
     OR (p_category IS NOT NULL AND length(p_category)>80) THEN
    RAISE EXCEPTION 'Invalid description, amount or category' USING ERRCODE='22023';
  END IF;
  UPDATE public.expenses e
    SET description=btrim(p_description),amount=p_amount,
        split_method=p_split_method,category=nullif(btrim(p_category),''),notes=p_notes
    WHERE e.id=p_expense_id;
  PERFORM public.anotara_replace_expense_shares(
    p_expense_id,v_trip,v_exp.paid_by,p_amount,p_split_method,p_members);
END;
$fn$;
REVOKE ALL ON FUNCTION public.anotara_edit_expense(uuid,text,numeric,text,jsonb,text,text)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.anotara_edit_expense(uuid,text,numeric,text,jsonb,text,text)
  TO authenticated;

-- Delete only own un-repaid OPEN expenses. Fully settled historical
-- expenses are still subject to trip/group financial-history retention.
CREATE OR REPLACE FUNCTION public.anotara_delete_expense(p_expense_id uuid)
RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $fn$
DECLARE
  v_actor uuid := (SELECT auth.uid());
  v_group uuid;
  v_exp public.expenses%ROWTYPE;
BEGIN
  IF v_actor IS NULL THEN RAISE EXCEPTION 'Sign in' USING ERRCODE='28000'; END IF;
  SELECT t.group_id INTO v_group FROM public.expenses e
    JOIN public.trips t ON t.id=e.trip_id WHERE e.id=p_expense_id;
  IF v_group IS NULL THEN RAISE EXCEPTION 'Expense not found' USING ERRCODE='22023'; END IF;
  PERFORM 1 FROM public.groups g WHERE g.id=v_group AND g.archived_at IS NULL FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Group unavailable' USING ERRCODE='42501'; END IF;
  SELECT * INTO v_exp FROM public.expenses WHERE id=p_expense_id FOR UPDATE;
  IF NOT FOUND OR v_exp.created_by <> v_actor
    OR NOT EXISTS (
      SELECT 1 FROM public.trips t
      JOIN public.trip_members tm ON tm.trip_id=t.id AND tm.user_id=v_actor
      JOIN public.group_members gm ON gm.group_id=t.group_id AND gm.user_id=v_actor
      WHERE t.id=v_exp.trip_id AND t.status IN ('upcoming','ongoing')
        AND tm.membership_status='active' AND gm.status='active'
    ) THEN
    RAISE EXCEPTION 'Only the expense creator may delete an open trip expense'
      USING ERRCODE='42501';
  END IF;
  IF EXISTS (
    SELECT 1 FROM public.expense_shares s WHERE s.expense_id=p_expense_id
    AND s.user_id<>v_exp.paid_by AND s.is_settled AND s.share_amount>0
  ) OR EXISTS (SELECT 1 FROM public.settlements WHERE expense_id=p_expense_id) THEN
    RAISE EXCEPTION 'Expense cannot be deleted after repayment'
      USING ERRCODE='42501';
  END IF;
  DELETE FROM public.expense_shares WHERE expense_id=p_expense_id;
  DELETE FROM public.expenses WHERE id=p_expense_id;
END;
$fn$;
REVOKE ALL ON FUNCTION public.anotara_delete_expense(uuid)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.anotara_delete_expense(uuid) TO authenticated;

-- Only the person who originally fronted the expense confirms repayment.
-- Works for completed/cancelled trips so old balances can still be resolved.
CREATE OR REPLACE FUNCTION public.anotara_confirm_repayment(
  p_expense_id uuid, p_debtor_id uuid)
RETURNS uuid
LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $fn$
DECLARE
  v_actor uuid := (SELECT auth.uid());
  v_group uuid;
  v_exp public.expenses%ROWTYPE;
  v_share numeric;
  v_settlement uuid;
BEGIN
  IF v_actor IS NULL THEN RAISE EXCEPTION 'Sign in' USING ERRCODE='28000'; END IF;
  SELECT t.group_id INTO v_group FROM public.expenses e
    JOIN public.trips t ON t.id=e.trip_id WHERE e.id=p_expense_id;
  IF v_group IS NULL THEN RAISE EXCEPTION 'Expense not found' USING ERRCODE='22023'; END IF;
  PERFORM 1 FROM public.groups g WHERE g.id=v_group FOR UPDATE;
  SELECT * INTO v_exp FROM public.expenses WHERE id=p_expense_id FOR UPDATE;
  IF NOT FOUND OR v_exp.paid_by<>v_actor OR p_debtor_id=v_actor THEN
    RAISE EXCEPTION 'Only the original expense payer can verify another member''s repayment'
      USING ERRCODE='42501';
  END IF;
  SELECT s.share_amount INTO v_share
    FROM public.expense_shares s
    WHERE s.expense_id=p_expense_id AND s.user_id=p_debtor_id
      AND NOT s.is_settled AND s.share_amount>0
    FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'No outstanding share for that member'
      USING ERRCODE='22023';
  END IF;
  UPDATE public.expense_shares
    SET is_settled=true, settled_at=now()
    WHERE expense_id=p_expense_id AND user_id=p_debtor_id;
  INSERT INTO public.settlements
    (expense_id,trip_id,payer_id,payee_id,amount,currency,status,paid_at)
  VALUES
    (p_expense_id,v_exp.trip_id,p_debtor_id,v_actor,v_share,v_exp.currency,'paid',now())
  RETURNING id INTO v_settlement;
  RETURN v_settlement;
END;
$fn$;
REVOKE ALL ON FUNCTION public.anotara_confirm_repayment(uuid,uuid)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.anotara_confirm_repayment(uuid,uuid)
  TO authenticated;

-- Leaving a trip changes membership_status. Financial history is retained.
CREATE OR REPLACE FUNCTION public.anotara_leave_trip(p_trip_id uuid)
RETURNS text
LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $fn$
DECLARE
  v_actor uuid := (SELECT auth.uid());
  v_group uuid;
  v_trip_creator uuid;
  v_status text;
BEGIN
  IF v_actor IS NULL THEN RAISE EXCEPTION 'Sign in' USING ERRCODE='28000'; END IF;
  SELECT t.group_id INTO v_group FROM public.trips t WHERE t.id=p_trip_id;
  IF v_group IS NULL THEN RAISE EXCEPTION 'Trip not found' USING ERRCODE='22023'; END IF;
  PERFORM 1 FROM public.groups g WHERE g.id=v_group AND g.archived_at IS NULL FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Group unavailable' USING ERRCODE='42501'; END IF;
  SELECT t.created_by,t.status INTO v_trip_creator,v_status
    FROM public.trips t WHERE t.id=p_trip_id;
  IF v_status NOT IN ('upcoming','ongoing') THEN
    RAISE EXCEPTION 'Past/cancelled trips retain participation history'
      USING ERRCODE='42501';
  END IF;
  IF v_actor=v_trip_creator OR EXISTS (
    SELECT 1 FROM public.group_members gm
    WHERE gm.group_id=v_group AND gm.user_id=v_actor
      AND gm.role='organizer' AND gm.status='active'
  ) THEN
    RAISE EXCEPTION 'An organizer cannot leave their own trip'
      USING ERRCODE='42501';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM public.trip_members tm
    JOIN public.group_members gm ON gm.user_id=tm.user_id AND gm.group_id=v_group
    WHERE tm.trip_id=p_trip_id AND tm.user_id=v_actor
      AND tm.membership_status='active' AND gm.status='active'
  ) THEN
    RAISE EXCEPTION 'Not an active trip participant' USING ERRCODE='42501';
  END IF;
  IF public.anotara_has_unsettled_trip_obligations(p_trip_id,v_actor) THEN
    RAISE EXCEPTION 'Settle your outstanding trip debts/receivables before leaving'
      USING ERRCODE='42501';
  END IF;
  UPDATE public.trip_location_permissions
    SET enabled=false WHERE trip_id=p_trip_id AND user_id=v_actor;
  UPDATE public.location_shares
    SET is_active=false WHERE trip_id=p_trip_id AND user_id=v_actor;
  UPDATE public.trip_members
    SET membership_status='left',left_at=now()
    WHERE trip_id=p_trip_id AND user_id=v_actor;
  RETURN 'left';
END;
$fn$;
REVOKE ALL ON FUNCTION public.anotara_leave_trip(uuid)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.anotara_leave_trip(uuid) TO authenticated;

-- Leaving a group also exits its associated trips but preserves member rows.
CREATE OR REPLACE FUNCTION public.anotara_leave_group(p_group_id uuid)
RETURNS text
LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $fn$
DECLARE
  v_actor uuid := (SELECT auth.uid());
BEGIN
  IF v_actor IS NULL THEN RAISE EXCEPTION 'Sign in' USING ERRCODE='28000'; END IF;
  PERFORM 1 FROM public.groups g
    WHERE g.id=p_group_id AND g.archived_at IS NULL FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Group unavailable' USING ERRCODE='42501'; END IF;
  IF NOT EXISTS (
    SELECT 1 FROM public.group_members gm
    WHERE gm.group_id=p_group_id AND gm.user_id=v_actor
      AND gm.status='active' AND gm.role='member'
  ) THEN
    RAISE EXCEPTION 'Only an active regular member may leave this group'
      USING ERRCODE='42501';
  END IF;
  IF public.anotara_has_unsettled_group_obligations(p_group_id,v_actor) THEN
    RAISE EXCEPTION 'Settle all group trip debts/receivables before leaving'
      USING ERRCODE='42501';
  END IF;
  UPDATE public.trip_location_permissions lp SET enabled=false
    FROM public.trips t
    WHERE lp.trip_id=t.id AND t.group_id=p_group_id AND lp.user_id=v_actor;
  UPDATE public.location_shares ls SET is_active=false
    FROM public.trips t
    WHERE ls.trip_id=t.id AND t.group_id=p_group_id AND ls.user_id=v_actor;
  UPDATE public.trip_members tm SET membership_status='left',left_at=now()
    FROM public.trips t
    WHERE tm.trip_id=t.id AND t.group_id=p_group_id
      AND tm.user_id=v_actor AND tm.membership_status='active';
  UPDATE public.group_members gm SET status='left'
    WHERE gm.group_id=p_group_id AND gm.user_id=v_actor;
  RETURN 'left';
END;
$fn$;
REVOKE ALL ON FUNCTION public.anotara_leave_group(uuid)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.anotara_leave_group(uuid) TO authenticated;

-- Active group organizer may remove a non-organizer from a trip (not the
-- trip creator); all monetary obligations must be resolved first.
CREATE OR REPLACE FUNCTION public.anotara_remove_trip_participant(
  p_trip_id uuid, p_user_id uuid)
RETURNS text
LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $fn$
DECLARE
  v_actor uuid := (SELECT auth.uid());
  v_group uuid;
  v_trip_creator uuid;
  v_status text;
BEGIN
  IF v_actor IS NULL OR p_user_id IS NULL THEN
    RAISE EXCEPTION 'Invalid removal request' USING ERRCODE='22023';
  END IF;
  SELECT t.group_id INTO v_group FROM public.trips t WHERE t.id=p_trip_id;
  IF v_group IS NULL THEN RAISE EXCEPTION 'Trip not found' USING ERRCODE='22023'; END IF;
  PERFORM 1 FROM public.groups g WHERE g.id=v_group AND g.archived_at IS NULL FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Group unavailable' USING ERRCODE='42501'; END IF;
  IF NOT EXISTS (
    SELECT 1 FROM public.group_members gm WHERE gm.group_id=v_group
      AND gm.user_id=v_actor AND gm.role='organizer' AND gm.status='active'
  ) THEN
    RAISE EXCEPTION 'Active group organizer required' USING ERRCODE='42501';
  END IF;
  SELECT t.created_by,t.status INTO v_trip_creator,v_status
    FROM public.trips t WHERE t.id=p_trip_id;
  IF v_status NOT IN ('upcoming','ongoing') THEN
    RAISE EXCEPTION 'Closed trip membership is read-only' USING ERRCODE='42501';
  END IF;
  IF p_user_id=v_trip_creator OR p_user_id=v_actor
     OR EXISTS (
       SELECT 1 FROM public.group_members gm WHERE gm.group_id=v_group
         AND gm.user_id=p_user_id AND gm.role='organizer' AND gm.status='active'
     ) THEN
    RAISE EXCEPTION 'Cannot remove a trip creator or group organizer'
      USING ERRCODE='42501';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM public.trip_members tm
    WHERE tm.trip_id=p_trip_id AND tm.user_id=p_user_id
      AND tm.membership_status='active'
  ) THEN
    RAISE EXCEPTION 'Participant is not active' USING ERRCODE='22023';
  END IF;
  IF public.anotara_has_unsettled_trip_obligations(p_trip_id,p_user_id) THEN
    RAISE EXCEPTION 'Member has unsettled debts/receivables'
      USING ERRCODE='42501';
  END IF;
  UPDATE public.trip_location_permissions
    SET enabled=false WHERE trip_id=p_trip_id AND user_id=p_user_id;
  UPDATE public.location_shares SET is_active=false
    WHERE trip_id=p_trip_id AND user_id=p_user_id;
  UPDATE public.trip_members SET membership_status='removed',removed_at=now()
    WHERE trip_id=p_trip_id AND user_id=p_user_id;
  RETURN 'removed';
END;
$fn$;
REVOKE ALL ON FUNCTION public.anotara_remove_trip_participant(uuid,uuid)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.anotara_remove_trip_participant(uuid,uuid)
  TO authenticated;

-- Active group organizer may remove a regular member from the group and
-- all its associated trips, after every group debt/receivable is resolved.
CREATE OR REPLACE FUNCTION public.anotara_remove_group_member(
  p_group_id uuid, p_user_id uuid)
RETURNS text
LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $fn$
DECLARE
  v_actor uuid := (SELECT auth.uid());
BEGIN
  IF v_actor IS NULL OR p_user_id IS NULL OR p_user_id=v_actor THEN
    RAISE EXCEPTION 'Invalid removal request' USING ERRCODE='22023';
  END IF;
  PERFORM 1 FROM public.groups g
    WHERE g.id=p_group_id AND g.archived_at IS NULL FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Group unavailable' USING ERRCODE='42501'; END IF;
  IF NOT EXISTS (
    SELECT 1 FROM public.group_members gm
    WHERE gm.group_id=p_group_id AND gm.user_id=v_actor
      AND gm.role='organizer' AND gm.status='active'
  ) OR NOT EXISTS (
    SELECT 1 FROM public.group_members gm
    WHERE gm.group_id=p_group_id AND gm.user_id=p_user_id
      AND gm.role='member' AND gm.status='active'
  ) THEN
    RAISE EXCEPTION 'Active organizer and active regular member required'
      USING ERRCODE='42501';
  END IF;
  IF public.anotara_has_unsettled_group_obligations(p_group_id,p_user_id) THEN
    RAISE EXCEPTION 'Member has unsettled group debts/receivables'
      USING ERRCODE='42501';
  END IF;
  UPDATE public.trip_location_permissions lp SET enabled=false
    FROM public.trips t
    WHERE lp.trip_id=t.id AND t.group_id=p_group_id AND lp.user_id=p_user_id;
  UPDATE public.location_shares ls SET is_active=false
    FROM public.trips t
    WHERE ls.trip_id=t.id AND t.group_id=p_group_id AND ls.user_id=p_user_id;
  UPDATE public.trip_members tm SET membership_status='removed',removed_at=now()
    FROM public.trips t
    WHERE tm.trip_id=t.id AND t.group_id=p_group_id
      AND tm.user_id=p_user_id AND tm.membership_status='active';
  UPDATE public.group_members SET status='removed'
    WHERE group_id=p_group_id AND user_id=p_user_id;
  RETURN 'removed';
END;
$fn$;
REVOKE ALL ON FUNCTION public.anotara_remove_group_member(uuid,uuid)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.anotara_remove_group_member(uuid,uuid)
  TO authenticated;

-- Final defense: direct app DML stays disabled, despite older permissive RLS
-- policies that remain in the imported schema.
REVOKE INSERT,UPDATE,DELETE ON
  public.group_members,public.trip_members,
  public.expenses,public.expense_shares,public.settlements
FROM PUBLIC, anon, authenticated;

-- ============================================================================
-- SOURCE 5: PHASE 3: ITINERARY, CHAT, NOTIFICATIONS, LOCATION, SUBSCRIPTIONS
-- Original reviewed file: anotara_v2_phase3_core_LOCAL_ONLY.sql
-- ============================================================================
SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '120s';

DO $guard$
BEGIN
  IF to_regclass('public.member_availability') IS NULL
     OR to_regclass('public.group_messages') IS NULL
     OR to_regclass('public.trip_location_permissions') IS NULL
     OR to_regprocedure('public.anotara_confirm_repayment(uuid,uuid)') IS NULL
     OR to_regprocedure('public.anotara_set_trip_rsvp(uuid,text)') IS NULL THEN
    RAISE EXCEPTION 'Phase 3 requires the existing AnoTara V2 Foundation and Phase 2A/2B migrations';
  END IF;
END;
$guard$;

-- Reusable read-only predicates. SECURITY DEFINER avoids recursive RLS lookups.
-- Each predicate obtains the caller from the JWT; there is no spoofable user argument.
CREATE OR REPLACE FUNCTION public.anotara_p3_active_group_member(p_group uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = ''
AS $fn$
 SELECT (SELECT auth.uid()) IS NOT NULL AND EXISTS (
   SELECT 1 FROM public.group_members gm
   JOIN public.groups g ON g.id = gm.group_id
   WHERE gm.group_id = p_group AND gm.user_id = (SELECT auth.uid())
     AND gm.status = 'active' AND g.archived_at IS NULL
 );
$fn$;

CREATE OR REPLACE FUNCTION public.anotara_p3_manage_trip(p_trip uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = ''
AS $fn$
 SELECT (SELECT auth.uid()) IS NOT NULL AND EXISTS (
   SELECT 1 FROM public.trips t
   JOIN public.groups g ON g.id = t.group_id
   JOIN public.group_members gm ON gm.group_id = t.group_id
   WHERE t.id = p_trip AND t.status IN ('upcoming','ongoing')
     AND g.archived_at IS NULL AND gm.user_id = (SELECT auth.uid())
     AND gm.status = 'active' AND gm.role = 'organizer'
 );
$fn$;

CREATE OR REPLACE FUNCTION public.anotara_p3_active_trip_member(p_trip uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = ''
AS $fn$
 SELECT (SELECT auth.uid()) IS NOT NULL AND EXISTS (
   SELECT 1 FROM public.trips t
   JOIN public.trip_members tm ON tm.trip_id = t.id
   JOIN public.group_members gm ON gm.group_id = t.group_id AND gm.user_id = tm.user_id
   WHERE t.id = p_trip AND tm.user_id = (SELECT auth.uid())
     AND tm.membership_status = 'active' AND gm.status = 'active'
 );
$fn$;

REVOKE ALL ON FUNCTION public.anotara_p3_active_group_member(uuid),
  public.anotara_p3_manage_trip(uuid), public.anotara_p3_active_trip_member(uuid)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.anotara_p3_active_group_member(uuid),
  public.anotara_p3_manage_trip(uuid), public.anotara_p3_active_trip_member(uuid)
  TO authenticated;

-- ============================================================================
-- 1. ITINERARY. Group organizers manage items; trip members may read via RLS.
--    AI-generated drafts are NOT created by client RPCs and must be handled by
--    a trusted backend worker after validating external model output.
-- ============================================================================
REVOKE INSERT, UPDATE, DELETE ON public.itinerary_items,
  public.itinerary_generations, public.meeting_points FROM PUBLIC, anon, authenticated;
GRANT SELECT ON public.itinerary_items, public.itinerary_generations,
  public.meeting_points TO authenticated;

CREATE OR REPLACE FUNCTION public.anotara_add_itinerary_item(
  p_trip_id uuid, p_title text, p_starts_at timestamptz DEFAULT NULL,
  p_ends_at timestamptz DEFAULT NULL, p_location_name text DEFAULT NULL,
  p_description text DEFAULT NULL, p_category text DEFAULT NULL,
  p_address text DEFAULT NULL, p_latitude double precision DEFAULT NULL,
  p_longitude double precision DEFAULT NULL, p_estimated_cost numeric DEFAULT NULL,
  p_sort_order integer DEFAULT 0
) RETURNS uuid LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $fn$
DECLARE v_id uuid;
BEGIN
  IF NOT public.anotara_p3_manage_trip(p_trip_id) THEN
    RAISE EXCEPTION 'Only an active organizer may edit an upcoming or ongoing trip itinerary';
  END IF;
  IF p_title IS NULL OR length(btrim(p_title)) NOT BETWEEN 1 AND 160
     OR (p_starts_at IS NOT NULL AND p_ends_at IS NOT NULL AND p_ends_at < p_starts_at)
     OR (p_estimated_cost IS NOT NULL AND p_estimated_cost < 0)
     OR (p_latitude IS NOT NULL AND (p_latitude < -90 OR p_latitude > 90))
     OR (p_longitude IS NOT NULL AND (p_longitude < -180 OR p_longitude > 180)) THEN
    RAISE EXCEPTION 'Invalid itinerary item';
  END IF;
  INSERT INTO public.itinerary_items
    (trip_id,created_by,title,starts_at,ends_at,location_name,description,
     category,address,latitude,longitude,estimated_cost,sort_order)
  VALUES
    (p_trip_id,auth.uid(),btrim(p_title),p_starts_at,p_ends_at,p_location_name,
     p_description,p_category,p_address,p_latitude,p_longitude,p_estimated_cost,p_sort_order)
  RETURNING id INTO v_id;
  RETURN v_id;
END;
$fn$;

CREATE OR REPLACE FUNCTION public.anotara_update_itinerary_item(
  p_item_id uuid, p_title text, p_starts_at timestamptz DEFAULT NULL,
  p_ends_at timestamptz DEFAULT NULL, p_location_name text DEFAULT NULL,
  p_description text DEFAULT NULL, p_category text DEFAULT NULL,
  p_address text DEFAULT NULL, p_latitude double precision DEFAULT NULL,
  p_longitude double precision DEFAULT NULL, p_estimated_cost numeric DEFAULT NULL,
  p_sort_order integer DEFAULT 0
) RETURNS boolean LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $fn$
DECLARE v_trip uuid;
BEGIN
  SELECT trip_id INTO v_trip FROM public.itinerary_items WHERE id = p_item_id FOR UPDATE;
  IF v_trip IS NULL THEN RAISE EXCEPTION 'Itinerary item not found'; END IF;
  IF NOT public.anotara_p3_manage_trip(v_trip) THEN
    RAISE EXCEPTION 'Only an active organizer may edit an upcoming or ongoing trip itinerary';
  END IF;
  IF p_title IS NULL OR length(btrim(p_title)) NOT BETWEEN 1 AND 160
     OR (p_starts_at IS NOT NULL AND p_ends_at IS NOT NULL AND p_ends_at < p_starts_at)
     OR (p_estimated_cost IS NOT NULL AND p_estimated_cost < 0)
     OR (p_latitude IS NOT NULL AND (p_latitude < -90 OR p_latitude > 90))
     OR (p_longitude IS NOT NULL AND (p_longitude < -180 OR p_longitude > 180)) THEN
    RAISE EXCEPTION 'Invalid itinerary item';
  END IF;
  UPDATE public.itinerary_items SET title=btrim(p_title), starts_at=p_starts_at,
    ends_at=p_ends_at, location_name=p_location_name, description=p_description,
    category=p_category, address=p_address, latitude=p_latitude,
    longitude=p_longitude, estimated_cost=p_estimated_cost,
    sort_order=p_sort_order, updated_at=now()
  WHERE id=p_item_id;
  RETURN true;
END;
$fn$;

CREATE OR REPLACE FUNCTION public.anotara_delete_itinerary_item(p_item_id uuid)
RETURNS boolean LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $fn$
DECLARE v_trip uuid;
BEGIN
  SELECT trip_id INTO v_trip FROM public.itinerary_items WHERE id=p_item_id FOR UPDATE;
  IF v_trip IS NULL THEN RETURN false; END IF;
  IF NOT public.anotara_p3_manage_trip(v_trip) THEN
    RAISE EXCEPTION 'Only an active organizer may delete an open trip itinerary item';
  END IF;
  DELETE FROM public.itinerary_items WHERE id=p_item_id;
  RETURN true;
END;
$fn$;

-- Meeting points use existing table (separate from itinerary activities).
CREATE OR REPLACE FUNCTION public.anotara_add_meeting_point(
 p_trip_id uuid, p_name text, p_latitude double precision, p_longitude double precision,
 p_address text DEFAULT NULL, p_scheduled_at timestamptz DEFAULT NULL,
 p_notes text DEFAULT NULL
) RETURNS uuid LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $fn$
DECLARE v_id uuid;
BEGIN
 IF NOT public.anotara_p3_manage_trip(p_trip_id) THEN
   RAISE EXCEPTION 'Only an active organizer can set a meeting point for an open trip';
 END IF;
 IF p_name IS NULL OR length(btrim(p_name)) NOT BETWEEN 1 AND 160
    OR p_latitude IS NULL OR p_longitude IS NULL
    OR p_latitude NOT BETWEEN -90 AND 90 OR p_longitude NOT BETWEEN -180 AND 180 THEN
   RAISE EXCEPTION 'Invalid meeting point';
 END IF;
 INSERT INTO public.meeting_points
  (trip_id,created_by,name,address,latitude,longitude,scheduled_at,notes)
 VALUES (p_trip_id,auth.uid(),btrim(p_name),p_address,p_latitude,
  p_longitude,p_scheduled_at,p_notes) RETURNING id INTO v_id;
 RETURN v_id;
END;
$fn$;

CREATE OR REPLACE FUNCTION public.anotara_update_meeting_point(
 p_point_id uuid, p_name text, p_latitude double precision, p_longitude double precision,
 p_address text DEFAULT NULL, p_scheduled_at timestamptz DEFAULT NULL,
 p_notes text DEFAULT NULL
) RETURNS boolean LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $fn$
DECLARE v_trip uuid;
BEGIN
 SELECT trip_id INTO v_trip FROM public.meeting_points WHERE id=p_point_id FOR UPDATE;
 IF v_trip IS NULL THEN RETURN false; END IF;
 IF NOT public.anotara_p3_manage_trip(v_trip) THEN
   RAISE EXCEPTION 'Only an active organizer can edit an open trip meeting point';
 END IF;
 IF p_name IS NULL OR length(btrim(p_name)) NOT BETWEEN 1 AND 160
    OR p_latitude IS NULL OR p_longitude IS NULL
    OR p_latitude NOT BETWEEN -90 AND 90 OR p_longitude NOT BETWEEN -180 AND 180 THEN
   RAISE EXCEPTION 'Invalid meeting point';
 END IF;
 UPDATE public.meeting_points SET name=btrim(p_name),address=p_address,
   latitude=p_latitude,longitude=p_longitude,scheduled_at=p_scheduled_at,
   notes=p_notes,updated_at=now() WHERE id=p_point_id;
 RETURN true;
END;
$fn$;

CREATE OR REPLACE FUNCTION public.anotara_delete_meeting_point(p_point_id uuid)
RETURNS boolean LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $fn$
DECLARE v_trip uuid;
BEGIN
 SELECT trip_id INTO v_trip FROM public.meeting_points WHERE id=p_point_id FOR UPDATE;
 IF v_trip IS NULL THEN RETURN false; END IF;
 IF NOT public.anotara_p3_manage_trip(v_trip) THEN
   RAISE EXCEPTION 'Only an active organizer can delete an open trip meeting point';
 END IF;
 DELETE FROM public.meeting_points WHERE id=p_point_id;
 RETURN true;
END;
$fn$;

-- ============================================================================
-- 2. GROUP CHAT + IN-APP NOTIFICATIONS
--    Mobile push requires external FCM/APNs service; DB creates in-app rows.
-- ============================================================================
DROP POLICY IF EXISTS anotara_group_messages_read ON public.group_messages;
CREATE POLICY anotara_group_messages_read ON public.group_messages
  FOR SELECT TO authenticated
  USING (public.anotara_p3_active_group_member(group_id));
DROP POLICY IF EXISTS anotara_group_messages_send ON public.group_messages;
REVOKE INSERT,UPDATE,DELETE ON public.group_messages FROM PUBLIC,anon,authenticated;
GRANT SELECT ON public.group_messages TO authenticated;

CREATE OR REPLACE FUNCTION public.anotara_send_group_message(p_group_id uuid, p_message_text text)
RETURNS uuid LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $fn$
DECLARE v_id uuid; v_uid uuid := auth.uid();
BEGIN
 IF v_uid IS NULL OR NOT public.anotara_p3_active_group_member(p_group_id) THEN
   RAISE EXCEPTION 'An active group member is required to send messages';
 END IF;
 IF p_message_text IS NULL OR length(btrim(p_message_text)) NOT BETWEEN 1 AND 5000 THEN
   RAISE EXCEPTION 'Message must contain 1 to 5000 characters';
 END IF;
 PERFORM pg_advisory_xact_lock(hashtextextended(v_uid::text || p_group_id::text, 71));
 IF (SELECT count(*) FROM public.group_messages m
     WHERE m.group_id=p_group_id AND m.sender_id=v_uid
       AND m.created_at > now() - interval '60 seconds') >= 15 THEN
   RAISE EXCEPTION 'Too many messages; try again later';
 END IF;
 INSERT INTO public.group_messages(group_id,sender_id,message_text)
 VALUES(p_group_id,v_uid,btrim(p_message_text)) RETURNING id INTO v_id;
 RETURN v_id;
END;
$fn$;

-- Automatic in-app notifications for addressed invitations and added trip members.
-- Keep content generic and exclude secrets, invitation codes and private locations.
CREATE OR REPLACE FUNCTION public.anotara_p3_invitation_notify()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $fn$
BEGIN
 INSERT INTO public.notifications(user_id,group_id,type,title,body,data)
 VALUES(NEW.invitee_user_id,NEW.group_id,'group_invitation','New group invitation',
        'You have been invited to join a group.',
        pg_catalog.jsonb_build_object('invitation_id',NEW.id));
 RETURN NEW;
END;
$fn$;
DROP TRIGGER IF EXISTS anotara_p3_invitation_notification ON public.group_invitations;
CREATE TRIGGER anotara_p3_invitation_notification
 AFTER INSERT ON public.group_invitations FOR EACH ROW
 EXECUTE FUNCTION public.anotara_p3_invitation_notify();

CREATE OR REPLACE FUNCTION public.anotara_p3_trip_member_notify()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $fn$
BEGIN
 IF NEW.user_id <> (SELECT t.created_by FROM public.trips t WHERE t.id=NEW.trip_id) THEN
   INSERT INTO public.notifications(user_id,group_id,trip_id,type,title,body,data)
   SELECT NEW.user_id,t.group_id,t.id,'trip_added','Added to a trip',
          'You have been added to a trip.',
          pg_catalog.jsonb_build_object('trip_id',t.id)
   FROM public.trips t WHERE t.id=NEW.trip_id;
 END IF;
 RETURN NEW;
END;
$fn$;
DROP TRIGGER IF EXISTS anotara_p3_trip_member_notification ON public.trip_members;
CREATE TRIGGER anotara_p3_trip_member_notification
 AFTER INSERT ON public.trip_members FOR EACH ROW
 EXECUTE FUNCTION public.anotara_p3_trip_member_notify();

-- Group chat also creates a generic in-app notification for other active members.
-- Message text is deliberately NOT copied into notification body (privacy).
CREATE OR REPLACE FUNCTION public.anotara_p3_message_notify()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $fn$
BEGIN
 INSERT INTO public.notifications(user_id,group_id,type,title,body,data)
 SELECT gm.user_id,NEW.group_id,'group_message','New group message',
   'A new message was posted in your group.',
   pg_catalog.jsonb_build_object('message_id',NEW.id)
 FROM public.group_members gm
 WHERE gm.group_id=NEW.group_id AND gm.status='active'
   AND gm.user_id<>NEW.sender_id;
 RETURN NEW;
END;
$fn$;
DROP TRIGGER IF EXISTS anotara_p3_message_notification ON public.group_messages;
CREATE TRIGGER anotara_p3_message_notification
 AFTER INSERT ON public.group_messages FOR EACH ROW
 EXECUTE FUNCTION public.anotara_p3_message_notify();

CREATE OR REPLACE FUNCTION public.anotara_mark_notifications_read(p_ids uuid[] DEFAULT NULL)
RETURNS integer LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $fn$
DECLARE v_count integer;
BEGIN
 IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Sign-in required'; END IF;
 UPDATE public.notifications n SET read_at=now()
 WHERE n.user_id=auth.uid() AND n.read_at IS NULL
   AND (p_ids IS NULL OR n.id=ANY(p_ids));
 GET DIAGNOSTICS v_count = ROW_COUNT;
 RETURN v_count;
END;
$fn$;

REVOKE INSERT,DELETE,UPDATE ON public.notifications FROM PUBLIC,anon,authenticated;
GRANT SELECT,UPDATE(read_at) ON public.notifications TO authenticated;

-- ============================================================================
-- 3. LIVE LOCATION: explicit opt-in, Going only, Ongoing only, short TTL.
--    No location history is exposed through client SELECT. Retention and mobile
--    background permissions are separate production tasks.
-- ============================================================================
DO $check$
BEGIN
 IF EXISTS (SELECT 1 FROM public.location_shares
   GROUP BY trip_id,user_id HAVING count(*)>1) THEN
   RAISE EXCEPTION 'Existing location_shares contains duplicate trip/user rows; resolve before Phase 3';
 END IF;
END;
$check$;
CREATE UNIQUE INDEX IF NOT EXISTS anotara_p3_one_location_per_trip_user
  ON public.location_shares(trip_id,user_id);

CREATE OR REPLACE FUNCTION public.anotara_p3_can_read_location(
 p_trip_id uuid, p_sharer_id uuid
) RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = ''
AS $fn$
 SELECT (SELECT auth.uid()) IS NOT NULL AND EXISTS (
   SELECT 1
   FROM public.trips t
   JOIN public.trip_members viewer ON viewer.trip_id=t.id
     AND viewer.user_id=(SELECT auth.uid())
   JOIN public.group_members vg ON vg.group_id=t.group_id
     AND vg.user_id=viewer.user_id
   JOIN public.trip_members sharer ON sharer.trip_id=t.id
     AND sharer.user_id=p_sharer_id
   JOIN public.group_members sg ON sg.group_id=t.group_id
     AND sg.user_id=p_sharer_id
   JOIN public.trip_location_permissions permission ON permission.trip_id=t.id
     AND permission.user_id=p_sharer_id
   WHERE t.id=p_trip_id AND t.status='ongoing'
     AND viewer.membership_status='active' AND viewer.response='going'
     AND vg.status='active'
     AND sharer.membership_status='active' AND sharer.response='going'
     AND sg.status='active' AND permission.enabled=true
 );
$fn$;
REVOKE ALL ON FUNCTION public.anotara_p3_can_read_location(uuid,uuid)
  FROM PUBLIC,anon,authenticated;
GRANT EXECUTE ON FUNCTION public.anotara_p3_can_read_location(uuid,uuid)
  TO authenticated;

CREATE OR REPLACE FUNCTION public.anotara_set_location_consent(
 p_trip_id uuid,p_enabled boolean
) RETURNS boolean LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $fn$
DECLARE v_uid uuid := auth.uid(); v_allowed boolean;
BEGIN
 IF v_uid IS NULL OR p_enabled IS NULL THEN RAISE EXCEPTION 'Invalid consent request'; END IF;
 SELECT EXISTS(
   SELECT 1 FROM public.trips t
   JOIN public.trip_members tm ON tm.trip_id=t.id AND tm.user_id=v_uid
   JOIN public.group_members gm ON gm.group_id=t.group_id AND gm.user_id=v_uid
   WHERE t.id=p_trip_id AND tm.membership_status='active'
     AND tm.response='going' AND gm.status='active'
     AND t.status IN ('upcoming','ongoing')
 ) INTO v_allowed;
 IF p_enabled AND NOT v_allowed THEN
   RAISE EXCEPTION 'Location consent can be enabled only by an active Going participant on an open trip';
 END IF;
 IF NOT p_enabled AND NOT EXISTS(
    SELECT 1 FROM public.trip_members WHERE trip_id=p_trip_id AND user_id=v_uid
 ) THEN RAISE EXCEPTION 'Trip membership not found'; END IF;
 INSERT INTO public.trip_location_permissions(trip_id,user_id,enabled,updated_at)
 VALUES (p_trip_id,v_uid,p_enabled,now())
 ON CONFLICT(trip_id,user_id) DO UPDATE
  SET enabled=EXCLUDED.enabled,updated_at=now();
 IF NOT p_enabled THEN
   UPDATE public.location_shares SET is_active=false,expires_at=now(),updated_at=now()
   WHERE trip_id=p_trip_id AND user_id=v_uid;
 END IF;
 RETURN p_enabled;
END;
$fn$;

CREATE OR REPLACE FUNCTION public.anotara_publish_live_location(
 p_trip_id uuid, p_latitude double precision, p_longitude double precision,
 p_accuracy_meters numeric DEFAULT NULL
) RETURNS uuid LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $fn$
DECLARE v_uid uuid := auth.uid(); v_id uuid;
BEGIN
 IF v_uid IS NULL OR p_latitude IS NULL OR p_longitude IS NULL
   OR p_latitude NOT BETWEEN -90 AND 90 OR p_longitude NOT BETWEEN -180 AND 180
   OR (p_accuracy_meters IS NOT NULL AND
      (p_accuracy_meters < 0 OR p_accuracy_meters > 100000)) THEN
   RAISE EXCEPTION 'Invalid live location';
 END IF;
 IF NOT EXISTS (
   SELECT 1 FROM public.trips t
   JOIN public.trip_members tm ON tm.trip_id=t.id AND tm.user_id=v_uid
   JOIN public.group_members gm ON gm.group_id=t.group_id AND gm.user_id=v_uid
   JOIN public.trip_location_permissions lp ON lp.trip_id=t.id AND lp.user_id=v_uid
   WHERE t.id=p_trip_id AND t.status='ongoing'
     AND tm.membership_status='active' AND tm.response='going'
     AND gm.status='active' AND lp.enabled=true
 ) THEN RAISE EXCEPTION 'Live location requires an ongoing trip, Going RSVP and explicit consent';
 END IF;
 INSERT INTO public.location_shares
  (trip_id,user_id,is_active,latitude,longitude,accuracy_meters,captured_at,expires_at)
 VALUES (p_trip_id,v_uid,true,p_latitude,p_longitude,p_accuracy_meters,now(),now()+interval '2 minutes')
 ON CONFLICT(trip_id,user_id) DO UPDATE SET
  is_active=true, latitude=EXCLUDED.latitude,longitude=EXCLUDED.longitude,
  accuracy_meters=EXCLUDED.accuracy_meters,captured_at=now(),
  expires_at=now()+interval '2 minutes',updated_at=now()
 RETURNING id INTO v_id;
 RETURN v_id;
END;
$fn$;

DROP POLICY IF EXISTS locations_select_trip_members ON public.location_shares;
DROP POLICY IF EXISTS anotara_location_phase1_private ON public.location_shares;
DROP POLICY IF EXISTS anotara_p3_live_location_read ON public.location_shares;
CREATE POLICY anotara_p3_live_location_read ON public.location_shares
 FOR SELECT TO authenticated
 USING (is_active=true AND expires_at > now()
        AND public.anotara_p3_can_read_location(trip_id,user_id));
REVOKE INSERT,UPDATE,DELETE ON public.location_shares FROM PUBLIC,anon,authenticated;
GRANT SELECT ON public.location_shares TO authenticated;
REVOKE INSERT,UPDATE,DELETE ON public.trip_location_permissions FROM PUBLIC,anon,authenticated;
GRANT SELECT ON public.trip_location_permissions TO authenticated;

-- Trip status transitions are organizer-controlled. A production scheduler may
-- later automate date-based transitions, but it must call trusted transition logic.
CREATE OR REPLACE FUNCTION public.anotara_change_trip_status(
 p_trip_id uuid, p_new_status text, p_cancellation_reason text DEFAULT NULL
) RETURNS text LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $fn$
DECLARE v_old text;
BEGIN
 SELECT status INTO v_old FROM public.trips WHERE id=p_trip_id FOR UPDATE;
 IF v_old IS NULL THEN RAISE EXCEPTION 'Trip not found'; END IF;
 IF NOT public.anotara_p3_manage_trip(p_trip_id) THEN
   RAISE EXCEPTION 'Only an active organizer can change an open trip status';
 END IF;
 IF NOT (
   (v_old='upcoming' AND p_new_status IN ('ongoing','cancelled'))
    OR (v_old='ongoing' AND p_new_status IN ('completed','cancelled'))
 ) THEN RAISE EXCEPTION 'Invalid trip status transition'; END IF;
 IF p_cancellation_reason IS NOT NULL AND length(p_cancellation_reason)>500 THEN
   RAISE EXCEPTION 'Cancellation reason is too long';
 END IF;
 UPDATE public.trips SET status=p_new_status,
  cancelled_at=CASE WHEN p_new_status='cancelled' THEN now() ELSE NULL END,
  cancelled_by=CASE WHEN p_new_status='cancelled' THEN auth.uid() ELSE NULL END,
  cancellation_reason=CASE WHEN p_new_status='cancelled' THEN p_cancellation_reason ELSE NULL END,
  completed_at=CASE WHEN p_new_status='completed' THEN now() ELSE NULL END,
  updated_at=now()
 WHERE id=p_trip_id;
 IF p_new_status IN ('completed','cancelled') THEN
   UPDATE public.trip_location_permissions SET enabled=false,updated_at=now()
   WHERE trip_id=p_trip_id;
   UPDATE public.location_shares SET is_active=false,expires_at=now(),updated_at=now()
   WHERE trip_id=p_trip_id;
 END IF;
 RETURN p_new_status;
END;
$fn$;

-- ============================================================================
-- 4. SUBSCRIPTIONS & AI REQUEST TRACKING
--   Reads current paid entitlement if verified by a trusted backend.
--   Does NOT charge users, activate subscriptions or call an AI model.
-- ============================================================================
REVOKE INSERT,UPDATE,DELETE ON public.subscriptions,
  public.subscription_plans,public.usage_events FROM PUBLIC,anon,authenticated;
GRANT SELECT ON public.subscription_plans,public.subscriptions,
  public.usage_events TO authenticated;

CREATE OR REPLACE FUNCTION public.anotara_current_entitlements()
RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = ''
AS $fn$
DECLARE v_uid uuid := auth.uid(); v_plan public.subscription_plans%ROWTYPE;
        v_plan_id text; v_period_end timestamptz;
BEGIN
 IF v_uid IS NULL THEN RAISE EXCEPTION 'Sign-in required'; END IF;
 SELECT p.id,s.current_period_end INTO v_plan_id,v_period_end
 FROM public.subscriptions s JOIN public.subscription_plans p ON p.id=s.plan_id
 WHERE s.user_id=v_uid AND s.status IN ('active','trialing')
   AND p.is_active=true AND s.current_period_end > now()
   AND (s.current_period_start IS NULL OR s.current_period_start <= now())
 LIMIT 1;
 IF v_plan_id IS NULL THEN
   v_plan_id := 'free';
   v_period_end := NULL;
 END IF;
 SELECT * INTO v_plan FROM public.subscription_plans WHERE id=v_plan_id;
 IF v_plan.id IS NULL THEN RAISE EXCEPTION 'Free plan is missing'; END IF;
 RETURN pg_catalog.jsonb_build_object(
   'plan_id',v_plan.id, 'name',v_plan.name,
   'max_groups',v_plan.max_groups,
   'max_members_per_group',v_plan.max_members_per_group,
   'max_active_trips',v_plan.max_active_trips,
   'ai_generations_limit',v_plan.ai_generations_per_month,
   'features',v_plan.features,'period_end',v_period_end
 );
END;
$fn$;

CREATE OR REPLACE FUNCTION public.anotara_request_itinerary_generation(
 p_trip_id uuid,p_input_data jsonb DEFAULT '{}'::jsonb
) RETURNS uuid LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $fn$
DECLARE v_uid uuid := auth.uid(); v_entitlements jsonb; v_limit integer;
        v_count integer;v_window timestamptz;v_id uuid;
        v_period_end timestamptz;
BEGIN
 IF v_uid IS NULL OR NOT public.anotara_p3_manage_trip(p_trip_id) THEN
   RAISE EXCEPTION 'Only an active organizer may request an AI itinerary for an open trip';
 END IF;
 IF p_input_data IS NULL OR pg_catalog.jsonb_typeof(p_input_data)<>'object'
    OR length(p_input_data::text)>16000 THEN RAISE EXCEPTION 'Invalid AI request'; END IF;
 -- Serialize usage checks by user to avoid simultaneous quota overruns.
 PERFORM pg_advisory_xact_lock(hashtextextended(v_uid::text, 97));
 v_entitlements := public.anotara_current_entitlements();
 v_limit := (v_entitlements->>'ai_generations_limit')::integer;
 IF v_limit IS NULL THEN RAISE EXCEPTION 'AI quota is not configured'; END IF;
 -- Trip Pass uses its 30-day subscription window; other plans use calendar month.
 IF v_entitlements->>'plan_id'='trip_pass' THEN
   SELECT s.current_period_start INTO v_window FROM public.subscriptions s
    WHERE s.user_id=v_uid AND s.plan_id='trip_pass'
      AND s.status IN ('active','trialing') AND s.current_period_end>now();
   IF v_window IS NULL THEN RAISE EXCEPTION 'Trip Pass period is not configured'; END IF;
 ELSE
   v_window := date_trunc('month',now() AT TIME ZONE 'Asia/Manila')
                 AT TIME ZONE 'Asia/Manila';
 END IF;
 SELECT count(*) INTO v_count FROM public.usage_events ue
 WHERE ue.user_id=v_uid AND ue.event_type='ai_itinerary_generation'
   AND ue.created_at>=v_window;
 IF v_count>=v_limit THEN RAISE EXCEPTION 'AI generation limit reached for this plan period'; END IF;
 INSERT INTO public.itinerary_generations(trip_id,requested_by,status,input_data)
 VALUES(p_trip_id,v_uid,'draft',p_input_data) RETURNING id INTO v_id;
 INSERT INTO public.usage_events(user_id,trip_id,event_type,metadata)
 VALUES(v_uid,p_trip_id,'ai_itinerary_generation',
        pg_catalog.jsonb_build_object('request_id',v_id,'state','queued'));
 RETURN v_id;
END;
$fn$;

-- All app-writable SECURITY DEFINER RPCs are callable only by signed-in users.
DO $rpc$
DECLARE f record;
BEGIN
 FOR f IN SELECT p.oid::regprocedure AS signature
          FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
          WHERE n.nspname='public' AND p.proname IN (
            'anotara_add_itinerary_item','anotara_update_itinerary_item',
            'anotara_delete_itinerary_item','anotara_add_meeting_point',
            'anotara_update_meeting_point','anotara_delete_meeting_point',
            'anotara_send_group_message','anotara_mark_notifications_read',
            'anotara_set_location_consent','anotara_publish_live_location',
            'anotara_current_entitlements','anotara_request_itinerary_generation',
            'anotara_change_trip_status'
          )
 LOOP
   EXECUTE format('REVOKE ALL ON FUNCTION %s FROM PUBLIC,anon,authenticated', f.signature);
   EXECUTE format('GRANT EXECUTE ON FUNCTION %s TO authenticated', f.signature);
 END LOOP;
END;
$rpc$;
REVOKE ALL ON FUNCTION public.anotara_p3_invitation_notify(),
 public.anotara_p3_trip_member_notify(),
 public.anotara_p3_message_notify() FROM PUBLIC,anon,authenticated;

-- Final postconditions. Any missing object fails the transaction before commit.
DO $deployment_verify$
BEGIN
 IF to_regclass('public.member_availability') IS NULL
   OR to_regclass('public.group_invite_codes') IS NULL
   OR to_regclass('public.group_messages') IS NULL
   OR to_regclass('public.trip_location_permissions') IS NULL
   OR to_regclass('public.anotara_code_redeem_attempts') IS NULL
   OR to_regprocedure('public.anotara_confirm_repayment(uuid,uuid)') IS NULL
   OR to_regprocedure('public.anotara_redeem_group_code(text)') IS NULL
   OR to_regprocedure('public.anotara_change_trip_status(uuid,text,text)') IS NULL
 THEN RAISE EXCEPTION 'STOP: missing required V2 objects'; END IF;
 IF (SELECT count(*) FROM public.subscription_plans)<>3 THEN
   RAISE EXCEPTION 'STOP: subscription plans were not preserved'; END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_trigger
   WHERE tgname='on_auth_user_created'
     AND tgrelid='auth.users'::regclass AND NOT tgisinternal)
 THEN RAISE EXCEPTION 'STOP: signup trigger missing'; END IF;
END;
$deployment_verify$;

COMMIT;
NOTIFY pgrst, 'reload schema';
-- One successful COMMIT means all five sections were applied atomically.
