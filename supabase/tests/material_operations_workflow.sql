-- Transactional end-to-end material workflow. All created data is rolled back.

begin;

set local role postgres;
set local search_path = extensions, public, pg_catalog;

select extensions.plan(38);

create temporary table material_test_context (
  organization_id uuid not null,
  user_id uuid not null,
  tender_id uuid,
  district_id uuid,
  manager_id uuid,
  warehouse_id uuid,
  school_id uuid,
  material_id uuid
) on commit drop;

create temporary table material_delete_context (
  organization_id uuid not null,
  tender_id uuid,
  district_id uuid,
  manager_id uuid,
  warehouse_id uuid,
  school_tender_id uuid,
  school_district_id uuid,
  school_id uuid,
  material_id uuid
) on commit drop;

create temporary table material_permission_context (
  customer_update_blocked boolean not null,
  site_staff_receive_blocked boolean not null,
  site_staff_issue_blocked boolean not null,
  site_staff_return_blocked boolean not null
) on commit drop;

create temporary table material_cascade_context (
  case_name text primary key,
  tender_id uuid not null,
  district_id uuid not null,
  manager_id uuid not null,
  warehouse_id uuid not null,
  school_id uuid not null,
  material_id uuid not null
) on commit drop;

create or replace function pg_temp.create_material_cascade_fixture(
  p_organization_id uuid,
  p_suffix text
)
returns table (
  tender_id uuid,
  district_id uuid,
  manager_id uuid,
  warehouse_id uuid,
  school_id uuid,
  material_id uuid
)
language plpgsql
as $$
begin
  tender_id := public.create_material_tender(
    p_organization_id,
    'Cascade Tender ' || p_suffix,
    'CASCADE-' || substr(gen_random_uuid()::text, 1, 8),
    extract(year from current_date)::integer,
    'Cascade delete verification'
  );
  district_id := public.create_material_district(
    p_organization_id,
    'Cascade District ' || p_suffix || ' ' || substr(gen_random_uuid()::text, 1, 8),
    'Bihar'
  );
  manager_id := public.create_material_manager(
    p_organization_id,
    'Cascade Manager ' || p_suffix,
    null,
    null,
    'Project Manager'
  );
  warehouse_id := public.create_material_warehouse(
    p_organization_id,
    district_id,
    'Cascade Warehouse ' || p_suffix,
    null,
    null,
    null,
    false
  );
  school_id := public.create_material_school(
    p_organization_id,
    tender_id,
    district_id,
    'Cascade School ' || p_suffix,
    null,
    null,
    manager_id
  );
  material_id := public.create_material_item(
    p_organization_id,
    'Cascade Item ' || p_suffix || ' ' || substr(gen_random_uuid()::text, 1, 8),
    'Nos.',
    null,
    'Verification',
    1
  );

  perform public.set_school_material_requirement(
    p_organization_id, tender_id, school_id, material_id, 10
  );
  perform public.receive_material(
    p_organization_id, tender_id, warehouse_id, material_id, 20,
    'Cascade supplier', null, current_date, null
  );
  perform public.issue_material_to_school(
    p_organization_id, tender_id, warehouse_id, school_id, manager_id,
    material_id, 6, current_date, null
  );
  perform public.return_material_from_school(
    p_organization_id, tender_id, warehouse_id, school_id, manager_id,
    material_id, 2, current_date, 'Cascade return', null
  );

  return next;
end;
$$;

do $$
declare
  owner_user_id uuid := gen_random_uuid();
  org_id uuid := gen_random_uuid();
