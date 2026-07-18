-- Add an editable path for government fund receipts.
--
-- Receipts could previously only be created (add_government_fund_receipt) or
-- soft-deleted (delete_government_receipt). This adds
-- update_government_fund_receipt so an existing receipt's amount, date,
-- payment mode, reference and notes can be changed while keeping every derived
-- total in sync atomically:
--   * government_funds.amount_received_paise  (adjusted by the amount delta)
--   * government_funds.status                 (recomputed from received vs sanctioned)
--   * government_funds.last_received_date      (recomputed as the max receipt date)
--   * infra_projects.total_govt_received_paise (adjusted by the amount delta)
--
-- The new received total is validated so it can never exceed the sanctioned
-- amount, mirroring the guard in add_government_fund_receipt.

create or replace function public.update_government_fund_receipt(
  p_receipt_id uuid,
  p_amount_paise bigint,
  p_received_date date default current_date,
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
  v_fund uuid;
  v_old_amount bigint;
  v_sanctioned bigint;
  v_received bigint;
  v_new_received bigint;
  v_last_received date;
begin
  select organization_id, project_id, government_fund_id, amount_paise
    into v_org, v_project, v_fund, v_old_amount
  from public.government_fund_receipts
  where id = p_receipt_id and deleted_at is null;
  if v_org is null then raise exception 'Receipt not found'; end if;
  if not ledger_private.org_has_role(v_org, array['owner','manager','accountant']::public.org_member_role[]) then
    raise exception 'Not permitted to edit receipts';
  end if;
  if p_amount_paise <= 0 then raise exception 'Receipt amount must be greater than zero'; end if;

  select amount_sanctioned_paise, amount_received_paise
    into v_sanctioned, v_received
  from public.government_funds
  where id = v_fund and deleted_at is null;
  if v_sanctioned is null then raise exception 'Government fund not found'; end if;

  v_new_received := v_received - v_old_amount + p_amount_paise;
  if v_new_received > v_sanctioned then
    raise exception 'Receipt exceeds pending sanctioned amount';
  end if;

  update public.government_fund_receipts
    set amount_paise = p_amount_paise,
        received_date = p_received_date,
        payment_mode = p_payment_mode,
        reference_number = p_reference_number,
        notes = p_notes,
        updated_by = auth.uid(),
        updated_at = now()
  where id = p_receipt_id;

  -- Recompute the latest received date across the fund's live receipts so the
  -- fund summary stays accurate even when the edited date is moved earlier.
  select max(received_date)
    into v_last_received
  from public.government_fund_receipts
  where government_fund_id = v_fund and deleted_at is null;

  update public.government_funds
    set amount_received_paise = greatest(v_new_received, 0),
        last_received_date = v_last_received,
        status = (case
          when greatest(v_new_received, 0) >= v_sanctioned and v_new_received > 0 then 'fully_received'
          when v_new_received > 0 then 'partially_received'
          else 'sanctioned'
        end)::public.govt_fund_status,
        updated_by = auth.uid(),
        updated_at = now()
  where id = v_fund;

  update public.infra_projects
    set total_govt_received_paise =
          greatest(total_govt_received_paise - v_old_amount + p_amount_paise, 0),
        updated_by = auth.uid(),
        updated_at = now()
  where id = v_project;
end;
$$;

grant execute on function public.update_government_fund_receipt(uuid, bigint, date, text, text, text) to authenticated;
