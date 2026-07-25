-- =============================================================================
-- E-Pass Challan material entries (Bihar Khanan Soft portal capture)
-- =============================================================================
-- Stores mineral transport challans that a user captured from the Bihar
-- Government e-Pass portal inside an in-app WebView after completing CAPTCHA /
-- login manually, or entered manually.
--
-- Security notes:
--   * No government credential, cookie or CAPTCHA value is ever stored.
--   * verification_status/verification_method always identify HOW the data was
--     obtained. 'official_api_verified' is reserved for a future authorized
--     government API and is never written by the current client.
--   * Duplicate protection is enforced by a unique index (server is the final
--     authority); the Flutter pre-check is only a UX affordance.
-- =============================================================================

create table if not exists public.epass_challans (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id),
  project_id uuid not null references public.infra_projects(id),
  source_portal text not null default 'bihar_khanan_soft',
  portal_url text,
  financial_year text not null,
  challan_number text not null,
  normalized_challan_number text not null,
  uid_number text,
  challan_date timestamptz,
  valid_until timestamptz,
  selected_material_type text,
  portal_mineral_name text not null,
  quantity numeric(14, 3) not null,
  quantity_unit text not null default 'MT',
  vehicle_type text,
  vehicle_number text not null,
  normalized_vehicle_number text not null,
  consignor_name text,
  consignee_name text,
  source_location text,
  destination text,
  generated_from text,
  royalty_amount_paise bigint,
  portal_payload jsonb not null default '{}'::jsonb,
  portal_response_hash text,
  verification_status text not null,
  verification_method text not null,
  captured_at timestamptz,
  verified_at timestamptz,
  created_by uuid references auth.users(id) default auth.uid(),
  updated_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  constraint epass_challans_quantity_positive
    check (quantity > 0),
  constraint epass_challans_royalty_non_negative
    check (royalty_amount_paise is null or royalty_amount_paise >= 0),
  constraint epass_challans_verification_status_valid
    check (verification_status in (
      'portal_captured',
      'manual_unverified',
      'official_api_verified',
      'invalid',
      'expired'
    )),
  constraint epass_challans_verification_method_valid
    check (verification_method in (
      'webview_human_verification',
      'manual_entry',
      'official_api'
    ))
);

-- ---------------------------------------------------------------------------
-- Normalization (server-side authority)
-- ---------------------------------------------------------------------------
create or replace function ledger_private.normalize_challan_token(p_value text)
returns text
language sql
immutable
as $$
  select nullif(regexp_replace(upper(coalesce(p_value, '')), '[^A-Z0-9]', '', 'g'), '');
$$;

-- Normalizes on every write so direct PostgREST inserts cannot bypass the
-- duplicate index by supplying a differently-formatted normalized value.
create or replace function ledger_private.epass_challan_normalize()
returns trigger
language plpgsql
set search_path = public, ledger_private, pg_temp
as $$
begin
  new.challan_number := btrim(coalesce(new.challan_number, ''));
  new.vehicle_number := btrim(coalesce(new.vehicle_number, ''));
  new.financial_year := btrim(coalesce(new.financial_year, ''));
  new.normalized_challan_number :=
    ledger_private.normalize_challan_token(new.challan_number);
  new.normalized_vehicle_number :=
    ledger_private.normalize_challan_token(new.vehicle_number);

  if new.normalized_challan_number is null then
    raise exception 'Challan number must contain at least one letter or digit';
  end if;
  if new.normalized_vehicle_number is null then
    raise exception 'Vehicle number must contain at least one letter or digit';
  end if;
  if new.financial_year = '' then
    raise exception 'Financial year is required';
  end if;

  return new;
end;
$$;

drop trigger if exists epass_challans_normalize on public.epass_challans;
create trigger epass_challans_normalize
before insert or update on public.epass_challans
for each row execute function ledger_private.epass_challan_normalize();

drop trigger if exists set_updated_at on public.epass_challans;
create trigger set_updated_at
before update on public.epass_challans
for each row execute function ledger_private.set_updated_at();

