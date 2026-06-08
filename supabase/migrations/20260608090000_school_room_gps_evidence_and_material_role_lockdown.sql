-- School room counts, GPS photo evidence, and material role lockdown.
-- Field staff can update school progress/evidence, but stock/material mutation
-- stays with office/admin roles.

alter table public.schools
  add column if not exists room_quantity integer not null default 0
    check (room_quantity >= 0),
  add column if not exists gps_photo_paths text[] not null default '{}'::text[],
  add column if not exists gps_latitude numeric(10,7),
  add column if not exists gps_longitude numeric(10,7),
  add column if not exists gps_accuracy_meters numeric(10,2),
  add column if not exists gps_captured_at timestamptz;

create index if not exists schools_org_room_quantity_idx
  on public.schools (organization_id, room_quantity)
  where deleted_at is null;

drop function if exists public.create_material_school(uuid, uuid, uuid, text, text, text, uuid);
create or replace function public.create_material_school(
  p_organization_id uuid,
  p_tender_id uuid,
  p_district_id uuid,
  p_name text,
  p_code text default null,
  p_address text default null,
  p_assigned_manager_id uuid default null,
  p_room_quantity integer default 0
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
  if coalesce(p_room_quantity, 0) < 0 then
    raise exception 'Rooms quantity cannot be negative';
  end if;
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
    assigned_manager_id, room_quantity, created_by, updated_by
  ) values (
    p_organization_id, p_tender_id, p_district_id, trim(p_name),
    nullif(trim(p_code), ''), nullif(trim(p_address), ''),
    p_assigned_manager_id, coalesce(p_room_quantity, 0), auth.uid(), auth.uid()
  ) returning id into new_id;

  insert into public.material_audit_logs (
    organization_id, actor_id, entity_table, entity_id, action, metadata
  ) values (
    p_organization_id, auth.uid(), 'schools', new_id, 'create',
    jsonb_build_object(
      'name', trim(p_name),
      'tender_id', p_tender_id,
      'district_id', p_district_id,
      'room_quantity', coalesce(p_room_quantity, 0)
    )
  );
  return new_id;
end;
$$;

drop function if exists public.update_material_school(uuid, uuid, uuid, uuid, text, text, text, text, integer, uuid);
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
  p_assigned_manager_id uuid default null,
  p_room_quantity integer default 0
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
  if p_progress_percent < 0 or p_progress_percent > 100 then
    raise exception 'Progress must be between 0 and 100';
  end if;
  if coalesce(p_room_quantity, 0) < 0 then
    raise exception 'Rooms quantity cannot be negative';
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
      room_quantity = coalesce(p_room_quantity, 0),
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
    jsonb_build_object(
      'name', trim(p_name),
      'status', coalesce(nullif(trim(p_status), ''), 'not_started'),
      'progress_percent', p_progress_percent,
      'room_quantity', coalesce(p_room_quantity, 0)
    )
  );
end;
$$;

create or replace function public.add_material_school_evidence(
  p_organization_id uuid,
  p_school_id uuid,
  p_room_quantity integer default null,
  p_photo_paths text[] default '{}'::text[],
  p_gps_latitude numeric default null,
  p_gps_longitude numeric default null,
  p_gps_accuracy_meters numeric default null,
  p_gps_captured_at timestamptz default null
)
returns void
language plpgsql
security definer
set search_path = public, ledger_private, pg_temp
as $$
declare
  clean_paths text[];
