-- Atomic material operations and dashboard summaries.

create or replace function public.material_dashboard_summary(
  p_organization_id uuid,
  p_tender_id uuid default null,
  p_district_id uuid default null,
  p_warehouse_id uuid default null
)
returns table (
  total_schools bigint,
  running_schools bigint,
  completed_schools bigint,
  pending_schools bigint,
  total_items_in_warehouse bigint,
  low_stock_items bigint,
  total_received_quantity numeric,
  total_issued_quantity numeric,
  total_remaining_quantity numeric
)
language plpgsql
stable
security definer
set search_path = public, ledger_private, pg_temp
as $$
begin
  if not ledger_private.is_org_member(p_organization_id) then
    raise exception 'Not permitted to view material dashboard';
  end if;

  return query
  with school_counts as (
    select
      count(*)::bigint as total_schools,
      count(*) filter (where s.status = 'running')::bigint as running_schools,
      count(*) filter (where s.status = 'completed')::bigint as completed_schools,
      count(*) filter (where s.status in ('not_started', 'on_hold'))::bigint as pending_schools
    from public.schools s
    where s.organization_id = p_organization_id
      and s.deleted_at is null
      and (p_tender_id is null or s.tender_id = p_tender_id)
      and (p_district_id is null or s.district_id = p_district_id)
  ),
  stock_counts as (
    select
      count(*) filter (where ws.remaining_stock > 0)::bigint as total_items,
      count(*) filter (
        where ws.remaining_stock <= mi.low_stock_threshold
      )::bigint as low_items,
      coalesce(sum(ws.total_received), 0)::numeric as received,
      coalesce(sum(ws.total_issued), 0)::numeric as issued,
      coalesce(sum(ws.remaining_stock), 0)::numeric as remaining
    from public.warehouse_stock ws
    join public.material_items mi on mi.id = ws.material_id and mi.deleted_at is null
    join public.warehouses w on w.id = ws.warehouse_id and w.deleted_at is null
    where ws.organization_id = p_organization_id
      and (p_warehouse_id is null or ws.warehouse_id = p_warehouse_id)
      and (p_district_id is null or w.district_id = p_district_id)
  )
  select sc.total_schools, sc.running_schools, sc.completed_schools,
    sc.pending_schools, st.total_items, st.low_items,
    st.received, st.issued, st.remaining
  from school_counts sc cross join stock_counts st;
end;
$$;

create or replace function public.warehouse_stock_summary(
  p_organization_id uuid,
  p_warehouse_id uuid,
  p_tender_id uuid default null
)
returns table (
  material_id uuid,
  material_name text,
  unit text,
  total_received numeric,
  total_issued numeric,
  remaining_stock numeric,
  threshold numeric,
  stock_status text
)
language plpgsql
stable
security definer
set search_path = public, ledger_private, pg_temp
as $$
begin
  if not ledger_private.is_org_member(p_organization_id) then
    raise exception 'Not permitted to view warehouse stock';
  end if;

  return query
  with filtered as (
    select
      mi.id,
      mi.name,
      mi.unit,
      mi.low_stock_threshold,
      case when p_tender_id is null then ws.total_received else coalesce((
        select sum(r.quantity) from public.material_receipts r
        where r.organization_id = p_organization_id
          and r.warehouse_id = p_warehouse_id and r.material_id = mi.id
          and r.tender_id = p_tender_id and r.deleted_at is null
      ), 0) end as received,
      case when p_tender_id is null then ws.total_issued else coalesce((
        select sum(i.quantity) from public.material_issues i
        where i.organization_id = p_organization_id
          and i.warehouse_id = p_warehouse_id and i.material_id = mi.id
          and i.tender_id = p_tender_id and i.deleted_at is null
      ), 0) end as issued,
      case when p_tender_id is null then ws.total_returned else coalesce((
        select sum(r.quantity) from public.material_returns r
        where r.organization_id = p_organization_id
          and r.warehouse_id = p_warehouse_id and r.material_id = mi.id
          and r.tender_id = p_tender_id and r.deleted_at is null
      ), 0) end as returned
    from public.warehouse_stock ws
    join public.material_items mi on mi.id = ws.material_id
    where ws.organization_id = p_organization_id
      and ws.warehouse_id = p_warehouse_id
      and mi.deleted_at is null
  )
  select f.id, f.name, f.unit, f.received, f.issued,
    (f.received + f.returned - f.issued)::numeric,
    f.low_stock_threshold,
    case
      when f.received + f.returned - f.issued <= 0 then 'out_of_stock'
      when f.received + f.returned - f.issued <= f.low_stock_threshold then 'low'
      else 'in_stock'
    end
  from filtered f
  order by f.name;