begin
  insert into auth.users (
    id, aud, role, email, email_confirmed_at, created_at, updated_at
  ) values (
    owner_user_id,
    'authenticated',
    'authenticated',
    'material-owner-' || owner_user_id || '@example.test',
    now(),
    now(),
    now()
  );

  insert into public.profiles (id, full_name, default_language)
  values (owner_user_id, 'Material Owner', 'en');

  perform set_config('request.jwt.claim.sub', owner_user_id::text, true);

  insert into public.organizations (
    id, owner_id, name, owner_name, created_by, updated_by
  ) values (
    org_id, owner_user_id, 'Material Verification Org', 'Material Owner',
    owner_user_id, owner_user_id
  );

  insert into public.organization_members (
    organization_id, user_id, role, created_by, updated_by
  ) values (
    org_id, owner_user_id, 'owner', owner_user_id, owner_user_id
  );

  insert into material_test_context (organization_id, user_id)
  values (org_id, owner_user_id);
end $$;

select extensions.ok(
  exists (select 1 from material_test_context),
  'an authorized organization member exists for workflow verification'
);

do $$
begin
  perform set_config(
    'request.jwt.claim.sub',
    (select user_id::text from material_test_context),
    true
  );
end $$;

update material_test_context
set tender_id = public.create_material_tender(
  organization_id,
  'Codex Verification Tender',
  'VERIFY-' || substr(gen_random_uuid()::text, 1, 8),
  extract(year from current_date)::integer,
  'Transactional verification only'
);

update material_test_context
set district_id = public.create_material_district(
  organization_id,
  'Verification District ' || substr(gen_random_uuid()::text, 1, 8),
  'Bihar'
);

update material_test_context
set manager_id = public.create_material_manager(
  organization_id,
  'Verification Manager',
  null,
  null,
  'Project Manager'
);

update material_test_context
set warehouse_id = public.create_material_warehouse(
  organization_id,
  district_id,
  'Verification Warehouse',
  null,
  null,
  null,
  false
);

update material_test_context
set school_id = public.create_material_school(
  organization_id,
  tender_id,
  district_id,
  'Verification School',
  null,
  null,
  manager_id,
  8
);

update material_test_context
set material_id = public.create_material_item(
  organization_id,
  'Verification Item ' || substr(gen_random_uuid()::text, 1, 8),
  'Nos.',
  null,
  'Verification',
  5
);

select extensions.ok(tender_id is not null, 'creates tender')
from material_test_context;
select extensions.ok(district_id is not null, 'creates district')
from material_test_context;
select extensions.ok(warehouse_id is not null, 'creates warehouse')
from material_test_context;
select extensions.ok(manager_id is not null and school_id is not null, 'creates manager and school')
from material_test_context;
select extensions.ok(material_id is not null, 'creates material item')
from material_test_context;

do $$
declare
  c material_test_context%rowtype;
begin
  select * into c from material_test_context;
  perform public.update_material_tender(
    c.organization_id, c.tender_id, 'Codex Verification Tender Updated',
    'VERIFY-UPDATED', extract(year from current_date)::integer, 'active',
    'Updated in transactional verification'
  );
  perform public.update_material_district(
    c.organization_id, c.district_id, 'Verification District Updated', 'Bihar'
  );
  perform public.update_material_manager(
    c.organization_id, c.manager_id, 'Verification Manager Updated',
    null, null, 'Project Manager', true
  );
  perform public.update_material_warehouse(
    c.organization_id, c.warehouse_id, c.district_id,
    'Verification Warehouse Updated', null, null, null, false
  );
  perform public.update_material_school(
    c.organization_id, c.school_id, c.tender_id, c.district_id,
    'Verification School Updated', null, null, 'running', 40, c.manager_id, 12
  );
  perform public.update_material_item(
    c.organization_id, c.material_id, 'Verification Item Updated',
    'Nos.', null, 'Verification', 7
  );
end $$;

select extensions.is(
  (select name from public.tenders t join material_test_context c on c.tender_id = t.id),
  'Codex Verification Tender Updated',
  'updates tender'
);

select extensions.is(
  (select name from public.districts d join material_test_context c on c.district_id = d.id),
  'Verification District Updated',
  'updates district'
);

select extensions.is(
  (select full_name from public.site_managers m join material_test_context c on c.manager_id = m.id),
  'Verification Manager Updated',
  'updates site manager'
);

