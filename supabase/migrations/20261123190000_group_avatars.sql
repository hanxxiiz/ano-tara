-- Public group images, uploaded and managed only by group organizers.
ALTER TABLE public.groups
  ADD COLUMN IF NOT EXISTS avatar_url text;

-- Existing group update policies still require group-admin membership. Grant
-- only the newly added column so an organizer can save the public image URL.
GRANT UPDATE(avatar_url) ON public.groups TO authenticated;

INSERT INTO storage.buckets (
  id,
  name,
  public,
  file_size_limit,
  allowed_mime_types
)
VALUES (
  'group-avatars',
  'group-avatars',
  true,
  5242880,
  ARRAY['image/jpeg', 'image/png', 'image/webp']::text[]
)
ON CONFLICT (id) DO UPDATE
SET name = EXCLUDED.name,
    public = EXCLUDED.public,
    file_size_limit = EXCLUDED.file_size_limit,
    allowed_mime_types = EXCLUDED.allowed_mime_types;

DROP POLICY IF EXISTS group_avatars_select_member ON storage.objects;
CREATE POLICY group_avatars_select_member ON storage.objects
FOR SELECT TO authenticated
USING (
  bucket_id = 'group-avatars'
  AND CASE
    WHEN (storage.foldername(name))[1]
      ~ '^[0-9a-fA-F]{8}-([0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}$'
    THEN public.is_group_member(((storage.foldername(name))[1])::uuid)
    ELSE false
  END
);

DROP POLICY IF EXISTS group_avatars_insert_admin ON storage.objects;
CREATE POLICY group_avatars_insert_admin ON storage.objects
FOR INSERT TO authenticated
WITH CHECK (
  bucket_id = 'group-avatars'
  AND CASE
    WHEN (storage.foldername(name))[1]
      ~ '^[0-9a-fA-F]{8}-([0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}$'
    THEN public.is_group_admin(((storage.foldername(name))[1])::uuid)
    ELSE false
  END
);

DROP POLICY IF EXISTS group_avatars_update_admin ON storage.objects;
CREATE POLICY group_avatars_update_admin ON storage.objects
FOR UPDATE TO authenticated
USING (
  bucket_id = 'group-avatars'
  AND CASE
    WHEN (storage.foldername(name))[1]
      ~ '^[0-9a-fA-F]{8}-([0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}$'
    THEN public.is_group_admin(((storage.foldername(name))[1])::uuid)
    ELSE false
  END
)
WITH CHECK (
  bucket_id = 'group-avatars'
  AND CASE
    WHEN (storage.foldername(name))[1]
      ~ '^[0-9a-fA-F]{8}-([0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}$'
    THEN public.is_group_admin(((storage.foldername(name))[1])::uuid)
    ELSE false
  END
);

DROP POLICY IF EXISTS group_avatars_delete_admin ON storage.objects;
CREATE POLICY group_avatars_delete_admin ON storage.objects
FOR DELETE TO authenticated
USING (
  bucket_id = 'group-avatars'
  AND CASE
    WHEN (storage.foldername(name))[1]
      ~ '^[0-9a-fA-F]{8}-([0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}$'
    THEN public.is_group_admin(((storage.foldername(name))[1])::uuid)
    ELSE false
  END
);
