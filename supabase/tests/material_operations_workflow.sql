-- Transactional end-to-end material workflow. All created data is rolled back.

begin;

set local role postgres;
set local search_path = extensions, public, pg_catalog;

select extensions.plan(9);

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

insert into material_test_context (organization_id, user_id)
select organization_id, user_id
from public.organization_members
where deleted_at is null
  and role in ('owner', 'manager', 'accountant')
limit 1;

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
  manager_id
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

select * from extensions.finish();

rollback;