end;
$$;

create or replace function public.school_requirement_vs_issue(
  p_organization_id uuid,
  p_tender_id uuid,
  p_district_id uuid default null
)
returns table (
  school_id uuid,
  school_name text,
  total_items bigint,
  required_percent numeric,
  issued_percent numeric,
  pending_percent numeric,
  status text
)
language plpgsql
stable
security definer
set search_path = public, ledger_private, pg_temp
as $$
begin
  if not ledger_private.is_org_member(p_organization_id) then
    raise exception 'Not permitted to view school requirements';
  end if;

  return query
  select
    s.id,
    s.name,
    count(r.id)::bigint,
    case when coalesce(sum(r.required_quantity), 0) > 0 then 100::numeric else 0::numeric end,
    case when coalesce(sum(r.required_quantity), 0) > 0
      then least(100, round(
        (sum(greatest(r.issued_quantity - r.returned_quantity, 0))
          / nullif(sum(r.required_quantity), 0)) * 100, 2
      ))
      else 0::numeric
    end,
    case when coalesce(sum(r.required_quantity), 0) > 0
      then greatest(0, 100 - least(100, round(
        (sum(greatest(r.issued_quantity - r.returned_quantity, 0))
          / nullif(sum(r.required_quantity), 0)) * 100, 2
      )))
      else 100::numeric
    end,
    case
      when coalesce(sum(r.required_quantity), 0) > 0
        and sum(greatest(r.issued_quantity - r.returned_quantity, 0)) >= sum(r.required_quantity)
        then 'complete'
      when coalesce(sum(greatest(r.issued_quantity - r.returned_quantity, 0)), 0) > 0
        then 'partial'
      else 'pending'
    end
  from public.schools s
  left join public.school_material_requirements r
    on r.school_id = s.id and r.deleted_at is null
  where s.organization_id = p_organization_id
    and s.tender_id = p_tender_id
    and s.deleted_at is null
    and (p_district_id is null or s.district_id = p_district_id)
  group by s.id, s.name
  order by s.name;
end;
$$;

create or replace function public.recent_material_issues(
  p_organization_id uuid,
  p_tender_id uuid default null,
  p_district_id uuid default null,
  p_limit integer default 10
)
returns table (
  issue_id uuid,
  manager_name text,
  school_name text,
  issue_date date,
  summary_text text,
  material_count bigint,
  total_quantity numeric
)
language plpgsql
stable
security definer
set search_path = public, ledger_private, pg_temp
as $$
begin
  if not ledger_private.is_org_member(p_organization_id) then
    raise exception 'Not permitted to view material issues';
  end if;

  return query
  select
    (array_agg(i.id order by i.created_at desc))[1],
    coalesce(sm.full_name, 'Unassigned'),
    s.name,
    i.issue_date,
    string_agg(
      trim(to_char(i.quantity, 'FM999999999990.##')) || ' ' || mi.name,
      ', ' order by mi.name
    ),
    count(distinct i.material_id)::bigint,
    sum(i.quantity)::numeric
  from public.material_issues i
  join public.schools s on s.id = i.school_id and s.deleted_at is null
  join public.material_items mi on mi.id = i.material_id and mi.deleted_at is null
  left join public.site_managers sm on sm.id = i.manager_id and sm.deleted_at is null
  where i.organization_id = p_organization_id
    and i.deleted_at is null
    and (p_tender_id is null or i.tender_id = p_tender_id)
    and (p_district_id is null or s.district_id = p_district_id)
  group by sm.id, sm.full_name, s.id, s.name, i.issue_date
  order by i.issue_date desc
  limit greatest(1, least(coalesce(p_limit, 10), 100));
end;
$$;

