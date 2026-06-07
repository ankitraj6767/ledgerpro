-- Complete the material module setup workflow with protected master-data RPCs.

create or replace function public.create_material_tender(
  p_organization_id uuid,
  p_name text,
  p_code text default null,
  p_year integer default null,
  p_description text default null
)
returns uuid
language plpgsql
security definer
set search_path = public, ledger_private, pg_temp
as $$
declare
  new_id uuid;
begin
  if not ledger_private.org_has_role(
    p_organization_id,
    array['owner','manager','accountant']::public.org_member_role[]
  ) then raise exception 'Not permitted to create tenders'; end if;
  if nullif(trim(p_name), '') is null then raise exception 'Tender name is required'; end if;
  if p_year is not null and (p_year < 2000 or p_year > 2100) then
    raise exception 'Tender year must be between 2000 and 2100';
  end if;

  insert into public.tenders (
    organization_id, name, code, year, description, created_by, updated_by
  ) values (
    p_organization_id, trim(p_name), nullif(trim(p_code), ''), p_year,
    nullif(trim(p_description), ''), auth.uid(), auth.uid()
  ) returning id into new_id;

  insert into public.material_audit_logs (
    organization_id, actor_id, entity_table, entity_id, action, metadata
  ) values (
    p_organization_id, auth.uid(), 'tenders', new_id, 'create',
    jsonb_build_object('name', trim(p_name), 'year', p_year)
  );
  return new_id;
end;
$$;

create or replace function public.create_material_district(
  p_organization_id uuid,
  p_name text,
  p_state text default null
)
returns uuid
language plpgsql
security definer
set search_path = public, ledger_private, pg_temp
as $$
declare
  new_id uuid;
begin
  if not ledger_private.org_has_role(
    p_organization_id,
    array['owner','manager','accountant']::public.org_member_role[]
  ) then raise exception 'Not permitted to create districts'; end if;
  if nullif(trim(p_name), '') is null then raise exception 'District name is required'; end if;

  insert into public.districts (organization_id, name, state)
  values (p_organization_id, trim(p_name), nullif(trim(p_state), ''))
  returning id into new_id;

  insert into public.material_audit_logs (
    organization_id, actor_id, entity_table, entity_id, action, metadata
  ) values (
    p_organization_id, auth.uid(), 'districts', new_id, 'create',
    jsonb_build_object('name', trim(p_name), 'state', nullif(trim(p_state), ''))
  );
  return new_id;
exception when unique_violation then
  raise exception 'A district with this name already exists';
end;
$$;

create or replace function public.create_material_manager(
  p_organization_id uuid,
  p_full_name text,
  p_phone text default null,
  p_email text default null,
  p_role_label text default 'Project Manager'
)
returns uuid
language plpgsql
security definer
set search_path = public, ledger_private, pg_temp
as $$
declare
  new_id uuid;
begin
  if not ledger_private.org_has_role(
    p_organization_id,
    array['owner','manager','accountant']::public.org_member_role[]
  ) then raise exception 'Not permitted to create site managers'; end if;
  if nullif(trim(p_full_name), '') is null then raise exception 'Manager name is required'; end if;

  insert into public.site_managers (
    organization_id, full_name, phone, email, role_label, created_by, updated_by
  ) values (
    p_organization_id, trim(p_full_name), nullif(trim(p_phone), ''),
    nullif(lower(trim(p_email)), ''), coalesce(nullif(trim(p_role_label), ''), 'Project Manager'),
    auth.uid(), auth.uid()
  ) returning id into new_id;

  insert into public.material_audit_logs (
    organization_id, actor_id, entity_table, entity_id, action, metadata
  ) values (
    p_organization_id, auth.uid(), 'site_managers', new_id, 'create',
    jsonb_build_object('full_name', trim(p_full_name))
  );
  return new_id;
end;
$$;

create or replace function public.create_material_warehouse(
  p_organization_id uuid,
  p_district_id uuid,
  p_name text,
  p_address text default null,
  p_manager_name text default null,
  p_phone text default null,
  p_is_central boolean default false
)
returns uuid
language plpgsql
security definer
set search_path = public, ledger_private, pg_temp
as $$
declare
  new_id uuid;
begin
  if not ledger_private.org_has_role(
    p_organization_id,
    array['owner','manager','accountant']::public.org_member_role[]
  ) then raise exception 'Not permitted to create warehouses'; end if;
  if nullif(trim(p_name), '') is null then raise exception 'Warehouse name is required'; end if;
  if p_district_id is not null and not exists (
    select 1 from public.districts
    where id = p_district_id and organization_id = p_organization_id and deleted_at is null
  ) then raise exception 'District does not belong to this organization'; end if;

  if coalesce(p_is_central, false) then
    update public.warehouses
    set is_central = false, updated_by = auth.uid(), updated_at = now()
    where organization_id = p_organization_id and deleted_at is null and is_central;
  end if;

  insert into public.warehouses (
    organization_id, district_id, name, address, manager_name, phone,
    is_central, created_by, updated_by
  ) values (
    p_organization_id, p_district_id, trim(p_name), nullif(trim(p_address), ''),
    nullif(trim(p_manager_name), ''), nullif(trim(p_phone), ''),
    coalesce(p_is_central, false), auth.uid(), auth.uid()
  ) returning id into new_id;

  insert into public.material_audit_logs (
    organization_id, actor_id, entity_table, entity_id, action, metadata
  ) values (
    p_organization_id, auth.uid(), 'warehouses', new_id, 'create',
    jsonb_build_object('name', trim(p_name), 'district_id', p_district_id, 'is_central', coalesce(p_is_central, false))
  );
  return new_id;
