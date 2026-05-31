-- =============================================================================
-- Royal Infra — customer role, workspace lookup, and customer-safe expense rules
-- =============================================================================

alter type public.org_member_role add value if not exists 'customer';

alter table public.organization_members
  add column if not exists notes text;

-- ---------------------------------------------------------------------------
-- Central role helpers. Keep authorization in organization_members, never in
-- user-editable auth metadata or Flutter-only state.
-- ---------------------------------------------------------------------------
create or replace function ledger_private.current_org_role(target_org_id uuid)
returns public.org_member_role
language sql
stable
security definer
set search_path = public, ledger_private, pg_temp
as $$
  select m.role
  from public.organization_members m
  where m.organization_id = target_org_id
    and m.user_id = auth.uid()
    and m.deleted_at is null
  order by m.created_at
  limit 1;
$$;

create or replace function ledger_private.is_org_customer(target_org_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public, ledger_private, pg_temp
as $$
  select coalesce((ledger_private.current_org_role(target_org_id))::text = 'customer', false);
$$;

create or replace function ledger_private.can_read_org(target_org_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public, ledger_private, pg_temp
as $$
  select coalesce(
    (ledger_private.current_org_role(target_org_id))::text in
      ('owner', 'manager', 'accountant', 'site_staff', 'viewer', 'customer'),
    false
  );
$$;

create or replace function ledger_private.can_manage_org(target_org_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public, ledger_private, pg_temp
as $$
  select coalesce(
    (ledger_private.current_org_role(target_org_id))::text in ('owner', 'manager'),
    false
  );
$$;

create or replace function ledger_private.can_manage_projects(target_org_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public, ledger_private, pg_temp
as $$
  select coalesce(
    (ledger_private.current_org_role(target_org_id))::text in ('owner', 'manager', 'accountant'),
    false
  );
$$;

create or replace function ledger_private.can_manage_financial_admin_data(target_org_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public, ledger_private, pg_temp
as $$
  select ledger_private.can_manage_projects(target_org_id);
$$;

create or replace function ledger_private.can_add_or_edit_expenses(target_org_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public, ledger_private, pg_temp
as $$
  select coalesce(
    (ledger_private.current_org_role(target_org_id))::text in
      ('owner', 'manager', 'accountant', 'site_staff', 'customer'),
    false
  );
$$;

create or replace function ledger_private.can_delete_expenses(target_org_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public, ledger_private, pg_temp
as $$
  select coalesce(
    (ledger_private.current_org_role(target_org_id))::text in ('owner', 'manager', 'accountant'),
    false
  );
$$;

-- Fetch the caller's existing workspace without creating one. This prevents a
-- customer with a valid auth account but no membership from becoming an owner
-- through the old bootstrap flow.
create or replace function public.get_my_infra_workspace()
returns table (
  out_organization_id uuid,
  out_organization_name text,
  out_role public.org_member_role
)
language plpgsql
stable
security definer
set search_path = public, ledger_private, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'Authentication required';
  end if;

  return query
  select o.id, o.name, m.role
  from public.organization_members m
  join public.organizations o
    on o.id = m.organization_id
   and o.deleted_at is null
  where m.user_id = v_uid
    and m.deleted_at is null
  order by m.created_at
  limit 1;

  if not found then
    raise exception 'No organization access. Ask admin to invite/create your account.';
  end if;
end;
$$;

-- Owner/manager-only customer list for the admin UI.
create or replace function public.list_customer_members(p_organization_id uuid)
returns table (
  member_id uuid,
  user_id uuid,
  full_name text,
  email text,
  phone text,
  notes text,
  role public.org_member_role,
  created_at timestamptz
)
language plpgsql
stable
security definer
set search_path = public, auth, ledger_private, pg_temp
as $$
begin
  if not ledger_private.can_manage_org(p_organization_id) then
    raise exception 'Not permitted to manage customers';
  end if;

  return query
  select m.id,
         m.user_id,
         p.full_name,
         u.email::text,
         p.phone,
         m.notes,
         m.role,
         m.created_at
  from public.organization_members m
  left join public.profiles p on p.id = m.user_id
  left join auth.users u on u.id = m.user_id
  where m.organization_id = p_organization_id
    and m.deleted_at is null
    and m.role::text = 'customer'
  order by m.created_at desc;
end;
$$;

-- ---------------------------------------------------------------------------
-- Expense RLS: customers can add/edit expenses, only their own on update, and
-- never delete. Select remains open to all organization members.
-- ---------------------------------------------------------------------------
drop policy if exists "expenses_write" on public.project_expenses;
drop policy if exists "expenses_insert" on public.project_expenses;
drop policy if exists "expenses_update" on public.project_expenses;
drop policy if exists "expenses_delete" on public.project_expenses;

create policy "expenses_insert" on public.project_expenses
  for insert to authenticated
  with check (ledger_private.can_add_or_edit_expenses(organization_id));

create policy "expenses_update" on public.project_expenses
  for update to authenticated
  using (
    ledger_private.can_add_or_edit_expenses(organization_id)
    and (
      not ledger_private.is_org_customer(organization_id)
      or created_by = auth.uid()
    )
  )
  with check (
    ledger_private.can_add_or_edit_expenses(organization_id)
    and (
      not ledger_private.is_org_customer(organization_id)
      or created_by = auth.uid()
    )
  );

create policy "expenses_delete" on public.project_expenses
  for delete to authenticated
  using (ledger_private.can_delete_expenses(organization_id));

-- ---------------------------------------------------------------------------
-- Expense RPCs: preserve atomic totals while applying the same customer rules.
-- ---------------------------------------------------------------------------
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
  select organization_id
    into org_id
  from public.infra_projects
  where id = p_project_id
    and deleted_at is null;

  if org_id is null then
    raise exception 'Project not found';
  end if;
  if not ledger_private.can_add_or_edit_expenses(org_id) then
    raise exception 'Not permitted to add expenses';
  end if;
  if p_amount_paise <= 0 then
    raise exception 'Expense amount must be greater than zero';
  end if;

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
  if not ledger_private.can_add_or_edit_expenses(v_org) then
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

create or replace function public.delete_project_expense(p_expense_id uuid)
returns void
language plpgsql
security definer
set search_path = public, ledger_private, pg_temp
as $$
declare
  v_org uuid;
  v_project uuid;
  v_amount bigint;
begin
  select organization_id, project_id, amount_paise
    into v_org, v_project, v_amount
  from public.project_expenses
  where id = p_expense_id
    and deleted_at is null;

  if v_org is null then
    raise exception 'Expense not found';
  end if;
  if not ledger_private.can_delete_expenses(v_org) then
    raise exception 'Not permitted to delete expenses';
  end if;

  update public.project_expenses
    set deleted_at = now(),
        updated_by = auth.uid(),
        updated_at = now()
  where id = p_expense_id;

  update public.infra_projects
    set total_expense_paise = greatest(total_expense_paise - v_amount, 0),
        updated_by = auth.uid(),
        updated_at = now()
  where id = v_project;
end;
$$;

revoke execute on function public.get_my_infra_workspace() from anon;
grant execute on function public.get_my_infra_workspace() to authenticated;
grant execute on function public.list_customer_members(uuid) to authenticated;
grant execute on function public.add_project_expense(uuid, text, bigint, text, date, text, text, text, text) to authenticated;
grant execute on function public.update_project_expense(uuid, text, bigint, text, date, text, text, text) to authenticated;
grant execute on function public.delete_project_expense(uuid) to authenticated;
