-- Infra realtime publication + client sync replay guard metadata.
-- Flutter still uses RLS/RPCs as the authority; this table records device
-- mutation ids so replayed offline writes can be detected server-side.

create table if not exists public.infra_sync_mutations (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id),
  mutation_id text not null,
  device_id text not null,
  entity_table text not null,
  entity_id uuid,
  status text not null default 'pending'
    check (status in ('pending', 'in_flight', 'synced', 'failed', 'conflict')),
  payload_hash text,
  error_message text,
  last_synced_at timestamptz,
  created_by uuid references auth.users(id) default auth.uid(),
  updated_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  unique (organization_id, mutation_id, device_id)
);

create index if not exists infra_sync_mutations_org_status_idx
  on public.infra_sync_mutations (organization_id, status, updated_at desc)
  where deleted_at is null;

alter table public.infra_sync_mutations enable row level security;

drop policy if exists "infra_sync_mutations_select" on public.infra_sync_mutations;
create policy "infra_sync_mutations_select" on public.infra_sync_mutations
  for select to authenticated
  using (ledger_private.can_read_org(organization_id));

drop policy if exists "infra_sync_mutations_insert" on public.infra_sync_mutations;
create policy "infra_sync_mutations_insert" on public.infra_sync_mutations
  for insert to authenticated
  with check (ledger_private.can_read_org(organization_id));

drop policy if exists "infra_sync_mutations_update" on public.infra_sync_mutations;
create policy "infra_sync_mutations_update" on public.infra_sync_mutations
  for update to authenticated
  using (ledger_private.can_read_org(organization_id))
  with check (ledger_private.can_read_org(organization_id));

drop trigger if exists set_updated_at on public.infra_sync_mutations;
create trigger set_updated_at
before update on public.infra_sync_mutations
for each row execute function ledger_private.set_updated_at();

create or replace function public.record_infra_sync_mutation(
  p_organization_id uuid,
  p_mutation_id text,
  p_device_id text,
  p_entity_table text,
  p_entity_id uuid default null,
  p_status text default 'pending',
  p_payload_hash text default null,
  p_error_message text default null
)
returns boolean
language plpgsql
security definer
set search_path = public, ledger_private, pg_temp
as $$
declare
  inserted boolean := false;
begin
  if not ledger_private.can_read_org(p_organization_id) then
    raise exception 'Not permitted to record sync mutation';
  end if;

  insert into public.infra_sync_mutations (
    organization_id,
    mutation_id,
    device_id,
    entity_table,
    entity_id,
    status,
    payload_hash,
    error_message,
    last_synced_at,
    created_by,
    updated_by
  ) values (
    p_organization_id,
    p_mutation_id,
    p_device_id,
    p_entity_table,
    p_entity_id,
    p_status,
    p_payload_hash,
    p_error_message,
    case when p_status = 'synced' then now() else null end,
    auth.uid(),
    auth.uid()
  )
  on conflict (organization_id, mutation_id, device_id) do update
    set status = excluded.status,
        payload_hash = coalesce(excluded.payload_hash, public.infra_sync_mutations.payload_hash),
        error_message = excluded.error_message,
        last_synced_at = case
          when excluded.status = 'synced' then now()
          else public.infra_sync_mutations.last_synced_at
        end,
        updated_by = auth.uid(),
        updated_at = now()
  returning xmax = 0 into inserted;

  return inserted;
end;
$$;

grant select, insert, update on public.infra_sync_mutations to authenticated;
grant execute on function public.record_infra_sync_mutation(
  uuid, text, text, text, uuid, text, text, text
) to authenticated;

do $$
declare
  table_name text;
  tables text[] := array[
    'organizations',
    'organization_members',
    'infra_projects',
    'investors',
    'project_investments',
    'government_funds',
    'government_fund_receipts',
    'project_expenses',
    'project_notes',
    'project_progress_updates',
    'project_documents',
    'customer_project_assignments',
    'project_audit_logs',
    'infra_sync_mutations'
  ];
begin
  if exists (select 1 from pg_publication where pubname = 'supabase_realtime') then
    foreach table_name in array tables loop
      begin
        execute format('alter publication supabase_realtime add table public.%I', table_name);
      exception when duplicate_object then
        null;
      end;
    end loop;
  end if;
end $$;
