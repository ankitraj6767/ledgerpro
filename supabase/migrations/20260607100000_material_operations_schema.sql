-- Material tracking and warehouse operations schema.
-- All records are organization-scoped. Stock totals are changed only by RPCs.

create table if not exists public.tenders (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id),
  name text not null,
  code text,
  year integer,
  status text not null default 'active'
    check (status in ('active', 'completed', 'on_hold', 'cancelled')),
  description text,
  created_by uuid references auth.users(id) default auth.uid(),
  updated_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.districts (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id),
  name text not null,
  state text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.warehouses (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id),
  district_id uuid references public.districts(id),
  name text not null,
  address text,
  manager_name text,
  phone text,
  is_central boolean not null default false,
  created_by uuid references auth.users(id) default auth.uid(),
  updated_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.site_managers (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id),
  full_name text not null,
  phone text,
  email text,
  role_label text not null default 'Project Manager',
  active boolean not null default true,
  created_by uuid references auth.users(id) default auth.uid(),
  updated_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.schools (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id),
  tender_id uuid not null references public.tenders(id),
  district_id uuid references public.districts(id),
  name text not null,
  code text,
  address text,
  status text not null default 'not_started'
    check (status in ('not_started', 'running', 'completed', 'on_hold')),
  progress_percent integer not null default 0
    check (progress_percent between 0 and 100),
  assigned_manager_id uuid references public.site_managers(id),
  created_by uuid references auth.users(id) default auth.uid(),
  updated_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.material_items (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id),
  name text not null,
  sku text,
  unit text not null,
  category text,
  low_stock_threshold numeric(14,2) not null default 0
    check (low_stock_threshold >= 0),
  created_by uuid references auth.users(id) default auth.uid(),
  updated_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.warehouse_stock (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id),
  warehouse_id uuid not null references public.warehouses(id),
  material_id uuid not null references public.material_items(id),
  total_received numeric(14,2) not null default 0 check (total_received >= 0),
  total_issued numeric(14,2) not null default 0 check (total_issued >= 0),
  total_returned numeric(14,2) not null default 0 check (total_returned >= 0),
  remaining_stock numeric(14,2)
    generated always as (total_received + total_returned - total_issued) stored,
  updated_at timestamptz not null default now(),
  unique (warehouse_id, material_id),
  check (total_received + total_returned >= total_issued)
);

create table if not exists public.school_material_requirements (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id),
  tender_id uuid not null references public.tenders(id),
  school_id uuid not null references public.schools(id),
  material_id uuid not null references public.material_items(id),
  required_quantity numeric(14,2) not null default 0
    check (required_quantity >= 0),
  issued_quantity numeric(14,2) not null default 0 check (issued_quantity >= 0),
  returned_quantity numeric(14,2) not null default 0
    check (returned_quantity >= 0 and returned_quantity <= issued_quantity),
  status text not null default 'pending'
    check (status in ('pending', 'partial', 'complete')),
  created_by uuid references auth.users(id) default auth.uid(),
  updated_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  unique (school_id, material_id)
);

create table if not exists public.material_receipts (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id),
  tender_id uuid not null references public.tenders(id),
  warehouse_id uuid not null references public.warehouses(id),
  material_id uuid not null references public.material_items(id),
  quantity numeric(14,2) not null check (quantity > 0),
  received_date date not null default current_date,
  supplier_name text,
  invoice_number text,
  notes text,
  created_by uuid references auth.users(id) default auth.uid(),
  updated_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.material_issues (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id),
  tender_id uuid not null references public.tenders(id),
  warehouse_id uuid not null references public.warehouses(id),
  school_id uuid not null references public.schools(id),
  manager_id uuid references public.site_managers(id),
  material_id uuid not null references public.material_items(id),
  quantity numeric(14,2) not null check (quantity > 0),
  issue_date date not null default current_date,
  notes text,
  created_by uuid references auth.users(id) default auth.uid(),
  updated_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.material_returns (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id),
  tender_id uuid not null references public.tenders(id),
  warehouse_id uuid not null references public.warehouses(id),
  school_id uuid not null references public.schools(id),
  manager_id uuid references public.site_managers(id),
  material_id uuid not null references public.material_items(id),
  quantity numeric(14,2) not null check (quantity > 0),
  return_date date not null default current_date,
  reason text,
  notes text,
  created_by uuid references auth.users(id) default auth.uid(),
  updated_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.material_audit_logs (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id),
  actor_id uuid references auth.users(id),
  entity_table text not null,
  entity_id uuid,
  action text not null,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists tenders_org_status_idx
  on public.tenders (organization_id, status) where deleted_at is null;