create or replace function public.low_stock_alerts(
  p_organization_id uuid,
  p_warehouse_id uuid default null
)
returns table (
  material_id uuid,
  material_name text,
  remaining_stock numeric,
  unit text,
  alert_level text
)
language plpgsql
stable
security definer
set search_path = public, ledger_private, pg_temp
as $$
begin
  if not ledger_private.is_org_member(p_organization_id) then
    raise exception 'Not permitted to view low stock alerts';
  end if;

  return query
  select
    mi.id,
    mi.name,
    sum(ws.remaining_stock)::numeric,
    mi.unit,
    case
      when sum(ws.remaining_stock) <= 0 then 'out'
      when sum(ws.remaining_stock) <= mi.low_stock_threshold then 'low'
      else 'medium'
    end
  from public.warehouse_stock ws
  join public.material_items mi on mi.id = ws.material_id and mi.deleted_at is null
  where ws.organization_id = p_organization_id
    and (p_warehouse_id is null or ws.warehouse_id = p_warehouse_id)
  group by mi.id, mi.name, mi.unit, mi.low_stock_threshold
  having sum(ws.remaining_stock) <= greatest(mi.low_stock_threshold * 2, mi.low_stock_threshold)
  order by sum(ws.remaining_stock), mi.name;
end;
$$;

create or replace function public.manager_material_issue_summary(
  p_organization_id uuid,
  p_tender_id uuid,
  p_district_id uuid default null
)
returns table (
  manager_id uuid,
  manager_name text,
  school_name text,
  material_id uuid,
  material_name text,
  unit text,
  issued_quantity numeric,
  total_items numeric
)
language plpgsql
stable
security definer
set search_path = public, ledger_private, pg_temp
as $$
begin
  if not ledger_private.is_org_member(p_organization_id) then
    raise exception 'Not permitted to view manager material summary';
  end if;

  return query
  select
    sm.id,
    coalesce(sm.full_name, 'Unassigned'),
    s.name,
    mi.id,
    mi.name,
    mi.unit,
    sum(i.quantity)::numeric,
    sum(sum(i.quantity)) over (partition by sm.id, s.id)::numeric
  from public.material_issues i
  join public.schools s on s.id = i.school_id and s.deleted_at is null
  join public.material_items mi on mi.id = i.material_id and mi.deleted_at is null
  left join public.site_managers sm on sm.id = i.manager_id and sm.deleted_at is null
  where i.organization_id = p_organization_id
    and i.tender_id = p_tender_id
    and i.deleted_at is null
    and (p_district_id is null or s.district_id = p_district_id)
  group by sm.id, sm.full_name, s.id, s.name, mi.id, mi.name, mi.unit
  order by coalesce(sm.full_name, 'Unassigned'), s.name, mi.name;
end;
$$;

create or replace function public.create_material_item(
  p_organization_id uuid,
  p_name text,
  p_unit text,
  p_sku text default null,
  p_category text default null,
  p_low_stock_threshold numeric default 0
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
  ) then raise exception 'Not permitted to create material items'; end if;
  if nullif(trim(p_name), '') is null or nullif(trim(p_unit), '') is null then
    raise exception 'Material name and unit are required';
  end if;
  if p_low_stock_threshold is null or p_low_stock_threshold < 0 then
    raise exception 'Low stock threshold cannot be negative';
  end if;

  insert into public.material_items (
    organization_id, name, unit, sku, category, low_stock_threshold,
    created_by, updated_by
  ) values (
    p_organization_id, trim(p_name), trim(p_unit), nullif(trim(p_sku), ''),
    nullif(trim(p_category), ''), p_low_stock_threshold, auth.uid(), auth.uid()
  ) returning id into new_id;

  insert into public.material_audit_logs (
    organization_id, actor_id, entity_table, entity_id, action, metadata
  ) values (
    p_organization_id, auth.uid(), 'material_items', new_id, 'create',
    jsonb_build_object('name', trim(p_name), 'unit', trim(p_unit), 'low_stock_threshold', p_low_stock_threshold)
  );
  return new_id;
end;
$$;

create or replace function public.set_school_material_requirement(
  p_organization_id uuid,
  p_tender_id uuid,
  p_school_id uuid,
  p_material_id uuid,
  p_required_quantity numeric
)
returns uuid
language plpgsql
security definer
set search_path = public, ledger_private, pg_temp
as $$
declare
  requirement_id uuid;
