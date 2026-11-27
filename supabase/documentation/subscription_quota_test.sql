-- Manual test for 20261127091612_subscription_quota_enforcement.sql
-- -----------------------------------------------------------------------------
-- HOW TO USE: run the migration first, then paste this WHOLE file into the
-- Supabase SQL Editor (staging / local project) and press Run.
--   * Every check prints "PASS: ..." as a NOTICE.
--   * Any failure stops the script with "TEST FAILED: ...".
--   * The last line is ROLLBACK, so the fake users, groups and trips created
--     here are thrown away. Nothing is saved.
--
-- The script pretends to be real signed-in users by switching to the
-- `authenticated` role and setting the JWT claims, exactly like an API call
-- from the app. That proves the limits hold even when calling the backend
-- directly.
-- -----------------------------------------------------------------------------
BEGIN;

-- 1. Fake users (as the database owner, before switching role).
--    a1 = owner on the Free plan, b1..b30 = friends who try to join.
INSERT INTO auth.users (id, email, raw_user_meta_data, aud, role)
SELECT format('00000000-0000-0000-0000-%s', lpad(to_hex(n), 12, '0'))::uuid,
       format('quota-test-%s@example.invalid', n), '{}'::jsonb,
       'authenticated', 'authenticated'
FROM generate_series(161, 161 + 30) AS n;   -- 161 = 0xa1

-- Small helper so each check reads clearly. Temporary: gone after ROLLBACK.
CREATE FUNCTION pg_temp.act_as(p_n integer) RETURNS void LANGUAGE sql AS $$
  SELECT set_config('request.jwt.claims',
    pg_catalog.json_build_object(
      'sub', format('00000000-0000-0000-0000-%s', lpad(to_hex(p_n), 12, '0')),
      'role', 'authenticated')::text, true);
$$;
GRANT EXECUTE ON FUNCTION pg_temp.act_as(integer) TO authenticated;

SET LOCAL ROLE authenticated;
SELECT pg_temp.act_as(161);

-- 2. Plan must be Free for a user with no subscription.
DO $t$
DECLARE u jsonb := public.anotara_get_subscription_usage();
BEGIN
  IF u->>'plan_id' <> 'free' THEN
    RAISE EXCEPTION 'TEST FAILED: expected free plan, got %', u->>'plan_id';
  END IF;
  RAISE NOTICE 'PASS: user without subscription is on Free. Usage: %', u;
END $t$;

-- 3. GROUPS: create up to the limit, then the next one must be blocked.
DO $t$
DECLARE
  v_me uuid := auth.uid();
  v_limit integer := (public.anotara_get_subscription_usage()->'groups'->>'limit')::integer;
  v_hint text;
BEGIN
  FOR i IN 1..v_limit LOOP
    INSERT INTO public.groups(name, created_by) VALUES ('Quota group ' || i, v_me);
  END LOOP;
  BEGIN
    INSERT INTO public.groups(name, created_by) VALUES ('One too many', v_me);
  EXCEPTION WHEN OTHERS THEN
    GET STACKED DIAGNOSTICS v_hint = PG_EXCEPTION_HINT;
  END;
  IF v_hint IS DISTINCT FROM 'quota_exceeded:groups' THEN
    RAISE EXCEPTION 'TEST FAILED: group % was not blocked', v_limit + 1;
  END IF;
  IF (SELECT count(*) FROM public.groups WHERE created_by = v_me) <> v_limit THEN
    RAISE EXCEPTION 'TEST FAILED: existing groups changed';
  END IF;
  RAISE NOTICE 'PASS: group limit (%) enforced, existing groups kept', v_limit;
END $t$;

-- 4. ACTIVE TRIPS: fill the limit, next is blocked; cancelling one frees a slot.
DO $t$
DECLARE
  v_me uuid := auth.uid();
  v_group uuid := (SELECT id FROM public.groups WHERE created_by = auth.uid() LIMIT 1);
  v_limit integer := (public.anotara_get_subscription_usage()->'active_trips'->>'limit')::integer;
  v_trip uuid;
  v_hint text;
BEGIN
  FOR i IN 1..v_limit LOOP
    INSERT INTO public.trips(group_id, created_by, name)
    VALUES (v_group, v_me, 'Quota trip ' || i) RETURNING id INTO v_trip;
  END LOOP;
  BEGIN
    INSERT INTO public.trips(group_id, created_by, name) VALUES (v_group, v_me, 'Too many');
  EXCEPTION WHEN OTHERS THEN
    GET STACKED DIAGNOSTICS v_hint = PG_EXCEPTION_HINT;
  END;
  IF v_hint IS DISTINCT FROM 'quota_exceeded:active_trips' THEN
    RAISE EXCEPTION 'TEST FAILED: active trip % was not blocked', v_limit + 1;
  END IF;
  RAISE NOTICE 'PASS: active trip limit (%) enforced', v_limit;

  PERFORM public.anotara_change_trip_status(v_trip, 'cancelled', 'quota test');
  INSERT INTO public.trips(group_id, created_by, name) VALUES (v_group, v_me, 'After cancel');
  IF (SELECT count(*) FROM public.trips WHERE created_by = v_me) <> v_limit + 1 THEN
    RAISE EXCEPTION 'TEST FAILED: cancelled trip should be kept';
  END IF;
  RAISE NOTICE 'PASS: cancelling a trip frees a slot and keeps the cancelled trip';
