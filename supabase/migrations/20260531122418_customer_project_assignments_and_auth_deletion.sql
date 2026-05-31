-- Customer project assignments + customer scoped project visibility.
-- Customers only see projects explicitly assigned by an owner/manager.

create table if not exists public.customer_project_assignments (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id),
  customer_member_id uuid not null references public.organization_members(id),
  customer_user_id uuid not null references public.profiles(id),
  project_id uuid not null references public.infra_projects(id),
  created_by uuid references auth.users(id) default auth.uid(),
  updated_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  unique (customer_member_id, project_id)
);

create index if not exists customer_project_assignments_customer_idx
  on public.customer_project_assignments (organization_id, customer_user_id)
  where deleted_at is null;

create index if not exists customer_project_assignments_project_idx
  on public.customer_project_assignments (project_id)
  where deleted_at is null;

alter table public.customer_project_assignments enable row level security;

create or replace function ledger_private.is_customer_assigned_project(target_project_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public, ledger_private, pg_temp
as $$
  select exists (
    select 1
    from public.customer_project_assignments a
    join public.organization_members m
      on m.id = a.customer_member_id
     and m.organization_id = a.organization_id
     and m.user_id = a.customer_user_id
     and m.role::text = 'customer'
     and m.deleted_at is null
    where a.project_id = target_project_id
      and a.customer_user_id = auth.uid()
      and a.deleted_at is null
  );
$$;

create or replace function ledger_private.can_read_project(target_project_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public, ledger_private, pg_temp
as $$
  select coalesce(
    (
      select case
        when ledger_private.is_org_customer(p.organization_id) then
          ledger_private.is_customer_assigned_project(p.id)
        else
          ledger_private.can_read_org(p.organization_id)
      end
      from public.infra_projects p
      where p.id = target_project_id
        and p.deleted_at is null
    ),
    false
  );
$$;

create or replace function ledger_private.can_read_project_data(target_org_id uuid, target_project_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public, ledger_private, pg_temp
as $$
  select case
    when ledger_private.is_org_customer(target_org_id) then
      ledger_private.is_customer_assigned_project(target_project_id)
    else
      ledger_private.can_read_org(target_org_id)
  end;
$$;

drop policy if exists "customer_project_assignments_select" on public.customer_project_assignments;
create policy "customer_project_assignments_select" on public.customer_project_assignments
  for select to authenticated
  using (
    deleted_at is null
    and (
      ledger_private.can_manage_org(organization_id)
      or customer_user_id = auth.uid()
    )
  );

drop policy if exists "customer_project_assignments_manage" on public.customer_project_assignments;
create policy "customer_project_assignments_manage" on public.customer_project_assignments
  for all to authenticated
  using (ledger_private.can_manage_org(organization_id))
  with check (ledger_private.can_manage_org(organization_id));

drop policy if exists "projects_select" on public.infra_projects;
create policy "projects_select" on public.infra_projects
  for select to authenticated
  using (
    deleted_at is null
    and (
      (
        ledger_private.is_org_customer(organization_id)
        and ledger_private.is_customer_assigned_project(id)
      )
      or (
        not ledger_private.is_org_customer(organization_id)
        and ledger_private.can_read_org(organization_id)
      )
    )
  );

drop policy if exists "investments_select" on public.project_investments;
create policy "investments_select" on public.project_investments
  for select to authenticated
  using (ledger_private.can_read_project_data(organization_id, project_id));

drop policy if exists "govt_funds_select" on public.government_funds;
create policy "govt_funds_select" on public.government_funds
  for select to authenticated
  using (ledger_private.can_read_project_data(organization_id, project_id));

drop policy if exists "govt_receipts_select" on public.government_fund_receipts;
create policy "govt_receipts_select" on public.government_fund_receipts
  for select to authenticated
  using (ledger_private.can_read_project_data(organization_id, project_id));

drop policy if exists "expenses_select" on public.project_expenses;
create policy "expenses_select" on public.project_expenses
  for select to authenticated
  using (ledger_private.can_read_project_data(organization_id, project_id));

drop policy if exists "documents_select" on public.project_documents;
create policy "documents_select" on public.project_documents
  for select to authenticated
  using (ledger_private.can_read_project_data(organization_id, project_id));

drop policy if exists "notes_select" on public.project_notes;
create policy "notes_select" on public.project_notes
  for select to authenticated
  using (ledger_private.can_read_project_data(organization_id, project_id));

drop policy if exists "progress_select" on public.project_progress_updates;
create policy "progress_select" on public.project_progress_updates
  for select to authenticated
  using (ledger_private.can_read_project_data(organization_id, project_id));

create or replace function public.list_customer_project_assignments(
  p_organization_id uuid,
  p_customer_user_id uuid
)
returns table (
  project_id uuid
)
language plpgsql
stable
security definer
set search_path = public, ledger_private, pg_temp
as $$
begin
  if not ledger_private.can_manage_org(p_organization_id) then
    raise exception 'Not permitted to manage customers';
  end if;

  return query
  select a.project_id
  from public.customer_project_assignments a
  join public.organization_members m
    on m.id = a.customer_member_id
   and m.role::text = 'customer'
   and m.deleted_at is null
  where a.organization_id = p_organization_id
    and a.customer_user_id = p_customer_user_id
    and a.deleted_at is null
  order by a.created_at;
end;
$$;

create or replace function public.set_customer_project_assignments(
  p_organization_id uuid,
  p_customer_user_id uuid,
  p_project_ids uuid[]
)
returns void
language plpgsql
security definer
set search_path = public, ledger_private, pg_temp
as $$
declare
  v_member_id uuid;
  v_project_id uuid;
  v_project_ids uuid[] := coalesce(p_project_ids, array[]::uuid[]);
begin
  if not ledger_private.can_manage_org(p_organization_id) then
    raise exception 'Not permitted to manage customers';
  end if;

  select id into v_member_id
  from public.organization_members
  where organization_id = p_organization_id
    and user_id = p_customer_user_id
    and role::text = 'customer'
    and deleted_at is null;

  if v_member_id is null then
    raise exception 'Customer access was not found';
  end if;

  if exists (
    select 1
    from unnest(v_project_ids) pid
    left join public.infra_projects p
      on p.id = pid
     and p.organization_id = p_organization_id
     and p.deleted_at is null
    where p.id is null
  ) then
    raise exception 'One or more projects are invalid';
  end if;

  update public.customer_project_assignments
    set deleted_at = now(),
        updated_by = auth.uid(),
        updated_at = now()
  where organization_id = p_organization_id
    and customer_user_id = p_customer_user_id
    and deleted_at is null
    and not (project_id = any(v_project_ids));

  foreach v_project_id in array v_project_ids loop
    insert into public.customer_project_assignments (
      organization_id,
      customer_member_id,
      customer_user_id,
      project_id,
      created_by,
      updated_by,
      deleted_at
    ) values (
      p_organization_id,
      v_member_id,
      p_customer_user_id,
      v_project_id,
      auth.uid(),
      auth.uid(),
      null
    )
    on conflict (customer_member_id, project_id) do update
      set deleted_at = null,
          updated_by = auth.uid(),
          updated_at = now();
  end loop;
end;
$$;

create or replace function public.dashboard_summary(p_organization_id uuid)
returns table (
  total_projects bigint,
  active_projects bigint,
  completed_projects bigint,
  delayed_projects bigint,
  total_investment_paise bigint,
  total_govt_sanctioned_paise bigint,
  total_govt_received_paise bigint,
  total_expense_paise bigint,
  pending_govt_funds_paise bigint
)
language sql
stable
security definer
set search_path = public, ledger_private, pg_temp
as $$
  select
    count(*) filter (where p.deleted_at is null and ledger_private.can_read_project(p.id)),
    count(*) filter (where p.deleted_at is null and p.status = 'active' and ledger_private.can_read_project(p.id)),
    count(*) filter (where p.deleted_at is null and p.status = 'completed' and ledger_private.can_read_project(p.id)),
    count(*) filter (where p.deleted_at is null and p.status = 'on_hold' and ledger_private.can_read_project(p.id)),
    coalesce(sum(p.total_investment_paise) filter (where p.deleted_at is null and ledger_private.can_read_project(p.id)), 0),
    coalesce(sum(p.total_govt_sanctioned_paise) filter (where p.deleted_at is null and ledger_private.can_read_project(p.id)), 0),
    coalesce(sum(p.total_govt_received_paise) filter (where p.deleted_at is null and ledger_private.can_read_project(p.id)), 0),
    coalesce(sum(p.total_expense_paise) filter (where p.deleted_at is null and ledger_private.can_read_project(p.id)), 0),
    coalesce(sum(greatest(p.total_govt_sanctioned_paise - p.total_govt_received_paise, 0)) filter (where p.deleted_at is null and ledger_private.can_read_project(p.id)), 0)
  from public.infra_projects p
  where p.organization_id = p_organization_id
    and ledger_private.can_read_org(p_organization_id);
$$;

create or replace function public.project_financial_summary(p_project_id uuid)
returns table (
  total_investment_paise bigint,
  total_govt_sanctioned_paise bigint,
  total_govt_received_paise bigint,
  pending_govt_paise bigint,
  total_expense_paise bigint,
  available_balance_paise bigint
)
language sql
stable
security definer
set search_path = public, ledger_private, pg_temp
as $$
  select
    p.total_investment_paise,
    p.total_govt_sanctioned_paise,
    p.total_govt_received_paise,
    greatest(p.total_govt_sanctioned_paise - p.total_govt_received_paise, 0),
    p.total_expense_paise,
    (p.total_investment_paise + p.total_govt_received_paise - p.total_expense_paise)
  from public.infra_projects p
  where p.id = p_project_id
    and p.deleted_at is null
    and ledger_private.can_read_project(p.id);
$$;

create or replace function public.search_projects(
  p_organization_id uuid,
  p_query text
)
returns setof public.infra_projects
language sql
stable
security definer
set search_path = public, ledger_private, pg_temp
as $$
  select *
  from public.infra_projects p
  where p.organization_id = p_organization_id
    and p.deleted_at is null
    and ledger_private.can_read_project(p.id)
    and (
      coalesce(trim(p_query), '') = ''
      or p.search_vector @@ plainto_tsquery('simple', p_query)
      or p.name ilike '%' || p_query || '%'
    )
  order by p.updated_at desc;
$$;

create or replace function public.add_project_expense(
  p_project_id uuid,
  p_category text,
  p_amount_paise bigint,
  p_vendor_name text default null,
  p_expense_date date default current_date,
  p_payment_mode text default 'cash',
  p_bill_number text default null,
  p_bill_image_path text default null,
  p_notes text default null
)
returns uuid
language plpgsql
security definer
set search_path = public, ledger_private, pg_temp
as $$
declare
  org_id uuid;
  new_id uuid;
begin
  select organization_id into org_id from public.infra_projects where id = p_project_id and deleted_at is null;
  if org_id is null then raise exception 'Project not found'; end if;
  if not ledger_private.can_add_or_edit_expenses(org_id) or not ledger_private.can_read_project(p_project_id) then
    raise exception 'Not permitted to add expenses';
  end if;
  if p_amount_paise <= 0 then raise exception 'Expense amount must be greater than zero'; end if;

  insert into public.project_expenses (
    organization_id, project_id, category, vendor_name, amount_paise, expense_date,
    payment_mode, bill_number, bill_image_path, notes, created_by, updated_by
  ) values (
    org_id, p_project_id, p_category, p_vendor_name, p_amount_paise, p_expense_date,
    p_payment_mode, p_bill_number, p_bill_image_path, p_notes, auth.uid(), auth.uid()
  )
  returning id into new_id;

  update public.infra_projects
    set total_expense_paise = total_expense_paise + p_amount_paise,
        updated_by = auth.uid(),
        updated_at = now()
  where id = p_project_id;

  return new_id;
end;
$$;

create or replace function public.update_project_expense(
  p_expense_id uuid,
  p_category text,
  p_amount_paise bigint,
  p_vendor_name text default null,
  p_expense_date date default current_date,
  p_payment_mode text default 'cash',
  p_bill_number text default null,
  p_notes text default null
)
returns void
language plpgsql
security definer
set search_path = public, ledger_private, pg_temp
as $$
declare
  v_org uuid;
  v_project uuid;
  v_old bigint;
  v_created_by uuid;
begin
  select organization_id, project_id, amount_paise, created_by
    into v_org, v_project, v_old, v_created_by
  from public.project_expenses
  where id = p_expense_id
    and deleted_at is null;

  if v_org is null then
    raise exception 'Expense not found';
  end if;
  if not ledger_private.can_add_or_edit_expenses(v_org) or not ledger_private.can_read_project(v_project) then
    raise exception 'Not permitted to edit expenses';
  end if;
  if ledger_private.is_org_customer(v_org) and v_created_by is distinct from auth.uid() then
    raise exception 'Customers can edit only expenses they created';
  end if;
  if p_amount_paise <= 0 then
    raise exception 'Expense amount must be greater than zero';
  end if;

  update public.project_expenses
    set category = p_category,
        amount_paise = p_amount_paise,
        vendor_name = p_vendor_name,
        expense_date = p_expense_date,
        payment_mode = p_payment_mode,
        bill_number = p_bill_number,
        notes = p_notes,
        updated_by = auth.uid(),
        updated_at = now()
  where id = p_expense_id;

  update public.infra_projects
    set total_expense_paise = greatest(total_expense_paise - v_old + p_amount_paise, 0),
        updated_by = auth.uid(),
        updated_at = now()
  where id = v_project;
end;
$$;

grant select, insert, update on public.customer_project_assignments to authenticated;
grant execute on function public.list_customer_project_assignments(uuid, uuid) to authenticated;
grant execute on function public.set_customer_project_assignments(uuid, uuid, uuid[]) to authenticated;
