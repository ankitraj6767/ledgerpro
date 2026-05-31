-- Keep the Add Investment investor dropdown aligned with live project data.
-- When the last active contribution for an investor is deleted or moved away,
-- archive that investor master record too. Historical contributions remain
-- soft-deleted and auditable, but the investor no longer appears as available.

update public.investors i
set deleted_at = now(),
    updated_at = now()
where i.deleted_at is null
  and exists (
    select 1
    from public.project_investments pi
    where pi.investor_id = i.id
      and pi.deleted_at is not null
  )
  and not exists (
    select 1
    from public.project_investments live_pi
    where live_pi.investor_id = i.id
      and live_pi.deleted_at is null
  );

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
  v_old_investor uuid;
begin
  select organization_id, project_id, amount_paise, investor_id
    into v_org, v_project, v_old, v_old_investor
  from public.project_investments
  where id = p_investment_id and deleted_at is null;
  if v_org is null then raise exception 'Investment not found'; end if;
  if not ledger_private.org_has_role(v_org, array['owner','manager','accountant']::public.org_member_role[]) then
    raise exception 'Not permitted to edit investments';
  end if;
  if p_amount_paise <= 0 then raise exception 'Investment amount must be greater than zero'; end if;
  if not exists (
    select 1
    from public.investors
    where id = p_investor_id
      and organization_id = v_org
      and deleted_at is null
  ) then
    raise exception 'Investor not found';
  end if;

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

  if v_old_investor is distinct from p_investor_id then
    update public.investors i
      set deleted_at = now(),
          updated_by = auth.uid(),
          updated_at = now()
    where i.id = v_old_investor
      and i.organization_id = v_org
      and i.deleted_at is null
      and not exists (
        select 1
        from public.project_investments live_pi
        where live_pi.investor_id = i.id
          and live_pi.deleted_at is null
      );
  end if;
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
  v_investor uuid;
  v_amount bigint;
begin
  select organization_id, project_id, investor_id, amount_paise
    into v_org, v_project, v_investor, v_amount
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

  update public.investors i
    set deleted_at = now(),
        updated_by = auth.uid(),
        updated_at = now()
  where i.id = v_investor
    and i.organization_id = v_org
    and i.deleted_at is null
    and not exists (
      select 1
      from public.project_investments live_pi
      where live_pi.investor_id = i.id
        and live_pi.deleted_at is null
    );
end;
$$;

grant execute on function public.update_project_investment(uuid, uuid, bigint, date, text, text, text) to authenticated;
grant execute on function public.delete_project_investment(uuid) to authenticated;
