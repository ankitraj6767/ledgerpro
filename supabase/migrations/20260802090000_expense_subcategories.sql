-- =============================================================================
-- Royal Infra — nested expense categories
--
-- The existing category column and RPCs remain untouched for old app builds.
-- New clients write the optional child through dedicated RPCs, so old rows and
-- old clients continue to work while parent/child values stay queryable.
-- =============================================================================

alter table public.project_expenses
  add column if not exists subcategory text;

create index if not exists expenses_project_category_idx
  on public.project_expenses (project_id, category, subcategory)
  where deleted_at is null;

create or replace function public.add_project_expense_with_subcategory(
  p_project_id uuid,
  p_category text,
  p_subcategory text,
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
  if coalesce(trim(p_category), '') = '' then
    raise exception 'Expense category is required';
  end if;

  select organization_id
    into org_id
  from public.infra_projects
  where id = p_project_id
    and deleted_at is null;

  if org_id is null then
    raise exception 'Project not found';
  end if;
  if not ledger_private.can_add_or_edit_expenses(org_id)
     or not ledger_private.can_read_project(p_project_id) then
    raise exception 'Not permitted to add expenses';
  end if;
  if p_amount_paise <= 0 then
    raise exception 'Expense amount must be greater than zero';
  end if;

  insert into public.project_expenses (
    organization_id,
    project_id,
    category,
    subcategory,
    vendor_name,
    amount_paise,
    expense_date,
    payment_mode,
    bill_number,
    bill_image_path,
    notes,
    created_by,
    updated_by
  ) values (
    org_id,
    p_project_id,
    trim(p_category),
    nullif(trim(p_subcategory), ''),
    p_vendor_name,
    p_amount_paise,
    p_expense_date,
    p_payment_mode,
    p_bill_number,
    p_bill_image_path,
    p_notes,
    auth.uid(),
    auth.uid()
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

create or replace function public.update_project_expense_with_subcategory(
  p_expense_id uuid,
  p_category text,
  p_subcategory text,
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
  if coalesce(trim(p_category), '') = '' then
    raise exception 'Expense category is required';
  end if;

  select organization_id, project_id, amount_paise, created_by
    into v_org, v_project, v_old, v_created_by
  from public.project_expenses
  where id = p_expense_id
    and deleted_at is null;

  if v_org is null then
    raise exception 'Expense not found';
  end if;
  if not ledger_private.can_add_or_edit_expenses(v_org)
     or not ledger_private.can_read_project(v_project) then
    raise exception 'Not permitted to edit expenses';
  end if;
  if ledger_private.is_org_customer(v_org)
     and v_created_by is distinct from auth.uid() then
    raise exception 'Customers can edit only expenses they created';
  end if;
  if p_amount_paise <= 0 then
    raise exception 'Expense amount must be greater than zero';
  end if;

  update public.project_expenses
    set category = trim(p_category),
        subcategory = nullif(trim(p_subcategory), ''),
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
    set total_expense_paise = greatest(
          total_expense_paise - v_old + p_amount_paise,
          0
        ),
        updated_by = auth.uid(),
        updated_at = now()
  where id = v_project;
end;
$$;

revoke execute on function public.add_project_expense_with_subcategory(
  uuid, text, text, bigint, text, date, text, text, text, text
) from public, anon;
grant execute on function public.add_project_expense_with_subcategory(
  uuid, text, text, bigint, text, date, text, text, text, text
) to authenticated;

revoke execute on function public.update_project_expense_with_subcategory(
  uuid, text, text, bigint, text, date, text, text, text
) from public, anon;
grant execute on function public.update_project_expense_with_subcategory(
  uuid, text, text, bigint, text, date, text, text, text
) to authenticated;
