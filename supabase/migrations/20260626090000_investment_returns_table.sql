-- ---------------------------------------------------------------------------
-- Investment returns table: track money returned to investors
-- ---------------------------------------------------------------------------
create table if not exists public.investment_returns (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id),
  project_id uuid not null references public.infra_projects(id),
  investor_id uuid not null references public.investors(id),
  amount_paise bigint not null check (amount_paise > 0),
  return_date date not null default current_date,
  payment_mode text not null default 'bank',
  reference_number text,
  notes text,
  created_by uuid references auth.users(id) default auth.uid(),
  updated_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

-- Index for common queries
create index if not exists idx_investment_returns_project
  on public.investment_returns(project_id)
  where deleted_at is null;

create index if not exists idx_investment_returns_investor
  on public.investment_returns(investor_id)
  where deleted_at is null;

-- RLS policies
alter table public.investment_returns enable row level security;

create policy "Users can view investment returns for their organization"
  on public.investment_returns for select
  using (
    organization_id in (
      select organization_id from public.organization_members
      where user_id = auth.uid() and deleted_at is null
    )
  );

create policy "Users can insert investment returns for their organization"
  on public.investment_returns for insert
  with check (
    organization_id in (
      select organization_id from public.organization_members
      where user_id = auth.uid() and deleted_at is null
      and role in ('owner', 'manager', 'accountant')
    )
  );

create policy "Users can update investment returns for their organization"
  on public.investment_returns for update
  using (
    organization_id in (
      select organization_id from public.organization_members
      where user_id = auth.uid() and deleted_at is null
      and role in ('owner', 'manager', 'accountant')
    )
  );

-- Trigger for updated_at
create trigger set_investment_returns_updated_at
  before update on public.investment_returns
  for each row execute function ledger_private.set_updated_at();
