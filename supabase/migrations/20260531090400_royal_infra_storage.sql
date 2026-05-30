-- =============================================================================
-- Royal Infra — storage bucket for project documents
-- Path convention: {organization_id}/{project_id}/{document_type}/{uuid}-{filename}
-- =============================================================================

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'project-documents',
  'project-documents',
  false,
  10485760, -- 10 MB
  array['image/jpeg', 'image/png', 'application/pdf', 'text/csv']
)
on conflict (id) do update
  set file_size_limit = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;

-- Only members of the organization (first path segment) can read/write.
drop policy if exists "project_docs_read" on storage.objects;
create policy "project_docs_read" on storage.objects
  for select to authenticated
  using (
    bucket_id = 'project-documents'
    and ledger_private.is_org_member((split_part(name, '/', 1))::uuid)
  );

drop policy if exists "project_docs_write" on storage.objects;
create policy "project_docs_write" on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'project-documents'
    and ledger_private.is_org_member((split_part(name, '/', 1))::uuid)
  );

drop policy if exists "project_docs_update" on storage.objects;
create policy "project_docs_update" on storage.objects
  for update to authenticated
  using (
    bucket_id = 'project-documents'
    and ledger_private.is_org_member((split_part(name, '/', 1))::uuid)
  );
