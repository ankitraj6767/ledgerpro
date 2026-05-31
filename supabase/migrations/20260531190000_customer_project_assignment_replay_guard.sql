-- Replay guard for migrations generated after earlier future-stamped files.
-- Keeps customer expense edits scoped to assigned projects after all edit/delete RPCs.

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

create or replace function public.delete_project(p_project_id uuid)
returns void
language plpgsql
security definer
set search_path = public, ledger_private, pg_temp
as $$
declare
  v_org uuid;
  v_now timestamptz := now();
  v_uid uuid := auth.uid();
begin
  select organization_id into v_org
  from public.infra_projects
  where id = p_project_id and deleted_at is null;
  if v_org is null then raise exception 'Project not found'; end if;
  if not ledger_private.org_has_role(v_org, array['owner','manager']::public.org_member_role[]) then
    raise exception 'Not permitted to delete projects';
  end if;

  update public.customer_project_assignments
    set deleted_at = v_now, updated_by = v_uid, updated_at = v_now
  where project_id = p_project_id and deleted_at is null;

  update public.project_investments
    set deleted_at = v_now, updated_by = v_uid, updated_at = v_now
  where project_id = p_project_id and deleted_at is null;

  update public.government_fund_receipts
    set deleted_at = v_now, updated_by = v_uid, updated_at = v_now
  where project_id = p_project_id and deleted_at is null;

  update public.government_funds
    set deleted_at = v_now, updated_by = v_uid, updated_at = v_now
  where project_id = p_project_id and deleted_at is null;

  update public.project_expenses
    set deleted_at = v_now, updated_by = v_uid, updated_at = v_now
  where project_id = p_project_id and deleted_at is null;

  update public.project_notes
    set deleted_at = v_now, updated_by = v_uid, updated_at = v_now
  where project_id = p_project_id and deleted_at is null;

  update public.project_documents
    set deleted_at = v_now
  where project_id = p_project_id and deleted_at is null;

  update public.project_progress_updates
    set deleted_at = v_now
  where project_id = p_project_id and deleted_at is null;

  update public.infra_projects
    set deleted_at = v_now, updated_by = v_uid, updated_at = v_now
  where id = p_project_id;
end;
$$;