select extensions.is(
  (select name from public.warehouses w join material_test_context c on c.warehouse_id = w.id),
  'Verification Warehouse Updated',
  'updates warehouse'
);

select extensions.is(
  (select progress_percent from public.schools s join material_test_context c on c.school_id = s.id),
  40,
  'updates school'
);

select extensions.is(
  (select room_quantity from public.schools s join material_test_context c on c.school_id = s.id),
  12,
  'updates school room quantity'
);

select extensions.is(
  (select low_stock_threshold from public.material_items i join material_test_context c on c.material_id = i.id),
  7::numeric,
  'updates material item'
);

do $$
declare
  c material_test_context%rowtype;
begin
  select * into c from material_test_context;
  perform public.set_school_material_requirement(
    c.organization_id, c.tender_id, c.school_id, c.material_id, 10
  );
  perform public.receive_material(
    c.organization_id, c.tender_id, c.warehouse_id, c.material_id, 20,
    'Verification supplier', null, current_date, null
  );
  perform public.issue_material_to_school(
    c.organization_id, c.tender_id, c.warehouse_id, c.school_id, c.manager_id,
    c.material_id, 6, current_date, null
  );
  perform public.return_material_from_school(
    c.organization_id, c.tender_id, c.warehouse_id, c.school_id, c.manager_id,
    c.material_id, 2, current_date, 'Verification return', null
  );
end $$;

select extensions.is(
  (
    select remaining_stock
    from public.warehouse_stock ws
    join material_test_context c
      on c.organization_id = ws.organization_id
      and c.warehouse_id = ws.warehouse_id
      and c.material_id = ws.material_id
  ),
  16::numeric,
  'receive, issue, and return calculate remaining stock atomically'
);

select extensions.is(
  (
    select issued_quantity - returned_quantity
    from public.school_material_requirements r
    join material_test_context c
      on c.organization_id = r.organization_id
      and c.school_id = r.school_id
      and c.material_id = r.material_id
  ),
  4::numeric,
  'school requirement tracks net issued quantity'
);

do $$
declare
  c material_test_context%rowtype;
begin
  select * into c from material_test_context;
  perform public.update_material_school_progress(
    c.organization_id, c.school_id, 50, null
  );
  perform public.add_material_school_evidence(
    c.organization_id,
    c.school_id,
    14,
    array['org/material-schools/school/photo-1.jpg', 'org/material-schools/school/photo-2.jpg'],
    26.1234567,
    85.1234567,
    8.5,
    now()
  );
end $$;

select extensions.is(
  (
    select progress_percent
    from public.schools s
    join material_test_context c on c.school_id = s.id
  ),
  50,
  'school progress update works'
);

select extensions.is(
  (
    select room_quantity
    from public.schools s
    join material_test_context c on c.school_id = s.id
  ),
  14,
  'school evidence update stores room quantity'
);

select extensions.is(
  (
    select cardinality(gps_photo_paths)
    from public.schools s
    join material_test_context c on c.school_id = s.id
  ),
  2,
  'school evidence update stores all GPS photo paths'
);

insert into material_cascade_context
select 'tender', f.*
from material_test_context c,
  lateral pg_temp.create_material_cascade_fixture(c.organization_id, 'Tender') f;

insert into material_cascade_context
select 'district', f.*
from material_test_context c,
  lateral pg_temp.create_material_cascade_fixture(c.organization_id, 'District') f;

insert into material_cascade_context
select 'warehouse', f.*
from material_test_context c,
  lateral pg_temp.create_material_cascade_fixture(c.organization_id, 'Warehouse') f;

insert into material_cascade_context
select 'school', f.*
from material_test_context c,
  lateral pg_temp.create_material_cascade_fixture(c.organization_id, 'School') f;

insert into material_cascade_context
select 'material', f.*
from material_test_context c,
  lateral pg_temp.create_material_cascade_fixture(c.organization_id, 'Material') f;

