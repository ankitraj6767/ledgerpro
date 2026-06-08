-- Admin-only update/delete RPCs for material master data.
-- Customers/viewers keep read-only access through RLS select policies.

create or replace function public.update_material_tender(
  p_organization_id uuid,
  p_tender_id uuid,
  p_name text,
  p_code text default null,
  p_year integer default null,
  p_status text default 'active',
  p_description text default null
)
returns void
language plpgsql
security definer
set search_path = public, ledger_private, pg_temp
as $$
begin
  if not ledger_private.org_has_role(
    p_organization_id,
    array['owner','manager','accountant']::public.org_member_role[]
  ) then raise exception 'Not permitted to update tenders'; end if;
  if nullif(trim(p_name), '') is null then raise exception 'Tender name is required'; end if;
  if p_year is not null and (p_year < 2000 or p_year > 2100) then
    raise exception 'Tender year must be between 2000 and 2100';
  end if;
  if coalesce(nullif(trim(p_status), ''), 'active') not in ('active','completed','on_hold','cancelled') then
    raise exception 'Invalid tender status';
  end if;

  update public.tenders
  set name = trim(p_name),
      code = nullif(trim(p_code), ''),
      year = p_year,
      status = coalesce(nullif(trim(p_status), ''), 'active'),
      description = nullif(trim(p_description), ''),
      updated_by = auth.uid(),
      updated_at = now()
  where id = p_tender_id
    and organization_id = p_organization_id
    and deleted_at is null;
  if not found then raise exception 'Tender not found'; end if;

  insert into public.material_audit_logs (
    organization_id, actor_id, entity_table, entity_id, action, metadata
  ) values (
    p_organization_id, auth.uid(), 'tenders', p_tender_id, 'update',
    jsonb_build_object('name', trim(p_name), 'status', coalesce(nullif(trim(p_status), ''), 'active'))
  );
end;
$$;

create or replace function public.delete_material_tender(
  p_organization_id uuid,
  p_tender_id uuid
)
returns void
language plpgsql
security definer
set search_path = public, ledger_private, pg_temp
as $$
begin
  if not ledger_private.org_has_role(
    p_organization_id,
    array['owner','manager','accountant']::public.org_member_role[]
  ) then raise exception 'Not permitted to delete tenders'; end if;
  if exists (
    select 1 from public.schools
    where organization_id = p_organization_id and tender_id = p_tender_id and deleted_at is null
  ) or exists (
    select 1 from public.material_receipts
    where organization_id = p_organization_id and tender_id = p_tender_id and deleted_at is null
  ) or exists (
    select 1 from public.material_issues
    where organization_id = p_organization_id and tender_id = p_tender_id and deleted_at is null
  ) or exists (
    select 1 from public.material_returns
    where organization_id = p_organization_id and tender_id = p_tender_id and deleted_at is null
  ) then raise exception 'Tender has schools or material transactions and cannot be deleted'; end if;

  update public.tenders
  set deleted_at = now(), updated_by = auth.uid(), updated_at = now()
  where id = p_tender_id
    and organization_id = p_organization_id
    and deleted_at is null;
  if not found then raise exception 'Tender not found'; end if;

  insert into public.material_audit_logs (
    organization_id, actor_id, entity_table, entity_id, action, metadata
  ) values (
    p_organization_id, auth.uid(), 'tenders', p_tender_id, 'delete', '{}'::jsonb
  );
end;
$$;

create or replace function public.update_material_district(
  p_organization_id uuid,
  p_district_id uuid,
  p_name text,
  p_state text default null
)
returns void
language plpgsql
security definer
set search_path = public, ledger_private, pg_temp
as $$
begin
  if not ledger_private.org_has_role(
    p_organization_id,
    array['owner','manager','accountant']::public.org_member_role[]
  ) then raise exception 'Not permitted to update districts'; end if;
  if nullif(trim(p_name), '') is null then raise exception 'District name is required'; end if;

  update public.districts
  set name = trim(p_name),
      state = nullif(trim(p_state), ''),
      updated_at = now()
  where id = p_district_id
    and organization_id = p_organization_id
    and deleted_at is null;
  if not found then raise exception 'District not found'; end if;

  insert into public.material_audit_logs (
    organization_id, actor_id, entity_table, entity_id, action, metadata
  ) values (
    p_organization_id, auth.uid(), 'districts', p_district_id, 'update',
    jsonb_build_object('name', trim(p_name), 'state', nullif(trim(p_state), ''))
  );