begin
  if not ledger_private.org_has_role(
    p_organization_id,
    array['owner','manager','accountant','site_staff']::public.org_member_role[]
  ) then raise exception 'Not permitted to update school evidence'; end if;
  if p_room_quantity is not null and p_room_quantity < 0 then
    raise exception 'Rooms quantity cannot be negative';
  end if;
  if (p_gps_latitude is null) <> (p_gps_longitude is null) then
    raise exception 'GPS latitude and longitude must be provided together';
  end if;
  if p_gps_latitude is not null and (p_gps_latitude < -90 or p_gps_latitude > 90) then
    raise exception 'GPS latitude is out of range';
  end if;
  if p_gps_longitude is not null and (p_gps_longitude < -180 or p_gps_longitude > 180) then
    raise exception 'GPS longitude is out of range';
  end if;

  select coalesce(array_agg(path), '{}'::text[]) into clean_paths
  from (
    select distinct nullif(trim(path), '') as path
    from unnest(coalesce(p_photo_paths, '{}'::text[])) as raw(path)
  ) cleaned
  where path is not null;

  update public.schools
  set room_quantity = coalesce(p_room_quantity, room_quantity),
      gps_photo_paths = case
        when cardinality(clean_paths) = 0 then gps_photo_paths
        else (
          select coalesce(array_agg(distinct path), '{}'::text[])
          from unnest(gps_photo_paths || clean_paths) as merged(path)
          where nullif(trim(path), '') is not null
        )
      end,
      gps_latitude = coalesce(p_gps_latitude, gps_latitude),
      gps_longitude = coalesce(p_gps_longitude, gps_longitude),
      gps_accuracy_meters = coalesce(p_gps_accuracy_meters, gps_accuracy_meters),
      gps_captured_at = case
        when p_gps_latitude is not null
          or p_gps_longitude is not null
          or cardinality(clean_paths) > 0
          then coalesce(p_gps_captured_at, now())
        else gps_captured_at
      end,
      updated_by = auth.uid(),
      updated_at = now()
  where id = p_school_id
    and organization_id = p_organization_id
    and deleted_at is null;
  if not found then raise exception 'School not found'; end if;

  insert into public.material_audit_logs (
    organization_id, actor_id, entity_table, entity_id, action, metadata
  ) values (
    p_organization_id, auth.uid(), 'schools', p_school_id, 'add_evidence',
    jsonb_build_object(
      'room_quantity', p_room_quantity,
      'photo_count', cardinality(clean_paths),
      'gps_latitude', p_gps_latitude,
      'gps_longitude', p_gps_longitude
    )
  );
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

create or replace function public.receive_material(
  p_organization_id uuid,
  p_tender_id uuid,
  p_warehouse_id uuid,
  p_material_id uuid,
  p_quantity numeric,
  p_supplier_name text default null,
  p_invoice_number text default null,
  p_received_date date default current_date,
  p_notes text default null
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
  ) then raise exception 'Not permitted to receive material'; end if;
  if p_quantity is null or p_quantity <= 0 then
    raise exception 'Quantity must be greater than zero';
  end if;
  if not exists (select 1 from public.tenders where id = p_tender_id and organization_id = p_organization_id and deleted_at is null)
    or not exists (select 1 from public.warehouses where id = p_warehouse_id and organization_id = p_organization_id and deleted_at is null)
    or not exists (select 1 from public.material_items where id = p_material_id and organization_id = p_organization_id and deleted_at is null)
  then raise exception 'Tender, warehouse, or material does not belong to organization'; end if;

  insert into public.material_receipts (
    organization_id, tender_id, warehouse_id, material_id, quantity,
    supplier_name, invoice_number, received_date, notes, created_by, updated_by
  ) values (
    p_organization_id, p_tender_id, p_warehouse_id, p_material_id, p_quantity,
    p_supplier_name, p_invoice_number, p_received_date, p_notes, auth.uid(), auth.uid()
  ) returning id into new_id;

  insert into public.warehouse_stock (
    organization_id, warehouse_id, material_id, total_received
  ) values (p_organization_id, p_warehouse_id, p_material_id, p_quantity)
  on conflict (warehouse_id, material_id) do update
    set total_received = public.warehouse_stock.total_received + excluded.total_received,
        updated_at = now();

  insert into public.material_audit_logs (
    organization_id, actor_id, entity_table, entity_id, action, metadata
  ) values (
    p_organization_id, auth.uid(), 'material_receipts', new_id, 'receive',
    jsonb_build_object('warehouse_id', p_warehouse_id, 'material_id', p_material_id, 'quantity', p_quantity)
  );
  return new_id;
end;
$$;

create or replace function public.issue_material_to_school(
  p_organization_id uuid,
  p_tender_id uuid,
  p_warehouse_id uuid,
  p_school_id uuid,
  p_manager_id uuid,
  p_material_id uuid,
  p_quantity numeric,
  p_issue_date date default current_date,
  p_notes text default null
)
returns uuid
language plpgsql
security definer
set search_path = public, ledger_private, pg_temp
as $$
declare
  new_id uuid;
  available numeric;