create unique index if not exists districts_org_active_name_uidx
  on public.districts (organization_id, lower(name)) where deleted_at is null;
create index if not exists warehouses_org_district_idx
  on public.warehouses (organization_id, district_id) where deleted_at is null;
create index if not exists site_managers_org_active_idx
  on public.site_managers (organization_id, active) where deleted_at is null;
create index if not exists schools_org_filters_idx
  on public.schools (organization_id, tender_id, district_id, status, assigned_manager_id)
  where deleted_at is null;
create index if not exists material_items_org_name_idx
  on public.material_items (organization_id, name) where deleted_at is null;
create index if not exists warehouse_stock_warehouse_material_idx
  on public.warehouse_stock (warehouse_id, material_id);
create index if not exists requirements_school_material_status_idx
  on public.school_material_requirements (school_id, material_id, status)
  where deleted_at is null;
create index if not exists receipts_warehouse_material_date_idx
  on public.material_receipts (warehouse_id, material_id, received_date desc)
  where deleted_at is null;
create index if not exists issues_school_manager_material_date_idx
  on public.material_issues (school_id, manager_id, material_id, issue_date desc)
  where deleted_at is null;
create index if not exists returns_school_manager_material_date_idx
  on public.material_returns (school_id, manager_id, material_id, return_date desc)
  where deleted_at is null;
create index if not exists material_audit_org_date_idx
  on public.material_audit_logs (organization_id, created_at desc);

do $$
declare
  table_name text;
  updated_tables text[] := array[
    'tenders', 'districts', 'warehouses', 'site_managers', 'schools',
    'material_items', 'warehouse_stock', 'school_material_requirements',
    'material_receipts', 'material_issues', 'material_returns'
  ];
  soft_delete_tables text[] := array[
    'tenders', 'districts', 'warehouses', 'site_managers', 'schools',
    'material_items', 'school_material_requirements', 'material_receipts',
    'material_issues', 'material_returns'
  ];
begin
  foreach table_name in array updated_tables loop
    execute format('drop trigger if exists set_updated_at on public.%I', table_name);
    execute format(
      'create trigger set_updated_at before update on public.%I for each row execute function ledger_private.set_updated_at()',
      table_name
    );
  end loop;

  foreach table_name in array soft_delete_tables loop
    execute format('drop trigger if exists prevent_hard_delete on public.%I', table_name);
    execute format(
      'create trigger prevent_hard_delete before delete on public.%I for each row execute function ledger_private.prevent_hard_delete()',
      table_name
    );
  end loop;
end $$;

grant select, insert, update on public.tenders to authenticated;
grant select, insert, update on public.districts to authenticated;
grant select, insert, update on public.warehouses to authenticated;
grant select, insert, update on public.site_managers to authenticated;
grant select, insert, update on public.schools to authenticated;
grant select on public.material_items to authenticated;
grant select on public.warehouse_stock to authenticated;
grant select on public.school_material_requirements to authenticated;
grant select on public.material_receipts to authenticated;
grant select on public.material_issues to authenticated;
grant select on public.material_returns to authenticated;
grant select on public.material_audit_logs to authenticated;

do $$
declare
  table_name text;
  tables text[] := array[
    'tenders', 'districts', 'warehouses', 'site_managers', 'schools',
    'material_items', 'warehouse_stock', 'school_material_requirements',
    'material_receipts', 'material_issues', 'material_returns',
    'material_audit_logs'
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