END $t$;

-- 5. USAGE RECORDED: group_created / trip_created events exist.
DO $t$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.usage_events
                 WHERE user_id = auth.uid() AND event_type = 'group_created')
     OR NOT EXISTS (SELECT 1 FROM public.usage_events
                 WHERE user_id = auth.uid() AND event_type = 'trip_created') THEN
    RAISE EXCEPTION 'TEST FAILED: usage events were not recorded';
  END IF;
  RAISE NOTICE 'PASS: group/trip creation recorded in usage_events';
END $t$;

-- 6. AI GENERATIONS: request up to the limit, next is blocked.
DO $t$
DECLARE
  v_trip uuid := (SELECT id FROM public.trips
                  WHERE created_by = auth.uid() AND status = 'upcoming' LIMIT 1);
  v_limit integer := (public.anotara_get_subscription_usage()->'ai_generations'->>'limit')::integer;
  v_hint text;
BEGIN
  FOR i IN 1..v_limit LOOP
    PERFORM public.anotara_request_itinerary_generation(v_trip, '{}'::jsonb);
  END LOOP;
  BEGIN
    PERFORM public.anotara_request_itinerary_generation(v_trip, '{}'::jsonb);
  EXCEPTION WHEN OTHERS THEN
    GET STACKED DIAGNOSTICS v_hint = PG_EXCEPTION_HINT;
  END;
  IF v_hint IS DISTINCT FROM 'quota_exceeded:ai_generations' THEN
    RAISE EXCEPTION 'TEST FAILED: AI request % was not blocked', v_limit + 1;
  END IF;
  RAISE NOTICE 'PASS: AI generation limit (%) enforced', v_limit;
END $t$;

-- 7. MEMBERS PER GROUP: friends join by code until the group is full.
DO $t$
DECLARE
  v_group uuid := (SELECT id FROM public.groups WHERE created_by = auth.uid() LIMIT 1);
  v_limit integer := (public.anotara_get_subscription_usage()->'members_per_group'->>'limit')::integer;
  v_code text;
  v_hint text;
  v_friend integer := 162;
BEGIN
  IF v_limit > 30 THEN
    RAISE EXCEPTION 'TEST SETUP: limit % is larger than the fake users created', v_limit;
  END IF;
  SELECT invite_code INTO v_code FROM public.anotara_rotate_group_invite_code(v_group);

  -- The owner is member #1, so v_limit - 1 friends fit.
  FOR i IN 1..(v_limit - 1) LOOP
    PERFORM pg_temp.act_as(v_friend);
    IF NOT (public.anotara_redeem_group_code(v_code)->>'success')::boolean THEN
      RAISE EXCEPTION 'TEST FAILED: friend % could not join', i;
    END IF;
    v_friend := v_friend + 1;
  END LOOP;

  PERFORM pg_temp.act_as(v_friend);
  BEGIN
    PERFORM public.anotara_redeem_group_code(v_code);
  EXCEPTION WHEN OTHERS THEN
    GET STACKED DIAGNOSTICS v_hint = PG_EXCEPTION_HINT;
  END;
  IF v_hint IS DISTINCT FROM 'quota_exceeded:members_per_group' THEN
    RAISE EXCEPTION 'TEST FAILED: member % was not blocked', v_limit + 1;
  END IF;

  PERFORM pg_temp.act_as(161);
  IF (SELECT (g->>'used')::integer
      FROM jsonb_array_elements(
        public.anotara_get_subscription_usage()->'members_per_group'->'groups') AS g
      WHERE g->>'group_id' = v_group::text) IS DISTINCT FROM v_limit THEN
    RAISE EXCEPTION 'TEST FAILED: usage screen member count is wrong';
  END IF;
  RAISE NOTICE 'PASS: member limit (%) enforced, existing members kept', v_limit;
END $t$;

-- 8. NO BYPASS: the app cannot fake usage, award itself a plan, or read
--    another user's plan.
DO $t$
BEGIN
  BEGIN
    DELETE FROM public.usage_events WHERE user_id = auth.uid();
    RAISE EXCEPTION 'TEST FAILED: client deleted usage events';
  EXCEPTION WHEN insufficient_privilege THEN NULL;
  END;
  BEGIN
    INSERT INTO public.subscriptions(user_id, plan_id, current_period_end)
    VALUES (auth.uid(), 'plus', now() + interval '30 days');
    RAISE EXCEPTION 'TEST FAILED: client gave itself a subscription';
  EXCEPTION WHEN insufficient_privilege THEN NULL;
  END;
  BEGIN
    PERFORM public.anotara_entitlements_for(auth.uid());
    RAISE EXCEPTION 'TEST FAILED: internal entitlement lookup is callable';
  EXCEPTION WHEN insufficient_privilege THEN NULL;
  END;
  RAISE NOTICE 'PASS: usage, subscriptions and internal helpers are protected';
END $t$;

-- Final usage snapshot (what the Manage Subscription screen receives).
SELECT public.anotara_get_subscription_usage() AS usage_for_manage_subscription_screen;

ROLLBACK;