begin
  if not ledger_private.org_has_role(
    p_organization_id,
    array['owner','manager','accountant']::public.org_member_role[]
  ) then raise exception 'Not permitted to issue material'; end if;
  if p_quantity is null or p_quantity <= 0 then
    raise exception 'Quantity must be greater than zero';
  end if;
  if not exists (select 1 from public.tenders where id = p_tender_id and organization_id = p_organization_id and deleted_at is null)
    or not exists (select 1 from public.warehouses where id = p_warehouse_id and organization_id = p_organization_id and deleted_at is null)
    or not exists (select 1 from public.schools where id = p_school_id and organization_id = p_organization_id and tender_id = p_tender_id and deleted_at is null)
    or not exists (select 1 from public.material_items where id = p_material_id and organization_id = p_organization_id and deleted_at is null)
    or (p_manager_id is not null and not exists (select 1 from public.site_managers where id = p_manager_id and organization_id = p_organization_id and deleted_at is null))
  then raise exception 'Issue references do not belong to organization or tender'; end if;

  select ws.remaining_stock into available
  from public.warehouse_stock ws
  where ws.organization_id = p_organization_id
    and ws.warehouse_id = p_warehouse_id
    and ws.material_id = p_material_id
  for update;
  if available is null or available < p_quantity then
    raise exception 'Insufficient stock. Available: %', coalesce(available, 0);
  end if;

  insert into public.material_issues (
    organization_id, tender_id, warehouse_id, school_id, manager_id,
    material_id, quantity, issue_date, notes, created_by, updated_by
  ) values (
    p_organization_id, p_tender_id, p_warehouse_id, p_school_id, p_manager_id,
    p_material_id, p_quantity, p_issue_date, p_notes, auth.uid(), auth.uid()
  ) returning id into new_id;

  update public.warehouse_stock
    set total_issued = total_issued + p_quantity, updated_at = now()
  where organization_id = p_organization_id
    and warehouse_id = p_warehouse_id and material_id = p_material_id;

  insert into public.school_material_requirements (
    organization_id, tender_id, school_id, material_id, required_quantity,
    issued_quantity, status, created_by, updated_by
  ) values (
    p_organization_id, p_tender_id, p_school_id, p_material_id, p_quantity,
    p_quantity, 'complete', auth.uid(), auth.uid()
  )
  on conflict (school_id, material_id) do update
    set issued_quantity = public.school_material_requirements.issued_quantity + p_quantity,
        status = case
          when public.school_material_requirements.issued_quantity + p_quantity
            - public.school_material_requirements.returned_quantity
            >= public.school_material_requirements.required_quantity then 'complete'
          when public.school_material_requirements.issued_quantity + p_quantity
            - public.school_material_requirements.returned_quantity > 0 then 'partial'
          else 'pending'
        end,
        updated_by = auth.uid(),
        updated_at = now();

  insert into public.material_audit_logs (
    organization_id, actor_id, entity_table, entity_id, action, metadata
  ) values (
    p_organization_id, auth.uid(), 'material_issues', new_id, 'issue',
    jsonb_build_object('warehouse_id', p_warehouse_id, 'school_id', p_school_id, 'material_id', p_material_id, 'quantity', p_quantity)
  );
  return new_id;
end;
$$;

create or replace function public.return_material_from_school(
  p_organization_id uuid,
  p_tender_id uuid,
  p_warehouse_id uuid,
  p_school_id uuid,
  p_manager_id uuid,
  p_material_id uuid,
  p_quantity numeric,
  p_return_date date default current_date,
  p_reason text default null,
  p_notes text default null
)
returns uuid
language plpgsql
security definer
set search_path = public, ledger_private, pg_temp
as $$
declare
  new_id uuid;
  issued numeric;
  returned numeric;
