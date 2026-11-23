-- Group chat API additions: efficient thread summaries, scoped read receipts,
-- and Realtime delivery for persisted messages.

CREATE OR REPLACE FUNCTION public.anotara_get_group_chat_threads()
RETURNS TABLE (
  group_id uuid,
  group_name text,
  last_message text,
  last_message_at timestamptz,
  unread_count bigint
)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $function$
  SELECT
    g.id,
    g.name,
    latest.message_text,
    latest.created_at,
    (
      SELECT count(*)
      FROM public.notifications AS n
      WHERE n.user_id = (SELECT auth.uid())
        AND n.group_id = g.id
        AND n.type = 'group_message'
        AND n.read_at IS NULL
    )
  FROM public.groups AS g
  JOIN public.group_members AS gm ON gm.group_id = g.id
  LEFT JOIN LATERAL (
    SELECT m.message_text, m.created_at
    FROM public.group_messages AS m
    WHERE m.group_id = g.id
    ORDER BY m.created_at DESC
    LIMIT 1
  ) AS latest ON true
  WHERE (SELECT auth.uid()) IS NOT NULL
    AND gm.user_id = (SELECT auth.uid())
    AND gm.status = 'active'
    AND g.archived_at IS NULL
  ORDER BY latest.created_at DESC NULLS LAST, g.created_at DESC, g.id;
$function$;

REVOKE ALL ON FUNCTION public.anotara_get_group_chat_threads()
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.anotara_get_group_chat_threads()
  TO authenticated;

CREATE OR REPLACE FUNCTION public.anotara_mark_group_chat_read(p_group_id uuid)
RETURNS integer
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $function$
DECLARE
  v_count integer;
BEGIN
  IF auth.uid() IS NULL
     OR NOT public.anotara_p3_active_group_member(p_group_id) THEN
    RAISE EXCEPTION 'An active group member is required';
  END IF;

  UPDATE public.notifications AS n
  SET read_at = now()
  WHERE n.user_id = (SELECT auth.uid())
    AND n.group_id = p_group_id
    AND n.type = 'group_message'
    AND n.read_at IS NULL;

  GET DIAGNOSTICS v_count = ROW_COUNT;
  RETURN v_count;
END;
$function$;

REVOKE ALL ON FUNCTION public.anotara_mark_group_chat_read(uuid)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.anotara_mark_group_chat_read(uuid)
  TO authenticated;

DO $publication$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_catalog.pg_publication
    WHERE pubname = 'supabase_realtime'
  ) THEN
    RAISE EXCEPTION 'Supabase Realtime publication is missing';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_catalog.pg_publication_tables
    WHERE pubname = 'supabase_realtime'
      AND schemaname = 'public'
      AND tablename = 'group_messages'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.group_messages;
  END IF;
END;
$publication$;
