-- =============================================================================
-- E-Pass Challan: delete (instead of archive) and allow re-adding
-- =============================================================================
-- Behaviour change requested: a user must be able to delete a challan and then
-- add the same challan number again (e.g. after a mistaken or test entry).
--
-- The original design deliberately used a NON-partial unique index so a
-- soft-deleted row kept occupying its slot. That is now relaxed: the uniqueness
-- rule applies only to LIVE rows, so deleting genuinely frees the number.
--
-- Deletion stays a soft delete (deleted_at), matching every other financial
-- table in this schema and the existing delete_project / delete_project_expense
-- RPCs. That keeps the audit trail and the prevent_hard_delete guarantee intact
-- while making the number reusable.
-- =============================================================================

-- ---------------------------------------------------------------------------
-- 1. Uniqueness now applies to live rows only
-- ---------------------------------------------------------------------------
drop index if exists public.epass_challans_unique_challan_idx;

create unique index if not exists epass_challans_unique_challan_idx
  on public.epass_challans (
    organization_id,
    source_portal,
    financial_year,
    normalized_challan_number
  )
  where deleted_at is null;

-- ---------------------------------------------------------------------------
-- 2. create_epass_challan: duplicate check must ignore deleted rows
-- ---------------------------------------------------------------------------
-- Same signature as 20260725090000; only the duplicate lookup changed
-- (adds "and c.deleted_at is null").
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

  select p.organization_id into v_org_id
  from public.infra_projects p
  where p.id = p_project_id
    and p.deleted_at is null;

  if v_org_id is null then
    raise exception 'Project no longer exists';
  end if;

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

  -- Authoritative duplicate check against LIVE rows only, so a previously
  -- deleted challan number can be added again.
  select c.id into v_existing_id
  from public.epass_challans c
  where c.organization_id = v_org_id
    and c.source_portal = coalesce(p_source_portal, 'bihar_khanan_soft')
    and c.financial_year = btrim(p_financial_year)
    and c.normalized_challan_number = v_normalized
    and c.deleted_at is null
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
-- 3. delete_epass_challan: user-facing delete (soft delete + audit)
-- ---------------------------------------------------------------------------
-- Matches the naming of the existing delete_project / delete_project_expense
-- RPCs. Frees the challan number for re-entry because uniqueness is now
-- restricted to live rows.
create or replace function public.delete_epass_challan(p_challan_id uuid)
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
    raise exception 'Sign in again to delete a challan';
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
    raise exception 'Not permitted to delete challans';
  end if;

  update public.epass_challans
    set deleted_at = now(), updated_by = v_uid, updated_at = now()
  where id = p_challan_id and deleted_at is null;

  insert into public.project_audit_logs (
    organization_id, project_id, actor_id, entity_table, entity_id, action
  ) values (
    v_org_id, v_project_id, v_uid, 'epass_challans', p_challan_id,
    'challan_deleted'
  );

  return true;
end;
$$;

-- ---------------------------------------------------------------------------
-- 4. Grants
-- ---------------------------------------------------------------------------
-- archive_epass_challan is intentionally left in place so any client still
-- calling it keeps working; the UI now calls delete_epass_challan.
grant execute on function public.delete_epass_challan(uuid) to authenticated;
revoke execute on function public.delete_epass_challan(uuid) from public, anon;