begin
  if not ledger_private.org_has_role(
    p_organization_id,
    array['owner','manager','accountant']::public.org_member_role[]
  ) then raise exception 'Not permitted to return material'; end if;
  if p_quantity is null or p_quantity <= 0 then
    raise exception 'Quantity must be greater than zero';
  end if;
  if not exists (select 1 from public.tenders where id = p_tender_id and organization_id = p_organization_id and deleted_at is null)
    or not exists (select 1 from public.warehouses where id = p_warehouse_id and organization_id = p_organization_id and deleted_at is null)
    or not exists (select 1 from public.schools where id = p_school_id and organization_id = p_organization_id and tender_id = p_tender_id and deleted_at is null)
    or not exists (select 1 from public.material_items where id = p_material_id and organization_id = p_organization_id and deleted_at is null)
    or (p_manager_id is not null and not exists (select 1 from public.site_managers where id = p_manager_id and organization_id = p_organization_id and deleted_at is null))
  then raise exception 'Return references do not belong to organization or tender'; end if;

  select r.issued_quantity, r.returned_quantity into issued, returned
  from public.school_material_requirements r
  where r.organization_id = p_organization_id
    and r.school_id = p_school_id and r.material_id = p_material_id
    and r.deleted_at is null
  for update;
  if issued is null or issued - returned < p_quantity then
    raise exception 'Return exceeds material currently issued to school';
  end if;

  insert into public.material_returns (
    organization_id, tender_id, warehouse_id, school_id, manager_id,
    material_id, quantity, return_date, reason, notes, created_by, updated_by
  ) values (
    p_organization_id, p_tender_id, p_warehouse_id, p_school_id, p_manager_id,
    p_material_id, p_quantity, p_return_date, p_reason, p_notes, auth.uid(), auth.uid()
  ) returning id into new_id;

  insert into public.warehouse_stock (
    organization_id, warehouse_id, material_id, total_returned
  ) values (p_organization_id, p_warehouse_id, p_material_id, p_quantity)
  on conflict (warehouse_id, material_id) do update
    set total_returned = public.warehouse_stock.total_returned + excluded.total_returned,
        updated_at = now();

  update public.school_material_requirements
    set returned_quantity = returned_quantity + p_quantity,
        status = case
          when issued_quantity - (returned_quantity + p_quantity) >= required_quantity
            then 'complete'
          when issued_quantity - (returned_quantity + p_quantity) > 0
            then 'partial'
          else 'pending'
        end,
        updated_by = auth.uid(),
        updated_at = now()
  where organization_id = p_organization_id
    and school_id = p_school_id and material_id = p_material_id;

  insert into public.material_audit_logs (
    organization_id, actor_id, entity_table, entity_id, action, metadata
  ) values (
    p_organization_id, auth.uid(), 'material_returns', new_id, 'return',
    jsonb_build_object('warehouse_id', p_warehouse_id, 'school_id', p_school_id, 'material_id', p_material_id, 'quantity', p_quantity)
  );
  return new_id;
end;
$$;

revoke all on function public.create_material_school(uuid, uuid, uuid, text, text, text, uuid, integer) from public, anon;
revoke all on function public.update_material_school(uuid, uuid, uuid, uuid, text, text, text, text, integer, uuid, integer) from public, anon;
revoke all on function public.add_material_school_evidence(uuid, uuid, integer, text[], numeric, numeric, numeric, timestamptz) from public, anon;
revoke all on function public.update_material_school_progress(uuid, uuid, integer, text) from public, anon;
revoke all on function public.receive_material(uuid, uuid, uuid, uuid, numeric, text, text, date, text) from public, anon;
revoke all on function public.issue_material_to_school(uuid, uuid, uuid, uuid, uuid, uuid, numeric, date, text) from public, anon;
revoke all on function public.return_material_from_school(uuid, uuid, uuid, uuid, uuid, uuid, numeric, date, text, text) from public, anon;

grant execute on function public.create_material_school(uuid, uuid, uuid, text, text, text, uuid, integer) to authenticated;
grant execute on function public.update_material_school(uuid, uuid, uuid, uuid, text, text, text, text, integer, uuid, integer) to authenticated;
grant execute on function public.add_material_school_evidence(uuid, uuid, integer, text[], numeric, numeric, numeric, timestamptz) to authenticated;
grant execute on function public.update_material_school_progress(uuid, uuid, integer, text) to authenticated;
grant execute on function public.receive_material(uuid, uuid, uuid, uuid, numeric, text, text, date, text) to authenticated;
grant execute on function public.issue_material_to_school(uuid, uuid, uuid, uuid, uuid, uuid, numeric, date, text) to authenticated;
grant execute on function public.return_material_from_school(uuid, uuid, uuid, uuid, uuid, uuid, numeric, date, text, text) to authenticated;