do $$
declare
  org_id uuid := (select organization_id from material_test_context);
begin
  perform public.delete_material_tender(
    org_id,
    (select tender_id from material_cascade_context where case_name = 'tender')
  );
  perform public.delete_material_district(
    org_id,
    (select district_id from material_cascade_context where case_name = 'district')
  );
  perform public.delete_material_warehouse(
    org_id,
    (select warehouse_id from material_cascade_context where case_name = 'warehouse')
  );
  perform public.delete_material_school(
    org_id,
    (select school_id from material_cascade_context where case_name = 'school')
  );
  perform public.delete_material_item(
    org_id,
    (select material_id from material_cascade_context where case_name = 'material')
  );
end $$;

select extensions.ok(
  (
    select t.deleted_at is not null
    from public.tenders t
    join material_cascade_context c on c.tender_id = t.id
    where c.case_name = 'tender'
  ),
  'deletes tender even when it has schools and material transactions'
);

select extensions.ok(
  (
    select d.deleted_at is not null
    from public.districts d
    join material_cascade_context c on c.district_id = d.id
    where c.case_name = 'district'
  ),
  'deletes district even when it has schools and warehouses'
);

select extensions.ok(
  (
    select w.deleted_at is not null
    from public.warehouses w
    join material_cascade_context c on c.warehouse_id = w.id
    where c.case_name = 'warehouse'
  ),
  'deletes warehouse even when it has stock transactions'
);

select extensions.ok(
  (
    select s.deleted_at is not null
    from public.schools s
    join material_cascade_context c on c.school_id = s.id
    where c.case_name = 'school'
  ),
  'deletes school even when it has requirements and issues'
);

select extensions.ok(
  (
    select mi.deleted_at is not null
    from public.material_items mi
    join material_cascade_context c on c.material_id = mi.id
    where c.case_name = 'material'
  ),
  'deletes material item even when it has stock and transactions'
);

select extensions.ok(
  not exists (
    select 1
    from public.material_receipts r
    join material_cascade_context c
      on c.tender_id = r.tender_id or c.warehouse_id = r.warehouse_id
        or c.material_id = r.material_id
    where c.case_name in ('tender', 'district', 'warehouse', 'material')
      and r.deleted_at is null
  ),
  'cascade delete hides dependent receipts from active views'
);

select extensions.ok(
  not exists (
    select 1
    from public.material_issues i
    join material_cascade_context c
      on c.tender_id = i.tender_id or c.warehouse_id = i.warehouse_id
        or c.school_id = i.school_id or c.material_id = i.material_id
    where c.case_name in ('tender', 'district', 'warehouse', 'school', 'material')
      and i.deleted_at is null
  ),
  'cascade delete hides dependent issues from active views'
);

select extensions.ok(
  not exists (
    select 1
    from public.material_returns mr
    join material_cascade_context c
      on c.tender_id = mr.tender_id or c.warehouse_id = mr.warehouse_id
        or c.school_id = mr.school_id or c.material_id = mr.material_id
    where c.case_name in ('tender', 'district', 'warehouse', 'school', 'material')
      and mr.deleted_at is null
  ),
  'cascade delete hides dependent returns from active views'
);

select extensions.ok(
  not exists (
    select 1
    from public.school_material_requirements r
    join material_cascade_context c
      on c.tender_id = r.tender_id or c.school_id = r.school_id
        or c.material_id = r.material_id
    where c.case_name in ('tender', 'district', 'school', 'material')
      and r.deleted_at is null
  ),
  'cascade delete hides dependent requirements from active views'
);

select extensions.ok(
  not exists (
    select 1
    from public.warehouse_stock ws
    join material_cascade_context c
      on c.warehouse_id = ws.warehouse_id or c.material_id = ws.material_id
    where c.case_name in ('tender', 'district', 'warehouse', 'material')
  ),
  'cascade delete rebuilds stock aggregates without deleted setup data'
);