exception when unique_violation then
  raise exception 'A district with this name already exists';
end;
$$;

create or replace function public.delete_material_district(
  p_organization_id uuid,
  p_district_id uuid
)
returns void
language plpgsql
security definer
set search_path = public, ledger_private, pg_temp
as $$
begin
  if not ledger_private.org_has_role(
    p_organization_id,
    array['owner','manager','accountant']::public.org_member_role[]
  ) then raise exception 'Not permitted to delete districts'; end if;
  if exists (
    select 1 from public.schools
    where organization_id = p_organization_id and district_id = p_district_id and deleted_at is null
  ) or exists (
    select 1 from public.warehouses
    where organization_id = p_organization_id and district_id = p_district_id and deleted_at is null
  ) then raise exception 'District has schools or warehouses and cannot be deleted'; end if;

  update public.districts
  set deleted_at = now(), updated_at = now()
  where id = p_district_id
    and organization_id = p_organization_id
    and deleted_at is null;
  if not found then raise exception 'District not found'; end if;

  insert into public.material_audit_logs (
    organization_id, actor_id, entity_table, entity_id, action, metadata
  ) values (
    p_organization_id, auth.uid(), 'districts', p_district_id, 'delete', '{}'::jsonb
  );
end;
$$;

create or replace function public.update_material_manager(
  p_organization_id uuid,
  p_manager_id uuid,
  p_full_name text,
  p_phone text default null,
  p_email text default null,
  p_role_label text default 'Project Manager',
  p_active boolean default true
)
returns void
language plpgsql
security definer
set search_path = public, ledger_private, pg_temp
as $$
begin
  if not ledger_private.org_has_role(
    p_organization_id,
    array['owner','manager','accountant']::public.org_member_role[]
  ) then raise exception 'Not permitted to update site managers'; end if;
  if nullif(trim(p_full_name), '') is null then raise exception 'Manager name is required'; end if;

  update public.site_managers
  set full_name = trim(p_full_name),
      phone = nullif(trim(p_phone), ''),
      email = nullif(lower(trim(p_email)), ''),
      role_label = coalesce(nullif(trim(p_role_label), ''), 'Project Manager'),
      active = coalesce(p_active, true),
      updated_by = auth.uid(),
      updated_at = now()
  where id = p_manager_id
    and organization_id = p_organization_id
    and deleted_at is null;
  if not found then raise exception 'Manager not found'; end if;

  insert into public.material_audit_logs (
    organization_id, actor_id, entity_table, entity_id, action, metadata
  ) values (
    p_organization_id, auth.uid(), 'site_managers', p_manager_id, 'update',
    jsonb_build_object('full_name', trim(p_full_name), 'active', coalesce(p_active, true))
  );
end;
$$;

create or replace function public.delete_material_manager(
  p_organization_id uuid,
  p_manager_id uuid
)
returns void
language plpgsql
security definer
set search_path = public, ledger_private, pg_temp
as $$
begin
  if not ledger_private.org_has_role(
    p_organization_id,
    array['owner','manager','accountant']::public.org_member_role[]
  ) then raise exception 'Not permitted to delete site managers'; end if;

  update public.site_managers
  set active = false, updated_by = auth.uid(), updated_at = now()
  where id = p_manager_id
    and organization_id = p_organization_id
    and deleted_at is null;
  if not found then raise exception 'Manager not found'; end if;

  insert into public.material_audit_logs (
    organization_id, actor_id, entity_table, entity_id, action, metadata
  ) values (
    p_organization_id, auth.uid(), 'site_managers', p_manager_id, 'delete',
    jsonb_build_object('soft_delete', 'active_false')
  );
end;
$$;

