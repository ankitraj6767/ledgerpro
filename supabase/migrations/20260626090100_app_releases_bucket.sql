-- =============================================================================
-- Create the app-releases public storage bucket for update manifests and APKs.
-- =============================================================================

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'app-releases',
  'app-releases',
  true, -- public bucket: manifest and downloads are unauthenticated
  104857600, -- 100 MB (APKs/ZIPs can be large)
  array[
    'application/json',
    'application/vnd.android.package-archive',
    'application/zip',
    'application/octet-stream'
  ]
)
on conflict (id) do update
  set public = excluded.public,
      file_size_limit = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;

-- Anyone can read (public downloads).
drop policy if exists "app_releases_public_read" on storage.objects;
create policy "app_releases_public_read" on storage.objects
  for select to anon, authenticated
  using (bucket_id = 'app-releases');

-- Only authenticated owners/managers can upload releases.
drop policy if exists "app_releases_write" on storage.objects;
create policy "app_releases_write" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'app-releases');

drop policy if exists "app_releases_update" on storage.objects;
create policy "app_releases_update" on storage.objects
  for update to authenticated
  using (bucket_id = 'app-releases');