select extensions.is(
  (
    select ws.total_issued
    from public.warehouse_stock ws
    join material_cascade_context c
      on c.warehouse_id = ws.warehouse_id and c.material_id = ws.material_id
    where c.case_name = 'school'
  ),
  0::numeric,
  'school delete removes its issue totals from stock aggregates'
);

select extensions.is(
  (
    select ws.remaining_stock
    from public.warehouse_stock ws
    join material_cascade_context c
      on c.warehouse_id = ws.warehouse_id and c.material_id = ws.material_id
    where c.case_name = 'school'
  ),
  20::numeric,
  'school delete keeps unrelated warehouse receipts available'
);

insert into material_delete_context (organization_id)
select organization_id from material_test_context;

update material_delete_context
set tender_id = public.create_material_tender(
  organization_id,
  'Disposable Tender ' || substr(gen_random_uuid()::text, 1, 8),
  null,
  extract(year from current_date)::integer,
  'Delete verification only'
);

update material_delete_context
set district_id = public.create_material_district(
  organization_id,
  'Disposable District ' || substr(gen_random_uuid()::text, 1, 8),
  'Bihar'
);

update material_delete_context
set manager_id = public.create_material_manager(
  organization_id,
  'Disposable Manager',
  null,
  null,
  'Project Manager'
);

update material_delete_context
set warehouse_id = public.create_material_warehouse(
  organization_id,
  null,
  'Disposable Warehouse ' || substr(gen_random_uuid()::text, 1, 8),
  null,
  null,
  null,
  false
);

update material_delete_context
set school_tender_id = public.create_material_tender(
  organization_id,
  'Disposable School Tender ' || substr(gen_random_uuid()::text, 1, 8),
  null,
  extract(year from current_date)::integer,
  'Delete verification only'
);

update material_delete_context
set school_district_id = public.create_material_district(
  organization_id,
  'Disposable School District ' || substr(gen_random_uuid()::text, 1, 8),
  'Bihar'
);

update material_delete_context
set school_id = public.create_material_school(
  organization_id,
  school_tender_id,
  school_district_id,
  'Disposable School ' || substr(gen_random_uuid()::text, 1, 8),
  null,
  null,
  manager_id,
  0
);

update material_delete_context
set material_id = public.create_material_item(
  organization_id,
  'Disposable Item ' || substr(gen_random_uuid()::text, 1, 8),
  'Nos.',
  null,
  'Verification',
  0
);

do $$
declare
  c material_delete_context%rowtype;
begin
  select * into c from material_delete_context;
  perform public.delete_material_tender(c.organization_id, c.tender_id);
  perform public.delete_material_district(c.organization_id, c.district_id);
  perform public.delete_material_manager(c.organization_id, c.manager_id);
  perform public.delete_material_warehouse(c.organization_id, c.warehouse_id);
  perform public.delete_material_school(c.organization_id, c.school_id);
  perform public.delete_material_item(c.organization_id, c.material_id);
end $$;

select extensions.ok(
  (select deleted_at is not null from public.tenders t join material_delete_context c on c.tender_id = t.id),
  'deletes tender without dependencies'
);

select extensions.ok(
  (select deleted_at is not null from public.districts d join material_delete_context c on c.district_id = d.id),
  'deletes district without dependencies'
);

select extensions.ok(
  (select not active from public.site_managers m join material_delete_context c on c.manager_id = m.id),
  'deletes site manager by deactivating it'
);

select extensions.ok(
  (select deleted_at is not null from public.warehouses w join material_delete_context c on c.warehouse_id = w.id),
  'deletes warehouse without stock'
);

select extensions.ok(
  (select deleted_at is not null from public.schools s join material_delete_context c on c.school_id = s.id),
  'deletes school without requirements'
);

select extensions.ok(
  (select deleted_at is not null from public.material_items i join material_delete_context c on c.material_id = i.id),
  'deletes material item without history'
);

