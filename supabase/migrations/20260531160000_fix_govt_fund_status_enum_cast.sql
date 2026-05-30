-- Fix: "column \"status\" is of type govt_fund_status but expression is of type
-- text" (42804). A CASE expression returns text, which Postgres will not
-- implicitly assign to an enum column. Wrap the CASE result in an explicit
-- ::public.govt_fund_status cast in every function that sets status via CASE.
-- (Reconstructed file; already applied on remote.)

create or replace function public.add_government_fund_receipt(
  p_government_fund_id uuid,
  p_amount_paise bigint,
  p_received_date date default current_date,
  p_payment_mode text default 'bank',
  p_reference_number text default null,
  p_document_path text default null,
  p_notes text default null
)
returns uuid
language plpgsql
security definer
set search_path = public, ledger_private, pg_temp
as $$
declare
  org_id uuid;
  proj_id uuid;
  sanctioned bigint;
  received bigint;
  new_id uuid;
begin
  select organization_id, project_id, amount_sanctioned_paise, amount_received_paise
    into org_id, proj_id, sanctioned, received
  from public.government_funds where id = p_government_fund_id and deleted_at is null;
  if org_id is null then raise exception 'Government fund not found'; end if;
  if not ledger_private.org_has_role(org_id, array['owner','manager','accountant']::public.org_member_role[]) then
    raise exception 'Not permitted to add receipts';
  end if;
  if p_amount_paise <= 0 then raise exception 'Receipt amount must be greater than zero'; end if;
  if received + p_amount_paise > sanctioned then
    raise exception 'Receipt exceeds pending sanctioned amount';
  end if;

  insert into public.government_fund_receipts (
    organization_id, government_fund_id, project_id, amount_paise, received_date,
    payment_mode, reference_number, document_path, notes, created_by, updated_by
  ) values (
    org_id, p_government_fund_id, proj_id, p_amount_paise, p_received_date,
    p_payment_mode, p_reference_number, p_document_path, p_notes, auth.uid(), auth.uid()
  )
  returning id into new_id;

  update public.government_funds
    set amount_received_paise = amount_received_paise + p_amount_paise,
        last_received_date = p_received_date,
        status = (case
          when amount_received_paise + p_amount_paise >= sanctioned then 'fully_received'
          else 'partially_received'
        end)::public.govt_fund_status,
        updated_by = auth.uid(), updated_at = now()
  where id = p_government_fund_id;

  update public.infra_projects
    set total_govt_received_paise = total_govt_received_paise + p_amount_paise,
        updated_by = auth.uid(), updated_at = now()
  where id = proj_id;

  return new_id;
end;
$$;

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
        status = (case
          when v_received >= greatest(p_amount_sanctioned_paise, 0) and v_received > 0 then 'fully_received'
          when v_received > 0 then 'partially_received'
          else 'sanctioned'
        end)::public.govt_fund_status,
        updated_by = auth.uid(), updated_at = now()
  where id = p_fund_id;

  update public.infra_projects
    set total_govt_sanctioned_paise =
          greatest(total_govt_sanctioned_paise - v_old_sanctioned + greatest(p_amount_sanctioned_paise, 0), 0),
        updated_by = auth.uid(), updated_at = now()
  where id = v_project;
end;
$$;

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
    set status = (case
          when v_received_after >= v_sanctioned and v_received_after > 0 then 'fully_received'
          when v_received_after > 0 then 'partially_received'
          else 'sanctioned'
        end)::public.govt_fund_status
  where id = v_fund;

  update public.infra_projects
    set total_govt_received_paise = greatest(total_govt_received_paise - v_amount, 0),
        updated_by = auth.uid(), updated_at = now()
  where id = v_project;
end;
$$;

grant execute on function public.add_government_fund_receipt(uuid, bigint, date, text, text, text, text) to authenticated;
grant execute on function public.update_government_fund(uuid, text, text, text, bigint, date, text) to authenticated;
grant execute on function public.delete_government_receipt(uuid) to authenticated;