create or replace function public.update_material_warehouse(
  p_organization_id uuid,
  p_warehouse_id uuid,
  p_district_id uuid,
  p_name text,
  p_address text default null,
  p_manager_name text default null,
  p_phone text default null,
  p_is_central boolean default false
)
returns void
language plpgsql
security definer
set search_path = public, ledger_private, pg_temp
as $$
begin
  if not ledger_private.org_has_role(
    p_organization_id,
    array['owner','manager','accountant']::public.org_member_role[]
  ) then raise exception 'Not permitted to update warehouses'; end if;
  if nullif(trim(p_name), '') is null then raise exception 'Warehouse name is required'; end if;
  if p_district_id is not null and not exists (
    select 1 from public.districts
    where id = p_district_id and organization_id = p_organization_id and deleted_at is null
  ) then raise exception 'District does not belong to this organization'; end if;

  if coalesce(p_is_central, false) then
    update public.warehouses
    set is_central = false, updated_by = auth.uid(), updated_at = now()
    where organization_id = p_organization_id
      and id <> p_warehouse_id
      and deleted_at is null
      and is_central;
  end if;

  update public.warehouses
  set district_id = p_district_id,
      name = trim(p_name),
      address = nullif(trim(p_address), ''),
      manager_name = nullif(trim(p_manager_name), ''),
      phone = nullif(trim(p_phone), ''),
      is_central = coalesce(p_is_central, false),
      updated_by = auth.uid(),
      updated_at = now()
  where id = p_warehouse_id
    and organization_id = p_organization_id
    and deleted_at is null;
  if not found then raise exception 'Warehouse not found'; end if;

  insert into public.material_audit_logs (
    organization_id, actor_id, entity_table, entity_id, action, metadata
  ) values (
    p_organization_id, auth.uid(), 'warehouses', p_warehouse_id, 'update',
    jsonb_build_object('name', trim(p_name), 'district_id', p_district_id, 'is_central', coalesce(p_is_central, false))
  );
end;
$$;

create or replace function public.delete_material_warehouse(
  p_organization_id uuid,
  p_warehouse_id uuid
)
returns void
language plpgsql
security definer
set search_path = public, ledger_private, pg_temp
as $$
begin
  if not ledger_private.org_has_role(
    p_organization_id,
    array['owner','manager','accountant']::public.org_member_role[]
  ) then raise exception 'Not permitted to delete warehouses'; end if;
  if exists (
    select 1 from public.warehouse_stock
    where organization_id = p_organization_id and warehouse_id = p_warehouse_id
  ) or exists (
    select 1 from public.material_receipts
    where organization_id = p_organization_id and warehouse_id = p_warehouse_id and deleted_at is null
  ) or exists (
    select 1 from public.material_issues
    where organization_id = p_organization_id and warehouse_id = p_warehouse_id and deleted_at is null
  ) or exists (
    select 1 from public.material_returns
    where organization_id = p_organization_id and warehouse_id = p_warehouse_id and deleted_at is null
  ) then raise exception 'Warehouse has stock or transactions and cannot be deleted'; end if;

  update public.warehouses
  set deleted_at = now(), updated_by = auth.uid(), updated_at = now()
  where id = p_warehouse_id
    and organization_id = p_organization_id
    and deleted_at is null;
  if not found then raise exception 'Warehouse not found'; end if;

  insert into public.material_audit_logs (
    organization_id, actor_id, entity_table, entity_id, action, metadata
  ) values (
    p_organization_id, auth.uid(), 'warehouses', p_warehouse_id, 'delete', '{}'::jsonb
  );
end;
$$;

