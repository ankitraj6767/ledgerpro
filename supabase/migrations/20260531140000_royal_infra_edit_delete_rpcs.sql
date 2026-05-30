-- =============================================================================
-- Royal Infra — edit + (soft) delete RPCs for investments, expenses, funds,
-- receipts. Hard deletes are blocked by triggers, so these soft-delete and
-- atomically reverse the project/fund running totals.
-- =============================================================================

-- ---------------------------------------------------------------------------
-- Investments
-- ---------------------------------------------------------------------------
create or replace function public.update_project_investment(
  p_investment_id uuid,
  p_investor_id uuid,
  p_amount_paise bigint,
  p_investment_date date default current_date,
  p_payment_mode text default 'bank',
  p_reference_number text default null,
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
begin
  select organization_id, project_id, amount_paise
    into v_org, v_project, v_old
  from public.project_investments
  where id = p_investment_id and deleted_at is null;
  if v_org is null then raise exception 'Investment not found'; end if;
  if not ledger_private.org_has_role(v_org, array['owner','manager','accountant']::public.org_member_role[]) then
    raise exception 'Not permitted to edit investments';
  end if;
  if p_amount_paise <= 0 then raise exception 'Investment amount must be greater than zero'; end if;

  update public.project_investments
    set investor_id = p_investor_id,
        amount_paise = p_amount_paise,
        investment_date = p_investment_date,
        payment_mode = p_payment_mode,
        reference_number = p_reference_number,
        notes = p_notes,
        updated_by = auth.uid(),
        updated_at = now()
  where id = p_investment_id;

  update public.infra_projects
    set total_investment_paise = greatest(total_investment_paise - v_old + p_amount_paise, 0),
        updated_by = auth.uid(), updated_at = now()
  where id = v_project;
end;
$$;

create or replace function public.delete_project_investment(p_investment_id uuid)
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
  from public.project_investments
  where id = p_investment_id and deleted_at is null;
  if v_org is null then raise exception 'Investment not found'; end if;
  if not ledger_private.org_has_role(v_org, array['owner','manager','accountant']::public.org_member_role[]) then
    raise exception 'Not permitted to delete investments';
  end if;

  update public.project_investments
    set deleted_at = now(), updated_by = auth.uid(), updated_at = now()
  where id = p_investment_id;

  update public.infra_projects
    set total_investment_paise = greatest(total_investment_paise - v_amount, 0),
        updated_by = auth.uid(), updated_at = now()
  where id = v_project;
end;
$$;

-- ---------------------------------------------------------------------------
-- Expenses
-- ---------------------------------------------------------------------------
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
begin
  select organization_id, project_id, amount_paise
    into v_org, v_project, v_old
  from public.project_expenses
  where id = p_expense_id and deleted_at is null;
  if v_org is null then raise exception 'Expense not found'; end if;
  if not ledger_private.org_has_role(v_org, array['owner','manager','accountant','site_staff']::public.org_member_role[]) then
    raise exception 'Not permitted to edit expenses';
  end if;
  if p_amount_paise <= 0 then raise exception 'Expense amount must be greater than zero'; end if;

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
        updated_by = auth.uid(), updated_at = now()
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
  where id = p_expense_id and deleted_at is null;
  if v_org is null then raise exception 'Expense not found'; end if;
  if not ledger_private.org_has_role(v_org, array['owner','manager','accountant','site_staff']::public.org_member_role[]) then
    raise exception 'Not permitted to delete expenses';
  end if;

  update public.project_expenses
    set deleted_at = now(), updated_by = auth.uid(), updated_at = now()
  where id = p_expense_id;

  update public.infra_projects
    set total_expense_paise = greatest(total_expense_paise - v_amount, 0),
        updated_by = auth.uid(), updated_at = now()
  where id = v_project;
end;
$$;

-- ---------------------------------------------------------------------------
-- Government funds (edit basic details + sanctioned amount; delete cascades)
-- ---------------------------------------------------------------------------
create or replace function public.update_government_fund(
  p_fund_id uuid,
  p_department_name text,
  p_scheme_name text default null,
  p_sanction_order_number text default null,
  p_amount_sanctioned_paise bigint default 0,
  p_sanction_date date default null,
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
  v_old_sanctioned bigint;
  v_received bigint;
begin
  select organization_id, project_id, amount_sanctioned_paise, amount_received_paise
    into v_org, v_project, v_old_sanctioned, v_received
  from public.government_funds
  where id = p_fund_id and deleted_at is null;
  if v_org is null then raise exception 'Government fund not found'; end if;
  if not ledger_private.org_has_role(v_org, array['owner','manager','accountant']::public.org_member_role[]) then
    raise exception 'Not permitted to edit government funds';
  end if;
  if p_amount_sanctioned_paise < v_received then
    raise exception 'Sanctioned amount cannot be less than the amount already received';
  end if;

  update public.government_funds
    set department_name = p_department_name,
        scheme_name = p_scheme_name,
        sanction_order_number = p_sanction_order_number,
        amount_sanctioned_paise = greatest(p_amount_sanctioned_paise, 0),
        sanction_date = p_sanction_date,
        notes = p_notes,
        status = case
          when v_received >= greatest(p_amount_sanctioned_paise, 0) and v_received > 0 then 'fully_received'
          when v_received > 0 then 'partially_received'
          else 'sanctioned'
        end,
        updated_by = auth.uid(), updated_at = now()
  where id = p_fund_id;

  update public.infra_projects
    set total_govt_sanctioned_paise =
          greatest(total_govt_sanctioned_paise - v_old_sanctioned + greatest(p_amount_sanctioned_paise, 0), 0),
        updated_by = auth.uid(), updated_at = now()
  where id = v_project;
end;
$$;

create or replace function public.delete_government_fund(p_fund_id uuid)
returns void
language plpgsql
security definer
set search_path = public, ledger_private, pg_temp
as $$
declare
  v_org uuid;
  v_project uuid;
  v_sanctioned bigint;
  v_received bigint;
begin
  select organization_id, project_id, amount_sanctioned_paise, amount_received_paise
    into v_org, v_project, v_sanctioned, v_received
  from public.government_funds
  where id = p_fund_id and deleted_at is null;
  if v_org is null then raise exception 'Government fund not found'; end if;
  if not ledger_private.org_has_role(v_org, array['owner','manager','accountant']::public.org_member_role[]) then
    raise exception 'Not permitted to delete government funds';
  end if;

  -- Soft-delete the fund and all its receipts.
  update public.government_funds
    set deleted_at = now(), updated_by = auth.uid(), updated_at = now()
  where id = p_fund_id;

  update public.government_fund_receipts
    set deleted_at = now(), updated_by = auth.uid(), updated_at = now()
  where government_fund_id = p_fund_id and deleted_at is null;

  -- Reverse both sanctioned and received totals on the project.
  update public.infra_projects
    set total_govt_sanctioned_paise = greatest(total_govt_sanctioned_paise - v_sanctioned, 0),
        total_govt_received_paise = greatest(total_govt_received_paise - v_received, 0),
        updated_by = auth.uid(), updated_at = now()
  where id = v_project;
end;
$$;

-- ---------------------------------------------------------------------------
-- Government fund receipts (delete reverses received totals)
-- ---------------------------------------------------------------------------
create or replace function public.delete_government_receipt(p_receipt_id uuid)
returns void
language plpgsql
security definer
set search_path = public, ledger_private, pg_temp
as $$
declare
  v_org uuid;
  v_project uuid;
  v_fund uuid;
  v_amount bigint;
  v_sanctioned bigint;
  v_received_after bigint;
begin
  select organization_id, project_id, government_fund_id, amount_paise
    into v_org, v_project, v_fund, v_amount
  from public.government_fund_receipts
  where id = p_receipt_id and deleted_at is null;
  if v_org is null then raise exception 'Receipt not found'; end if;
  if not ledger_private.org_has_role(v_org, array['owner','manager','accountant']::public.org_member_role[]) then
    raise exception 'Not permitted to delete receipts';
  end if;

  update public.government_fund_receipts
    set deleted_at = now(), updated_by = auth.uid(), updated_at = now()
  where id = p_receipt_id;

  update public.government_funds
    set amount_received_paise = greatest(amount_received_paise - v_amount, 0),
        updated_by = auth.uid(), updated_at = now()
  where id = v_fund
  returning amount_sanctioned_paise, amount_received_paise
    into v_sanctioned, v_received_after;

  update public.government_funds
    set status = case
          when v_received_after >= v_sanctioned and v_received_after > 0 then 'fully_received'
          when v_received_after > 0 then 'partially_received'
          else 'sanctioned'
        end
  where id = v_fund;

  update public.infra_projects
    set total_govt_received_paise = greatest(total_govt_received_paise - v_amount, 0),
        updated_by = auth.uid(), updated_at = now()
  where id = v_project;
end;
$$;

-- Grants
grant execute on function public.update_project_investment(uuid, uuid, bigint, date, text, text, text) to authenticated;
grant execute on function public.delete_project_investment(uuid) to authenticated;
grant execute on function public.update_project_expense(uuid, text, bigint, text, date, text, text, text) to authenticated;
grant execute on function public.delete_project_expense(uuid) to authenticated;
grant execute on function public.update_government_fund(uuid, text, text, text, bigint, date, text) to authenticated;
grant execute on function public.delete_government_fund(uuid) to authenticated;
grant execute on function public.delete_government_receipt(uuid) to authenticated;
