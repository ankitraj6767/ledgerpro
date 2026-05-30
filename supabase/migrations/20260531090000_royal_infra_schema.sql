-- =============================================================================
-- Royal Infra — infrastructure project finance schema
-- Adds organization-scoped project finance tables alongside the existing
-- ledger schema. All money is stored in paise (bigint). Soft-delete only.
-- =============================================================================

-- Reuse the existing updated_at + hard-delete-guard helpers from ledger_private.
-- (ledger_private.set_updated_at / prevent_hard_delete already exist.)

-- ----------------------------------------------------------------------------
-- Enums
-- ----------------------------------------------------------------------------
do $$
begin
  if not exists (select 1 from pg_type where typname = 'infra_project_status') then
    create type public.infra_project_status as enum
      ('planning', 'active', 'on_hold', 'completed', 'cancelled');
  end if;
  if not exists (select 1 from pg_type where typname = 'govt_fund_status') then
    create type public.govt_fund_status as enum
      ('sanctioned', 'partially_received', 'fully_received', 'delayed', 'cancelled');
  end if;
  if not exists (select 1 from pg_type where typname = 'org_member_role') then
    create type public.org_member_role as enum
      ('owner', 'manager', 'accountant', 'site_staff', 'viewer');
  end if;
end $$;

-- ----------------------------------------------------------------------------
-- Organizations + membership
-- ----------------------------------------------------------------------------
create table if not exists public.organizations (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles(id),
  name text not null,
  owner_name text not null,
  phone text,
  address text,
  logo_path text,
  default_currency text not null default 'INR' check (default_currency = 'INR'),
  created_by uuid references auth.users(id) default auth.uid(),
  updated_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.organization_members (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id),
  user_id uuid not null references public.profiles(id),
  role public.org_member_role not null default 'viewer',
  created_by uuid references auth.users(id) default auth.uid(),
  updated_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  unique (organization_id, user_id)
);

-- ----------------------------------------------------------------------------
-- Projects
-- ----------------------------------------------------------------------------
create table if not exists public.infra_projects (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id),
  name text not null,
  code text,
  category text,
  location_city text,
  location_state text,
  address text,
  status public.infra_project_status not null default 'planning',
  start_date date,
  expected_end_date date,
  actual_end_date date,
  progress_percent integer not null default 0 check (progress_percent between 0 and 100),
  total_estimated_cost_paise bigint not null default 0 check (total_estimated_cost_paise >= 0),
  total_investment_paise bigint not null default 0 check (total_investment_paise >= 0),
  total_govt_sanctioned_paise bigint not null default 0 check (total_govt_sanctioned_paise >= 0),
  total_govt_received_paise bigint not null default 0 check (total_govt_received_paise >= 0),
  total_expense_paise bigint not null default 0 check (total_expense_paise >= 0),
  description text,
  cover_image_url text,
  search_vector tsvector,
  created_by uuid references auth.users(id) default auth.uid(),
  updated_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

-- ----------------------------------------------------------------------------
-- Investors + investments
-- ----------------------------------------------------------------------------
create table if not exists public.investors (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id),
  name text not null,
  phone text,
  email text,
  address text,
  pan text,
  notes text,
  created_by uuid references auth.users(id) default auth.uid(),
  updated_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.project_investments (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id),
  project_id uuid not null references public.infra_projects(id),
  investor_id uuid not null references public.investors(id),
  amount_paise bigint not null check (amount_paise > 0),
  investment_date date not null default current_date,
  payment_mode text not null default 'bank',
  reference_number text,
  notes text,
  created_by uuid references auth.users(id) default auth.uid(),
  updated_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