-- Soft-delete only (matches the other financial tables).
drop trigger if exists prevent_hard_delete on public.epass_challans;
create trigger prevent_hard_delete
before delete on public.epass_challans
for each row execute function ledger_private.prevent_hard_delete();

-- ---------------------------------------------------------------------------
-- Duplicate protection
-- ---------------------------------------------------------------------------
-- Deliberately NOT a partial index: soft-deleted rows keep occupying the slot
-- so an archived challan cannot be re-saved to sidestep the duplicate rule.
create unique index if not exists epass_challans_unique_challan_idx
  on public.epass_challans (
    organization_id,
    source_portal,
    financial_year,
    normalized_challan_number
  );

-- ---------------------------------------------------------------------------
-- Indexes
-- ---------------------------------------------------------------------------
create index if not exists epass_challans_org_created_idx
  on public.epass_challans (organization_id, created_at desc)
  where deleted_at is null;

create index if not exists epass_challans_project_date_idx
  on public.epass_challans (project_id, challan_date desc)
  where deleted_at is null;

create index if not exists epass_challans_normalized_challan_idx
  on public.epass_challans (normalized_challan_number)
  where deleted_at is null;

create index if not exists epass_challans_normalized_vehicle_idx
  on public.epass_challans (normalized_vehicle_number)
  where deleted_at is null;

create index if not exists epass_challans_mineral_idx
  on public.epass_challans (portal_mineral_name)
  where deleted_at is null;

create index if not exists epass_challans_status_idx
  on public.epass_challans (verification_status)
  where deleted_at is null;

-- ---------------------------------------------------------------------------
-- RLS
-- ---------------------------------------------------------------------------
alter table public.epass_challans enable row level security;

-- Read: any org member. Customers are narrowed to projects explicitly assigned
-- through customer_project_assignments by can_read_project_data().
drop policy if exists "epass_challans_select" on public.epass_challans;
create policy "epass_challans_select" on public.epass_challans
  for select to authenticated
  using (ledger_private.can_read_project_data(organization_id, project_id));

-- Insert: owner / manager / accountant / site_staff. Viewers and customers
-- cannot add challans.
drop policy if exists "epass_challans_insert" on public.epass_challans;
create policy "epass_challans_insert" on public.epass_challans
  for insert to authenticated
  with check (
    ledger_private.org_has_role(
      organization_id,
      array['owner','manager','accountant','site_staff']::public.org_member_role[]
    )
    and exists (
      select 1
      from public.infra_projects p
      where p.id = project_id
        and p.organization_id = organization_id
        and p.deleted_at is null
    )
  );

-- Update (archive / status change): owner / manager only.
drop policy if exists "epass_challans_update" on public.epass_challans;
create policy "epass_challans_update" on public.epass_challans
  for update to authenticated
  using (
    ledger_private.org_has_role(
      organization_id,
      array['owner','manager']::public.org_member_role[]
    )
  )
  with check (
    ledger_private.org_has_role(
      organization_id,
      array['owner','manager']::public.org_member_role[]
    )
  );

-- ---------------------------------------------------------------------------
-- create_epass_challan: atomic validate + duplicate-check + insert + audit
-- ---------------------------------------------------------------------------
create or replace function public.create_epass_challan(
  p_project_id uuid,
  p_financial_year text,
  p_challan_number text,
  p_portal_mineral_name text,
  p_quantity numeric,
  p_vehicle_number text,
  p_verification_status text,
  p_verification_method text,
  p_selected_material_type text default null,
  p_quantity_unit text default 'MT',
  p_uid_number text default null,
  p_challan_date timestamptz default null,
  p_valid_until timestamptz default null,
  p_vehicle_type text default null,
  p_consignor_name text default null,
  p_consignee_name text default null,
  p_source_location text default null,
  p_destination text default null,
  p_generated_from text default null,
  p_royalty_amount_paise bigint default null,
  p_portal_payload jsonb default '{}'::jsonb,
  p_portal_response_hash text default null,
  p_portal_url text default null,
  p_source_portal text default 'bihar_khanan_soft',
  p_captured_at timestamptz default null
)
returns public.epass_challans
language plpgsql
security definer
set search_path = public, ledger_private, pg_temp
as $$
declare
  v_org_id uuid;
  v_uid uuid := auth.uid();
  v_normalized text;
  v_row public.epass_challans;
  v_existing_id uuid;