begin
  if not ledger_private.org_has_role(
    p_organization_id,
    array['owner','manager','accountant']::public.org_member_role[]
  ) then raise exception 'Not permitted to manage school requirements'; end if;
  if p_required_quantity is null or p_required_quantity <= 0 then
    raise exception 'Required quantity must be greater than zero';
  end if;
  if not exists (
    select 1 from public.tenders
    where id = p_tender_id and organization_id = p_organization_id
      and deleted_at is null
  ) or not exists (
    select 1 from public.schools
    where id = p_school_id and organization_id = p_organization_id
      and tender_id = p_tender_id and deleted_at is null
  ) or not exists (
    select 1 from public.material_items
    where id = p_material_id and organization_id = p_organization_id
      and deleted_at is null
  ) then
    raise exception 'Requirement references do not belong to organization or tender';
  end if;

  insert into public.school_material_requirements (
    organization_id, tender_id, school_id, material_id, required_quantity,
    status, created_by, updated_by
  ) values (
    p_organization_id, p_tender_id, p_school_id, p_material_id,
    p_required_quantity, 'pending', auth.uid(), auth.uid()
  )
  on conflict (school_id, material_id) do update
    set required_quantity = excluded.required_quantity,
        status = case
          when public.school_material_requirements.issued_quantity
            - public.school_material_requirements.returned_quantity
            >= excluded.required_quantity then 'complete'
          when public.school_material_requirements.issued_quantity
            - public.school_material_requirements.returned_quantity > 0 then 'partial'
          else 'pending'
        end,
        updated_by = auth.uid(),
        updated_at = now(),
        deleted_at = null
  returning id into requirement_id;

  insert into public.material_audit_logs (
    organization_id, actor_id, entity_table, entity_id, action, metadata
  ) values (
    p_organization_id, auth.uid(), 'school_material_requirements',
    requirement_id, 'set_requirement',
    jsonb_build_object('school_id', p_school_id, 'material_id', p_material_id, 'required_quantity', p_required_quantity)
  );
  return requirement_id;
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
    array['owner','manager','accountant','site_staff']::public.org_member_role[]
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
    array['owner','manager','accountant','site_staff']::public.org_member_role[]
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
    array['owner','manager','accountant','site_staff']::public.org_member_role[]
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

revoke all on function public.material_dashboard_summary(uuid, uuid, uuid, uuid) from public, anon;
revoke all on function public.warehouse_stock_summary(uuid, uuid, uuid) from public, anon;
revoke all on function public.school_requirement_vs_issue(uuid, uuid, uuid) from public, anon;
revoke all on function public.recent_material_issues(uuid, uuid, uuid, integer) from public, anon;
revoke all on function public.low_stock_alerts(uuid, uuid) from public, anon;
revoke all on function public.manager_material_issue_summary(uuid, uuid, uuid) from public, anon;
revoke all on function public.create_material_item(uuid, text, text, text, text, numeric) from public, anon;
revoke all on function public.set_school_material_requirement(uuid, uuid, uuid, uuid, numeric) from public, anon;
revoke all on function public.receive_material(uuid, uuid, uuid, uuid, numeric, text, text, date, text) from public, anon;
revoke all on function public.issue_material_to_school(uuid, uuid, uuid, uuid, uuid, uuid, numeric, date, text) from public, anon;
revoke all on function public.return_material_from_school(uuid, uuid, uuid, uuid, uuid, uuid, numeric, date, text, text) from public, anon;

grant execute on function public.material_dashboard_summary(uuid, uuid, uuid, uuid) to authenticated;
grant execute on function public.warehouse_stock_summary(uuid, uuid, uuid) to authenticated;
grant execute on function public.school_requirement_vs_issue(uuid, uuid, uuid) to authenticated;
grant execute on function public.recent_material_issues(uuid, uuid, uuid, integer) to authenticated;
grant execute on function public.low_stock_alerts(uuid, uuid) to authenticated;
grant execute on function public.manager_material_issue_summary(uuid, uuid, uuid) to authenticated;
grant execute on function public.create_material_item(uuid, text, text, text, text, numeric) to authenticated;
grant execute on function public.set_school_material_requirement(uuid, uuid, uuid, uuid, numeric) to authenticated;
grant execute on function public.receive_material(uuid, uuid, uuid, uuid, numeric, text, text, date, text) to authenticated;
grant execute on function public.issue_material_to_school(uuid, uuid, uuid, uuid, uuid, uuid, numeric, date, text) to authenticated;
grant execute on function public.return_material_from_school(uuid, uuid, uuid, uuid, uuid, uuid, numeric, date, text, text) to authenticated;
