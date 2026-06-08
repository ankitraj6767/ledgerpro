-- Allow admins to delete configured material master data even when test/history
-- rows exist. Deletes remain soft-deletes for auditability, and stock totals are
-- rebuilt from the remaining active transaction rows so dashboards stay honest.

create or replace function ledger_private.rebuild_material_stock_for_org(
  target_org_id uuid
)
returns void
language plpgsql
security definer
set search_path = public, ledger_private, pg_temp
as $$
begin
  delete from public.warehouse_stock
  where organization_id = target_org_id;

  insert into public.warehouse_stock (
    organization_id,
    warehouse_id,
    material_id,
    total_received,
    total_issued,
    total_returned
  )
  with stock_events as (
    select
      r.organization_id,
      r.warehouse_id,
      r.material_id,
      sum(r.quantity)::numeric as received,
      0::numeric as issued,
      0::numeric as returned
    from public.material_receipts r
    join public.tenders t on t.id = r.tender_id and t.deleted_at is null
    join public.warehouses w on w.id = r.warehouse_id and w.deleted_at is null
    join public.material_items mi on mi.id = r.material_id and mi.deleted_at is null
    where r.organization_id = target_org_id
      and r.deleted_at is null
    group by r.organization_id, r.warehouse_id, r.material_id

    union all

    select
      i.organization_id,
      i.warehouse_id,
      i.material_id,
      0::numeric as received,
      sum(i.quantity)::numeric as issued,
      0::numeric as returned
    from public.material_issues i
    join public.tenders t on t.id = i.tender_id and t.deleted_at is null
    join public.warehouses w on w.id = i.warehouse_id and w.deleted_at is null
    join public.schools s on s.id = i.school_id and s.deleted_at is null
    join public.material_items mi on mi.id = i.material_id and mi.deleted_at is null
    where i.organization_id = target_org_id
      and i.deleted_at is null
    group by i.organization_id, i.warehouse_id, i.material_id

    union all

    select
      mr.organization_id,
      mr.warehouse_id,
      mr.material_id,
      0::numeric as received,
      0::numeric as issued,
      sum(mr.quantity)::numeric as returned
    from public.material_returns mr
    join public.tenders t on t.id = mr.tender_id and t.deleted_at is null
    join public.warehouses w on w.id = mr.warehouse_id and w.deleted_at is null
    join public.schools s on s.id = mr.school_id and s.deleted_at is null
    join public.material_items mi on mi.id = mr.material_id and mi.deleted_at is null
    where mr.organization_id = target_org_id
      and mr.deleted_at is null
    group by mr.organization_id, mr.warehouse_id, mr.material_id
  ),
  rolled_up as (
    select
      organization_id,
      warehouse_id,
      material_id,
      coalesce(sum(received), 0)::numeric as total_received,
      coalesce(sum(issued), 0)::numeric as total_issued,
      coalesce(sum(returned), 0)::numeric as total_returned
    from stock_events
    group by organization_id, warehouse_id, material_id
  )
  select
    organization_id,
    warehouse_id,
    material_id,
    total_received,
    total_issued,
    total_returned
  from rolled_up
  where total_received > 0
     or total_issued > 0
     or total_returned > 0;
end;
$$;