-- ----------------------------------------------------------------------------
-- Government funds + receipts
-- ----------------------------------------------------------------------------
create table if not exists public.government_funds (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id),
  project_id uuid not null references public.infra_projects(id),
  department_name text not null,
  scheme_name text,
  sanction_order_number text,
  amount_sanctioned_paise bigint not null default 0 check (amount_sanctioned_paise >= 0),
  amount_received_paise bigint not null default 0 check (amount_received_paise >= 0),
  sanction_date date,
  last_received_date date,
  status public.govt_fund_status not null default 'sanctioned',
  document_path text,
  notes text,
  created_by uuid references auth.users(id) default auth.uid(),
  updated_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.government_fund_receipts (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id),
  government_fund_id uuid not null references public.government_funds(id),
  project_id uuid not null references public.infra_projects(id),
  amount_paise bigint not null check (amount_paise > 0),
  received_date date not null default current_date,
  payment_mode text not null default 'bank',
  reference_number text,
  document_path text,
  notes text,
  created_by uuid references auth.users(id) default auth.uid(),
  updated_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

-- ----------------------------------------------------------------------------
-- Expenses
-- ----------------------------------------------------------------------------
create table if not exists public.project_expenses (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id),
  project_id uuid not null references public.infra_projects(id),
  category text not null default 'Miscellaneous',
  vendor_name text,
  amount_paise bigint not null check (amount_paise > 0),
  expense_date date not null default current_date,
  payment_mode text not null default 'cash',
  bill_number text,
  bill_image_path text,
  notes text,
  created_by uuid references auth.users(id) default auth.uid(),
  updated_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

-- ----------------------------------------------------------------------------
-- Documents, notes, progress
-- ----------------------------------------------------------------------------
create table if not exists public.project_documents (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id),
  project_id uuid not null references public.infra_projects(id),
  title text not null,
  document_type text not null default 'other',
  storage_path text not null,
  mime_type text,
  size_bytes bigint,
  uploaded_by uuid references auth.users(id) default auth.uid(),
  created_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.project_notes (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id),
  project_id uuid not null references public.infra_projects(id),
  note text not null,
  created_by uuid references auth.users(id) default auth.uid(),
  updated_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.project_progress_updates (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id),
  project_id uuid not null references public.infra_projects(id),
  progress_percent integer not null check (progress_percent between 0 and 100),
  note text,
  created_by uuid references auth.users(id) default auth.uid(),
  created_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.project_audit_logs (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id),
  project_id uuid references public.infra_projects(id),
  actor_id uuid references auth.users(id),
  entity_table text not null,
  entity_id uuid,
  action text not null,
  created_at timestamptz not null default now()
);

-- ----------------------------------------------------------------------------
-- Indexes
-- ----------------------------------------------------------------------------
create index if not exists organizations_owner_idx on public.organizations(owner_id) where deleted_at is null;
create index if not exists org_members_user_idx on public.organization_members(user_id, organization_id) where deleted_at is null;
create index if not exists infra_projects_org_idx on public.infra_projects(organization_id) where deleted_at is null;
create index if not exists infra_projects_status_idx on public.infra_projects(organization_id, status) where deleted_at is null;
create index if not exists infra_projects_search_idx on public.infra_projects using gin(search_vector);
create index if not exists investors_org_idx on public.investors(organization_id) where deleted_at is null;
create index if not exists investments_project_idx on public.project_investments(project_id) where deleted_at is null;
create index if not exists investments_investor_idx on public.project_investments(investor_id) where deleted_at is null;
create index if not exists govt_funds_project_idx on public.government_funds(project_id) where deleted_at is null;
create index if not exists govt_receipts_fund_idx on public.government_fund_receipts(government_fund_id) where deleted_at is null;
create index if not exists govt_receipts_project_idx on public.government_fund_receipts(project_id) where deleted_at is null;
create index if not exists expenses_project_idx on public.project_expenses(project_id) where deleted_at is null;
create index if not exists expenses_project_date_idx on public.project_expenses(project_id, expense_date desc) where deleted_at is null;
create index if not exists documents_project_idx on public.project_documents(project_id) where deleted_at is null;
create index if not exists notes_project_idx on public.project_notes(project_id) where deleted_at is null;
create index if not exists progress_project_idx on public.project_progress_updates(project_id) where deleted_at is null;
create index if not exists project_audit_org_idx on public.project_audit_logs(organization_id, created_at desc);