begin
  if v_uid is null then
    raise exception 'Sign in again to save a challan';
  end if;

  -- Project must exist and is the source of truth for the organization.
  select p.organization_id into v_org_id
  from public.infra_projects p
  where p.id = p_project_id
    and p.deleted_at is null;

  if v_org_id is null then
    raise exception 'Project no longer exists';
  end if;

  -- Active membership + role check.
  if not ledger_private.org_has_role(
    v_org_id,
    array['owner','manager','accountant','site_staff']::public.org_member_role[]
  ) then
    raise exception 'Not permitted to add challans';
  end if;

  if p_verification_method = 'official_api' then
    raise exception 'official_api verification is not available yet';
  end if;

  if coalesce(p_quantity, 0) <= 0 then
    raise exception 'Quantity must be greater than zero';
  end if;

  v_normalized := ledger_private.normalize_challan_token(p_challan_number);
  if v_normalized is null then
    raise exception 'Challan number must contain at least one letter or digit';
  end if;

  -- Server-side duplicate check (authoritative).
  select c.id into v_existing_id
  from public.epass_challans c
  where c.organization_id = v_org_id
    and c.source_portal = coalesce(p_source_portal, 'bihar_khanan_soft')
    and c.financial_year = btrim(p_financial_year)
    and c.normalized_challan_number = v_normalized
  limit 1;

  if v_existing_id is not null then
    raise exception 'DUPLICATE_CHALLAN: this challan is already saved (%)', v_existing_id
      using errcode = '23505';
  end if;

  begin
    insert into public.epass_challans (
      organization_id, project_id, source_portal, portal_url,
      financial_year, challan_number, normalized_challan_number, uid_number,
      challan_date, valid_until, selected_material_type, portal_mineral_name,
      quantity, quantity_unit, vehicle_type, vehicle_number,
      normalized_vehicle_number, consignor_name, consignee_name,
      source_location, destination, generated_from, royalty_amount_paise,
      portal_payload, portal_response_hash, verification_status,
      verification_method, captured_at, verified_at, created_by, updated_by
    ) values (
      v_org_id, p_project_id, coalesce(p_source_portal, 'bihar_khanan_soft'),
      p_portal_url, btrim(p_financial_year), p_challan_number, v_normalized,
      p_uid_number, p_challan_date, p_valid_until, p_selected_material_type,
      p_portal_mineral_name, p_quantity, coalesce(p_quantity_unit, 'MT'),
      p_vehicle_type, p_vehicle_number, '', p_consignor_name, p_consignee_name,
      p_source_location, p_destination, p_generated_from, p_royalty_amount_paise,
      coalesce(p_portal_payload, '{}'::jsonb), p_portal_response_hash,
      p_verification_status, p_verification_method, p_captured_at,
      case when p_verification_status = 'portal_captured'
        then coalesce(p_captured_at, now()) else null end,
      v_uid, v_uid
    )
    returning * into v_row;
  exception when unique_violation then
    -- Lost a race against a concurrent insert; surface the same clear error.
    raise exception 'DUPLICATE_CHALLAN: this challan is already saved'
      using errcode = '23505';
  end;

  insert into public.project_audit_logs (
    organization_id, project_id, actor_id, entity_table, entity_id, action
  ) values (
    v_org_id, p_project_id, v_uid, 'epass_challans', v_row.id,
    case when p_verification_method = 'manual_entry'
      then 'manual_challan_created' else 'challan_created' end
  );

  return v_row;
end;
$$;