create or replace function public.update_material_school(
  p_organization_id uuid,
  p_school_id uuid,
  p_tender_id uuid,
  p_district_id uuid,
  p_name text,
  p_code text default null,
  p_address text default null,
  p_status text default 'not_started',
  p_progress_percent integer default 0,
  p_assigned_manager_id uuid default null
)
returns void
language plpgsql
security definer
set search_path = public, ledger_private, pg_temp
as $$
begin
  if not ledger_private.org_has_role(
    p_organization_id,
    array['owner','manager','accountant']::public.org_member_role[]
  ) then raise exception 'Not permitted to update schools'; end if;
  if nullif(trim(p_name), '') is null then raise exception 'School name is required'; end if;
  if p_progress_percent is null or p_progress_percent < 0 or p_progress_percent > 100 then
    raise exception 'Progress must be between 0 and 100';
  end if;
  if coalesce(nullif(trim(p_status), ''), 'not_started') not in ('not_started','running','completed','on_hold') then
    raise exception 'Invalid school status';
  end if;
  if not exists (
    select 1 from public.tenders
    where id = p_tender_id and organization_id = p_organization_id and deleted_at is null
  ) then raise exception 'Tender does not belong to this organization'; end if;
  if p_district_id is not null and not exists (
    select 1 from public.districts
    where id = p_district_id and organization_id = p_organization_id and deleted_at is null
  ) then raise exception 'District does not belong to this organization'; end if;
  if p_assigned_manager_id is not null and not exists (
    select 1 from public.site_managers
    where id = p_assigned_manager_id and organization_id = p_organization_id
      and deleted_at is null and active
  ) then raise exception 'Manager does not belong to this organization'; end if;

  update public.schools
  set tender_id = p_tender_id,
      district_id = p_district_id,
      name = trim(p_name),
      code = nullif(trim(p_code), ''),
      address = nullif(trim(p_address), ''),
      status = coalesce(nullif(trim(p_status), ''), 'not_started'),
      progress_percent = p_progress_percent,
      assigned_manager_id = p_assigned_manager_id,
      updated_by = auth.uid(),
      updated_at = now()
  where id = p_school_id
    and organization_id = p_organization_id
    and deleted_at is null;
  if not found then raise exception 'School not found'; end if;

  insert into public.material_audit_logs (
    organization_id, actor_id, entity_table, entity_id, action, metadata
  ) values (
    p_organization_id, auth.uid(), 'schools', p_school_id, 'update',
    jsonb_build_object('name', trim(p_name), 'status', coalesce(nullif(trim(p_status), ''), 'not_started'), 'progress_percent', p_progress_percent)
  );
end;
$$;

create or replace function public.delete_material_school(
  p_organization_id uuid,
  p_school_id uuid
)
returns void
language plpgsql
security definer
set search_path = public, ledger_private, pg_temp
as $$
begin
  if not ledger_private.org_has_role(
    p_organization_id,
    array['owner','manager','accountant']::public.org_member_role[]
  ) then raise exception 'Not permitted to delete schools'; end if;
  if exists (
    select 1 from public.school_material_requirements
    where organization_id = p_organization_id and school_id = p_school_id and deleted_at is null
  ) or exists (
    select 1 from public.material_issues
    where organization_id = p_organization_id and school_id = p_school_id and deleted_at is null
  ) or exists (
    select 1 from public.material_returns
    where organization_id = p_organization_id and school_id = p_school_id and deleted_at is null
  ) then raise exception 'School has requirements or transactions and cannot be deleted'; end if;

  update public.schools
  set deleted_at = now(), updated_by = auth.uid(), updated_at = now()
  where id = p_school_id
    and organization_id = p_organization_id
    and deleted_at is null;
  if not found then raise exception 'School not found'; end if;

  insert into public.material_audit_logs (
    organization_id, actor_id, entity_table, entity_id, action, metadata
  ) values (
    p_organization_id, auth.uid(), 'schools', p_school_id, 'delete', '{}'::jsonb
  );
end;
$$;

create or replace function public.update_material_item(
  p_organization_id uuid,
  p_material_id uuid,
  p_name text,
  p_unit text,
  p_sku text default null,
  p_category text default null,
  p_low_stock_threshold numeric default 0
)
returns void
language plpgsql
security definer
set search_path = public, ledger_private, pg_temp
as $$
begin
  if not ledger_private.org_has_role(
    p_organization_id,
    array['owner','manager','accountant']::public.org_member_role[]
  ) then raise exception 'Not permitted to update material items'; end if;
  if nullif(trim(p_name), '') is null or nullif(trim(p_unit), '') is null then
    raise exception 'Material name and unit are required';
  end if;
  if p_low_stock_threshold is null or p_low_stock_threshold < 0 then
    raise exception 'Low stock threshold cannot be negative';
  end if;

  update public.material_items
  set name = trim(p_name),
      unit = trim(p_unit),
      sku = nullif(trim(p_sku), ''),
      category = nullif(trim(p_category), ''),
      low_stock_threshold = p_low_stock_threshold,
      updated_by = auth.uid(),
      updated_at = now()
  where id = p_material_id
    and organization_id = p_organization_id
    and deleted_at is null;
  if not found then raise exception 'Material item not found'; end if;

  insert into public.material_audit_logs (
    organization_id, actor_id, entity_table, entity_id, action, metadata
  ) values (
    p_organization_id, auth.uid(), 'material_items', p_material_id, 'update',
    jsonb_build_object('name', trim(p_name), 'unit', trim(p_unit), 'low_stock_threshold', p_low_stock_threshold)
  );