end;
$$;

create or replace function public.create_material_school(
  p_organization_id uuid,
  p_tender_id uuid,
  p_district_id uuid,
  p_name text,
  p_code text default null,
  p_address text default null,
  p_assigned_manager_id uuid default null
)
returns uuid
language plpgsql
security definer
set search_path = public, ledger_private, pg_temp
as $$
declare
  new_id uuid;
begin
  if not ledger_private.org_has_role(
    p_organization_id,
    array['owner','manager','accountant']::public.org_member_role[]
  ) then raise exception 'Not permitted to create schools'; end if;
  if nullif(trim(p_name), '') is null then raise exception 'School name is required'; end if;
  if not exists (
    select 1 from public.tenders
    where id = p_tender_id and organization_id = p_organization_id and deleted_at is null
  ) then raise exception 'Tender does not belong to this organization'; end if;
  if not exists (
    select 1 from public.districts
    where id = p_district_id and organization_id = p_organization_id and deleted_at is null
  ) then raise exception 'District does not belong to this organization'; end if;
  if p_assigned_manager_id is not null and not exists (
    select 1 from public.site_managers
    where id = p_assigned_manager_id and organization_id = p_organization_id
      and deleted_at is null and active
  ) then raise exception 'Manager does not belong to this organization'; end if;

  insert into public.schools (
    organization_id, tender_id, district_id, name, code, address,
    assigned_manager_id, created_by, updated_by
  ) values (
    p_organization_id, p_tender_id, p_district_id, trim(p_name),
    nullif(trim(p_code), ''), nullif(trim(p_address), ''),
    p_assigned_manager_id, auth.uid(), auth.uid()
  ) returning id into new_id;

  insert into public.material_audit_logs (
    organization_id, actor_id, entity_table, entity_id, action, metadata
  ) values (
    p_organization_id, auth.uid(), 'schools', new_id, 'create',
    jsonb_build_object('name', trim(p_name), 'tender_id', p_tender_id, 'district_id', p_district_id)
  );
  return new_id;
end;
$$;

create or replace function public.update_material_school_progress(
  p_organization_id uuid,
  p_school_id uuid,
  p_progress_percent integer,
  p_status text default null
)
returns void
language plpgsql
security definer
set search_path = public, ledger_private, pg_temp
as $$
declare
  next_status text;
begin
  if not ledger_private.org_has_role(
    p_organization_id,
    array['owner','manager','accountant','site_staff']::public.org_member_role[]
  ) then raise exception 'Not permitted to update school progress'; end if;
  if p_progress_percent < 0 or p_progress_percent > 100 then
    raise exception 'Progress must be between 0 and 100';
  end if;
  if not exists (
    select 1 from public.schools
    where id = p_school_id and organization_id = p_organization_id and deleted_at is null
  ) then raise exception 'School not found'; end if;

  next_status := coalesce(
    nullif(trim(p_status), ''),
    case when p_progress_percent >= 100 then 'completed'
         when p_progress_percent > 0 then 'running'
         else 'not_started' end
  );
  if next_status not in ('not_started', 'running', 'completed', 'on_hold') then
    raise exception 'Invalid school status';
  end if;

  update public.schools
  set progress_percent = p_progress_percent,
      status = next_status,
      updated_by = auth.uid(),
      updated_at = now()
  where id = p_school_id and organization_id = p_organization_id;

  insert into public.material_audit_logs (
    organization_id, actor_id, entity_table, entity_id, action, metadata
  ) values (
    p_organization_id, auth.uid(), 'schools', p_school_id, 'update_progress',
    jsonb_build_object('progress_percent', p_progress_percent, 'status', next_status)
  );
end;
$$;

revoke all on function public.create_material_tender(uuid, text, text, integer, text) from public, anon;
revoke all on function public.create_material_district(uuid, text, text) from public, anon;
revoke all on function public.create_material_manager(uuid, text, text, text, text) from public, anon;
revoke all on function public.create_material_warehouse(uuid, uuid, text, text, text, text, boolean) from public, anon;
revoke all on function public.create_material_school(uuid, uuid, uuid, text, text, text, uuid) from public, anon;
revoke all on function public.update_material_school_progress(uuid, uuid, integer, text) from public, anon;

grant execute on function public.create_material_tender(uuid, text, text, integer, text) to authenticated;
grant execute on function public.create_material_district(uuid, text, text) to authenticated;
grant execute on function public.create_material_manager(uuid, text, text, text, text) to authenticated;
grant execute on function public.create_material_warehouse(uuid, uuid, text, text, text, text, boolean) to authenticated;
grant execute on function public.create_material_school(uuid, uuid, uuid, text, text, text, uuid) to authenticated;
grant execute on function public.update_material_school_progress(uuid, uuid, integer, text) to authenticated;