-- ---------------------------------------------------------------------------
-- archive_epass_challan: owner/manager soft-delete + audit
-- ---------------------------------------------------------------------------
create or replace function public.archive_epass_challan(p_challan_id uuid)
returns boolean
language plpgsql
security definer
set search_path = public, ledger_private, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
  v_org_id uuid;
  v_project_id uuid;
begin
  if v_uid is null then
    raise exception 'Sign in again to archive a challan';
  end if;

  select c.organization_id, c.project_id into v_org_id, v_project_id
  from public.epass_challans c
  where c.id = p_challan_id
    and c.deleted_at is null;

  if v_org_id is null then
    raise exception 'Challan not found';
  end if;

  if not ledger_private.org_has_role(
    v_org_id, array['owner','manager']::public.org_member_role[]
  ) then
    raise exception 'Not permitted to archive challans';
  end if;

  update public.epass_challans
    set deleted_at = now(), updated_by = v_uid, updated_at = now()
  where id = p_challan_id and deleted_at is null;

  insert into public.project_audit_logs (
    organization_id, project_id, actor_id, entity_table, entity_id, action
  ) values (
    v_org_id, v_project_id, v_uid, 'epass_challans', p_challan_id,
    'challan_archived'
  );

  return true;
end;
$$;

-- ---------------------------------------------------------------------------
-- record_challan_duplicate_block: audit a blocked duplicate save attempt.
-- Separate function so the audit row survives (create_epass_challan raises,
-- which would roll back an audit row written in the same transaction).
-- ---------------------------------------------------------------------------
create or replace function public.record_challan_duplicate_block(
  p_project_id uuid,
  p_challan_number text
)
returns boolean
language plpgsql
security definer
set search_path = public, ledger_private, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
  v_org_id uuid;
begin
  if v_uid is null then
    return false;
  end if;

  select p.organization_id into v_org_id
  from public.infra_projects p
  where p.id = p_project_id and p.deleted_at is null;

  if v_org_id is null or not ledger_private.can_read_org(v_org_id) then
    return false;
  end if;

  insert into public.project_audit_logs (
    organization_id, project_id, actor_id, entity_table, entity_id, action
  ) values (
    v_org_id, p_project_id, v_uid, 'epass_challans', null,
    'duplicate_save_blocked'
  );

  return true;
end;
$$;

-- ---------------------------------------------------------------------------
-- Grants. Authenticated only; anon gets nothing.
-- ---------------------------------------------------------------------------
grant select, insert, update on public.epass_challans to authenticated;

grant execute on function public.create_epass_challan(
  uuid, text, text, text, numeric, text, text, text, text, text, text,
  timestamptz, timestamptz, text, text, text, text, text, text, bigint,
  jsonb, text, text, text, timestamptz
) to authenticated;
grant execute on function public.archive_epass_challan(uuid) to authenticated;
grant execute on function public.record_challan_duplicate_block(uuid, text)
  to authenticated;

-- PostgreSQL grants function EXECUTE to PUBLIC by default, and anon inherits
-- PUBLIC. Revoking from anon alone would leave anonymous access open, so revoke
-- PUBLIC first (matching 20260531103021_restrict_public_rpc_execution.sql).
revoke execute on function public.create_epass_challan(
  uuid, text, text, text, numeric, text, text, text, text, text, text,
  timestamptz, timestamptz, text, text, text, text, text, text, bigint,
  jsonb, text, text, text, timestamptz
) from public, anon;
revoke execute on function public.archive_epass_challan(uuid)
  from public, anon;
revoke execute on function public.record_challan_duplicate_block(uuid, text)
  from public, anon;

-- ---------------------------------------------------------------------------
-- Realtime publication (idempotent)
-- ---------------------------------------------------------------------------
do $$
begin
  if exists (select 1 from pg_publication where pubname = 'supabase_realtime') then
    begin
      execute 'alter publication supabase_realtime add table public.epass_challans';
    exception when duplicate_object then
      null;
    end;
  end if;
end $$;