end;
$$;

create or replace function public.delete_material_item(
  p_organization_id uuid,
  p_material_id uuid
)
returns void
language plpgsql
security definer
set search_path = public, ledger_private, pg_temp
as $$
begin
  if not ledger_private.org_has_role(
    p_organization_id,
    array['owner','manager','accountant']::public.org_member_role[]
  ) then raise exception 'Not permitted to delete material items'; end if;
  if exists (
    select 1 from public.warehouse_stock
    where organization_id = p_organization_id and material_id = p_material_id
  ) or exists (
    select 1 from public.school_material_requirements
    where organization_id = p_organization_id and material_id = p_material_id and deleted_at is null
  ) or exists (
    select 1 from public.material_receipts
    where organization_id = p_organization_id and material_id = p_material_id and deleted_at is null
  ) or exists (
    select 1 from public.material_issues
    where organization_id = p_organization_id and material_id = p_material_id and deleted_at is null
  ) or exists (
    select 1 from public.material_returns
    where organization_id = p_organization_id and material_id = p_material_id and deleted_at is null
  ) then raise exception 'Material item has stock, requirements, or transactions and cannot be deleted'; end if;

  update public.material_items
  set deleted_at = now(), updated_by = auth.uid(), updated_at = now()
  where id = p_material_id
    and organization_id = p_organization_id
    and deleted_at is null;
  if not found then raise exception 'Material item not found'; end if;

  insert into public.material_audit_logs (
    organization_id, actor_id, entity_table, entity_id, action, metadata
  ) values (
    p_organization_id, auth.uid(), 'material_items', p_material_id, 'delete', '{}'::jsonb
  );
end;
$$;

revoke all on function public.update_material_tender(uuid, uuid, text, text, integer, text, text) from public, anon;
revoke all on function public.delete_material_tender(uuid, uuid) from public, anon;
revoke all on function public.update_material_district(uuid, uuid, text, text) from public, anon;
revoke all on function public.delete_material_district(uuid, uuid) from public, anon;
revoke all on function public.update_material_manager(uuid, uuid, text, text, text, text, boolean) from public, anon;
revoke all on function public.delete_material_manager(uuid, uuid) from public, anon;
revoke all on function public.update_material_warehouse(uuid, uuid, uuid, text, text, text, text, boolean) from public, anon;
revoke all on function public.delete_material_warehouse(uuid, uuid) from public, anon;
revoke all on function public.update_material_school(uuid, uuid, uuid, uuid, text, text, text, text, integer, uuid) from public, anon;
revoke all on function public.delete_material_school(uuid, uuid) from public, anon;
revoke all on function public.update_material_item(uuid, uuid, text, text, text, text, numeric) from public, anon;
revoke all on function public.delete_material_item(uuid, uuid) from public, anon;

grant execute on function public.update_material_tender(uuid, uuid, text, text, integer, text, text) to authenticated;
grant execute on function public.delete_material_tender(uuid, uuid) to authenticated;
grant execute on function public.update_material_district(uuid, uuid, text, text) to authenticated;
grant execute on function public.delete_material_district(uuid, uuid) to authenticated;
grant execute on function public.update_material_manager(uuid, uuid, text, text, text, text, boolean) to authenticated;
grant execute on function public.delete_material_manager(uuid, uuid) to authenticated;
grant execute on function public.update_material_warehouse(uuid, uuid, uuid, text, text, text, text, boolean) to authenticated;
grant execute on function public.delete_material_warehouse(uuid, uuid) to authenticated;
grant execute on function public.update_material_school(uuid, uuid, uuid, uuid, text, text, text, text, integer, uuid) to authenticated;
grant execute on function public.delete_material_school(uuid, uuid) to authenticated;
grant execute on function public.update_material_item(uuid, uuid, text, text, text, text, numeric) to authenticated;
grant execute on function public.delete_material_item(uuid, uuid) to authenticated;