create or replace function ledger_private.rebuild_material_requirements_for_org(
  target_org_id uuid
)
returns void
language plpgsql
security definer
set search_path = public, ledger_private, pg_temp
as $$
begin
  with issued as (
    select
      r.id as requirement_id,
      coalesce(sum(i.quantity), 0)::numeric as quantity
    from public.school_material_requirements r
    left join public.material_issues i
      on i.organization_id = r.organization_id
      and i.tender_id = r.tender_id
      and i.school_id = r.school_id
      and i.material_id = r.material_id
      and i.deleted_at is null
      and exists (
        select 1 from public.warehouses w
        where w.id = i.warehouse_id and w.deleted_at is null
      )
    where r.organization_id = target_org_id
      and r.deleted_at is null
    group by r.id
  ),
  returned as (
    select
      r.id as requirement_id,
      coalesce(sum(mr.quantity), 0)::numeric as quantity
    from public.school_material_requirements r
    left join public.material_returns mr
      on mr.organization_id = r.organization_id
      and mr.tender_id = r.tender_id
      and mr.school_id = r.school_id
      and mr.material_id = r.material_id
      and mr.deleted_at is null
      and exists (
        select 1 from public.warehouses w
        where w.id = mr.warehouse_id and w.deleted_at is null
      )
    where r.organization_id = target_org_id
      and r.deleted_at is null
    group by r.id
  ),
  totals as (
    select
      r.id,
      coalesce(i.quantity, 0)::numeric as issued_quantity,
      least(coalesce(ret.quantity, 0), coalesce(i.quantity, 0))::numeric
        as returned_quantity
    from public.school_material_requirements r
    left join issued i on i.requirement_id = r.id
    left join returned ret on ret.requirement_id = r.id
    where r.organization_id = target_org_id
      and r.deleted_at is null
  )
  update public.school_material_requirements r
  set issued_quantity = totals.issued_quantity,
      returned_quantity = totals.returned_quantity,
      status = case
        when totals.issued_quantity - totals.returned_quantity
          >= r.required_quantity then 'complete'
        when totals.issued_quantity - totals.returned_quantity > 0 then 'partial'
        else 'pending'
      end,
      updated_by = auth.uid(),
      updated_at = now()
  from totals
  where r.id = totals.id;
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

  update public.material_receipts
  set deleted_at = now(), updated_by = auth.uid(), updated_at = now()
  where organization_id = p_organization_id
    and tender_id = p_tender_id
    and deleted_at is null;

  update public.material_issues
  set deleted_at = now(), updated_by = auth.uid(), updated_at = now()
  where organization_id = p_organization_id
    and tender_id = p_tender_id
    and deleted_at is null;

  update public.material_returns
  set deleted_at = now(), updated_by = auth.uid(), updated_at = now()
  where organization_id = p_organization_id
    and tender_id = p_tender_id
    and deleted_at is null;

  update public.school_material_requirements
  set deleted_at = now(), updated_by = auth.uid(), updated_at = now()
  where organization_id = p_organization_id
    and tender_id = p_tender_id
    and deleted_at is null;

  update public.schools
  set deleted_at = now(), updated_by = auth.uid(), updated_at = now()
  where organization_id = p_organization_id
    and tender_id = p_tender_id
    and deleted_at is null;

  update public.tenders
  set deleted_at = now(), updated_by = auth.uid(), updated_at = now()
  where id = p_tender_id
    and organization_id = p_organization_id
    and deleted_at is null;
  if not found then raise exception 'Tender not found'; end if;

  perform ledger_private.rebuild_material_requirements_for_org(p_organization_id);
  perform ledger_private.rebuild_material_stock_for_org(p_organization_id);

  insert into public.material_audit_logs (
    organization_id, actor_id, entity_table, entity_id, action, metadata
  ) values (
    p_organization_id, auth.uid(), 'tenders', p_tender_id, 'delete',
    jsonb_build_object('cascade', true)
  );
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

  update public.material_receipts r
  set deleted_at = now(), updated_by = auth.uid(), updated_at = now()
  where r.organization_id = p_organization_id
    and r.deleted_at is null
    and exists (
      select 1 from public.warehouses w
      where w.id = r.warehouse_id
        and w.organization_id = p_organization_id
        and w.district_id = p_district_id
        and w.deleted_at is null
    );

  update public.material_issues i
  set deleted_at = now(), updated_by = auth.uid(), updated_at = now()
  where i.organization_id = p_organization_id
    and i.deleted_at is null
    and (
      exists (
        select 1 from public.warehouses w
        where w.id = i.warehouse_id
          and w.organization_id = p_organization_id
          and w.district_id = p_district_id
          and w.deleted_at is null
      )
      or exists (
        select 1 from public.schools s
        where s.id = i.school_id
          and s.organization_id = p_organization_id
          and s.district_id = p_district_id
          and s.deleted_at is null
      )
    );

  update public.material_returns mr
  set deleted_at = now(), updated_by = auth.uid(), updated_at = now()
  where mr.organization_id = p_organization_id
    and mr.deleted_at is null
    and (
      exists (
        select 1 from public.warehouses w
        where w.id = mr.warehouse_id
          and w.organization_id = p_organization_id
          and w.district_id = p_district_id
          and w.deleted_at is null
      )
      or exists (
        select 1 from public.schools s
        where s.id = mr.school_id
          and s.organization_id = p_organization_id
          and s.district_id = p_district_id
          and s.deleted_at is null
      )
    );

  update public.school_material_requirements r
  set deleted_at = now(), updated_by = auth.uid(), updated_at = now()
  where r.organization_id = p_organization_id
    and r.deleted_at is null
    and exists (
      select 1 from public.schools s
      where s.id = r.school_id
        and s.organization_id = p_organization_id
        and s.district_id = p_district_id
        and s.deleted_at is null
    );

  update public.schools
  set deleted_at = now(), updated_by = auth.uid(), updated_at = now()
  where organization_id = p_organization_id
    and district_id = p_district_id
    and deleted_at is null;

  update public.warehouses
  set deleted_at = now(), updated_by = auth.uid(), updated_at = now()
  where organization_id = p_organization_id
    and district_id = p_district_id
    and deleted_at is null;

  update public.districts
  set deleted_at = now(), updated_at = now()
  where id = p_district_id
    and organization_id = p_organization_id
    and deleted_at is null;
  if not found then raise exception 'District not found'; end if;

  perform ledger_private.rebuild_material_requirements_for_org(p_organization_id);
  perform ledger_private.rebuild_material_stock_for_org(p_organization_id);

  insert into public.material_audit_logs (
    organization_id, actor_id, entity_table, entity_id, action, metadata
  ) values (
    p_organization_id, auth.uid(), 'districts', p_district_id, 'delete',
    jsonb_build_object('cascade', true)
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

  update public.material_receipts
  set deleted_at = now(), updated_by = auth.uid(), updated_at = now()
  where organization_id = p_organization_id
    and warehouse_id = p_warehouse_id
    and deleted_at is null;

  update public.material_issues
  set deleted_at = now(), updated_by = auth.uid(), updated_at = now()
  where organization_id = p_organization_id
    and warehouse_id = p_warehouse_id
    and deleted_at is null;

  update public.material_returns
  set deleted_at = now(), updated_by = auth.uid(), updated_at = now()
  where organization_id = p_organization_id
    and warehouse_id = p_warehouse_id
    and deleted_at is null;

  update public.warehouses
  set deleted_at = now(), updated_by = auth.uid(), updated_at = now()
  where id = p_warehouse_id
    and organization_id = p_organization_id
    and deleted_at is null;
  if not found then raise exception 'Warehouse not found'; end if;

  perform ledger_private.rebuild_material_requirements_for_org(p_organization_id);
  perform ledger_private.rebuild_material_stock_for_org(p_organization_id);

  insert into public.material_audit_logs (
    organization_id, actor_id, entity_table, entity_id, action, metadata
  ) values (
    p_organization_id, auth.uid(), 'warehouses', p_warehouse_id, 'delete',
    jsonb_build_object('cascade', true)
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

  update public.material_issues
  set deleted_at = now(), updated_by = auth.uid(), updated_at = now()
  where organization_id = p_organization_id
    and school_id = p_school_id
    and deleted_at is null;

  update public.material_returns
  set deleted_at = now(), updated_by = auth.uid(), updated_at = now()
  where organization_id = p_organization_id
    and school_id = p_school_id
    and deleted_at is null;

  update public.school_material_requirements
  set deleted_at = now(), updated_by = auth.uid(), updated_at = now()
  where organization_id = p_organization_id
    and school_id = p_school_id
    and deleted_at is null;

  update public.schools
  set deleted_at = now(), updated_by = auth.uid(), updated_at = now()
  where id = p_school_id
    and organization_id = p_organization_id
    and deleted_at is null;
  if not found then raise exception 'School not found'; end if;

  perform ledger_private.rebuild_material_requirements_for_org(p_organization_id);
  perform ledger_private.rebuild_material_stock_for_org(p_organization_id);

  insert into public.material_audit_logs (
    organization_id, actor_id, entity_table, entity_id, action, metadata
  ) values (
    p_organization_id, auth.uid(), 'schools', p_school_id, 'delete',
    jsonb_build_object('cascade', true)
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

  update public.material_receipts
  set deleted_at = now(), updated_by = auth.uid(), updated_at = now()
  where organization_id = p_organization_id
    and material_id = p_material_id
    and deleted_at is null;

  update public.material_issues
  set deleted_at = now(), updated_by = auth.uid(), updated_at = now()
  where organization_id = p_organization_id
    and material_id = p_material_id
    and deleted_at is null;

  update public.material_returns
  set deleted_at = now(), updated_by = auth.uid(), updated_at = now()
  where organization_id = p_organization_id
    and material_id = p_material_id
    and deleted_at is null;

  update public.school_material_requirements
  set deleted_at = now(), updated_by = auth.uid(), updated_at = now()
  where organization_id = p_organization_id
    and material_id = p_material_id
    and deleted_at is null;

  update public.material_items
  set deleted_at = now(), updated_by = auth.uid(), updated_at = now()
  where id = p_material_id
    and organization_id = p_organization_id
    and deleted_at is null;
  if not found then raise exception 'Material item not found'; end if;

  perform ledger_private.rebuild_material_requirements_for_org(p_organization_id);
  perform ledger_private.rebuild_material_stock_for_org(p_organization_id);

  insert into public.material_audit_logs (
    organization_id, actor_id, entity_table, entity_id, action, metadata
  ) values (
    p_organization_id, auth.uid(), 'material_items', p_material_id, 'delete',
    jsonb_build_object('cascade', true)
  );
end;
$$;

grant execute on function public.delete_material_tender(uuid, uuid) to authenticated;
grant execute on function public.delete_material_district(uuid, uuid) to authenticated;
grant execute on function public.delete_material_warehouse(uuid, uuid) to authenticated;
grant execute on function public.delete_material_school(uuid, uuid) to authenticated;
grant execute on function public.delete_material_item(uuid, uuid) to authenticated;