do $$
declare
  c material_test_context%rowtype;
  customer_user_id uuid := gen_random_uuid();
  site_staff_user_id uuid := gen_random_uuid();
  blocked boolean := false;
  receive_blocked boolean := false;
  issue_blocked boolean := false;
  return_blocked boolean := false;
begin
  select * into c from material_test_context;

  insert into auth.users (
    id, aud, role, email, email_confirmed_at, created_at, updated_at
  ) values (
    customer_user_id,
    'authenticated',
    'authenticated',
    'material-customer-' || customer_user_id || '@example.test',
    now(),
    now(),
    now()
  );

  insert into public.profiles (id, full_name, default_language)
  values (customer_user_id, 'Material Customer', 'en');

  insert into public.organization_members (
    organization_id, user_id, role, created_by, updated_by
  ) values (
    c.organization_id, customer_user_id, 'customer', c.user_id, c.user_id
  );

  insert into auth.users (
    id, aud, role, email, email_confirmed_at, created_at, updated_at
  ) values (
    site_staff_user_id,
    'authenticated',
    'authenticated',
    'material-site-staff-' || site_staff_user_id || '@example.test',
    now(),
    now(),
    now()
  );

  insert into public.profiles (id, full_name, default_language)
  values (site_staff_user_id, 'Material Site Staff', 'en');

  insert into public.organization_members (
    organization_id, user_id, role, created_by, updated_by
  ) values (
    c.organization_id, site_staff_user_id, 'site_staff', c.user_id, c.user_id
  );

  perform set_config('request.jwt.claim.sub', customer_user_id::text, true);
  begin
    perform public.update_material_tender(
      c.organization_id, c.tender_id, 'Customer Should Not Update',
      null, null, 'active', null
    );
  exception when others then
    if sqlerrm = 'Not permitted to update tenders' then
      blocked := true;
    else
      raise;
    end if;
  end;

  perform set_config('request.jwt.claim.sub', site_staff_user_id::text, true);
  begin
    perform public.receive_material(
      c.organization_id, c.tender_id, c.warehouse_id, c.material_id, 1,
      null, null, current_date, null
    );
  exception when others then
    if sqlerrm = 'Not permitted to receive material' then
      receive_blocked := true;
    else
      raise;
    end if;
  end;
  begin
    perform public.issue_material_to_school(
      c.organization_id, c.tender_id, c.warehouse_id, c.school_id,
      c.manager_id, c.material_id, 1, current_date, null
    );
  exception when others then
    if sqlerrm = 'Not permitted to issue material' then
      issue_blocked := true;
    else
      raise;
    end if;
  end;
  begin
    perform public.return_material_from_school(
      c.organization_id, c.tender_id, c.warehouse_id, c.school_id,
      c.manager_id, c.material_id, 1, current_date, 'Site staff return', null
    );
  exception when others then
    if sqlerrm = 'Not permitted to return material' then
      return_blocked := true;
    else
      raise;
    end if;
  end;

  perform public.update_material_school_progress(
    c.organization_id, c.school_id, 55, null
  );
  perform public.add_material_school_evidence(
    c.organization_id,
    c.school_id,
    15,
    array['org/material-schools/school/site-staff-photo.jpg'],
    26.2234567,
    85.2234567,
    7.5,
    now()
  );
  perform set_config('request.jwt.claim.sub', c.user_id::text, true);

  insert into material_permission_context (
    customer_update_blocked,
    site_staff_receive_blocked,
    site_staff_issue_blocked,
    site_staff_return_blocked
  ) values (
    blocked,
    receive_blocked,
    issue_blocked,
    return_blocked
  );
end $$;

select extensions.ok(
  (select customer_update_blocked from material_permission_context),
  'customer members are read-only for material master writes'
);

select extensions.ok(
  (
    select site_staff_receive_blocked
      and site_staff_issue_blocked
      and site_staff_return_blocked
    from material_permission_context
  ),
  'site staff can view/update site evidence but cannot mutate material stock'
);

select * from extensions.finish();

rollback;
