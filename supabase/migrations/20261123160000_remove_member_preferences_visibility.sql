-- AnoTara V2 follow-up: remove unused member_preferences.visibility.
-- Intended for the EXISTING V2 schema (after the 2026-11-23 V2 deployment).
-- Historical V1/V2 migrations must remain unchanged; apply this forward migration ONCE.
--
-- Privacy choice: individual preference rows become self-readable only.
-- Other members may still receive specifically shared data via separate
-- SECURITY DEFINER functions (e.g., get_group_usual_free_days); review those
-- separately if group-wide preference sharing is not desired.
--
-- Scope: no profile, preference-row, Auth, or subscription records are deleted.
--       Values previously stored in the visibility COLUMN will be lost.
-- Run first on local staging; back up and review dependencies before production.

BEGIN;
SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '30s';

DO $guard$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'member_preferences'
      AND column_name = 'visibility'
  ) THEN
    RAISE EXCEPTION 'Expected member_preferences.visibility not found; review current schema.';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE n.nspname = 'public'
      AND c.relname = 'member_preferences'
      AND c.relrowsecurity
  ) THEN
    RAISE EXCEPTION 'RLS is not enabled for member_preferences; stop for review.';
  END IF;

  -- Fail closed if a later policy was added after the original V2 deployment.
  IF EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'member_preferences'
      AND policyname <> 'preferences_select_own_or_group'
      AND (
        cmd IN ('SELECT', 'ALL')
        OR coalesce(qual, '') ILIKE '%visibility%'
        OR coalesce(with_check, '') ILIKE '%visibility%'
      )
  ) THEN
    RAISE EXCEPTION 'Additional preference visibility/SELECT policies exist; review before dropping visibility.';
  END IF;
END;
$guard$;

-- The V2 SELECT policy referenced the column; replace it with an own-row rule.
DROP POLICY IF EXISTS preferences_select_own_or_group
  ON public.member_preferences;

CREATE POLICY preferences_select_own
  ON public.member_preferences
  FOR SELECT TO authenticated
  USING (user_id = (SELECT auth.uid()));

-- Default RESTRICT behavior: fail safely if an unexpected view or other
-- dependent object still references visibility. Do NOT add CASCADE.
ALTER TABLE public.member_preferences
  DROP COLUMN visibility RESTRICT;

COMMIT;
