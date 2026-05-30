-- =============================================================================
-- Royal Infra — RPC functions (atomic financial operations + summaries)
-- =============================================================================

-- 1) ensure_infra_workspace: profile + organization + owner membership.
create or replace function public.ensure_infra_workspace(
  p_email text default null,
  p_full_name text default null,
  p_org_name text default null
)
returns table (
  out_organization_id uuid,
  out_organization_name text
)
language plpgsql
security definer
set search_path = public, ledger_private, pg_temp
as $$
declare
  user_id uuid := auth.uid();
  found_org_id uuid;
  found_org_name text;
  owner_name text;
begin
  if user_id is null then
    raise exception 'Authentication required';
  end if;

  owner_name := coalesce(
    nullif(trim(p_full_name), ''),
    nullif(split_part(coalesce(p_email, ''), '@', 1), ''),
    'Royal Infra Owner'
  );

  insert into public.profiles (id, full_name, default_language)
  values (user_id, owner_name, 'en')
  on conflict (id) do update
    set full_name = coalesce(public.profiles.full_name, excluded.full_name),
        updated_at = now(),
        deleted_at = null;

  select o.id, o.name
    into found_org_id, found_org_name
  from public.organizations o
  join public.organization_members m
    on m.organization_id = o.id and m.user_id = user_id and m.deleted_at is null
  where o.deleted_at is null
  order by o.created_at
  limit 1;

  if found_org_id is null then
    insert into public.organizations (owner_id, name, owner_name, created_by, updated_by)
    values (
      user_id,
      coalesce(nullif(trim(p_org_name), ''), 'My Organization'),
      owner_name,
      user_id,
      user_id
    )
    returning organizations.id, organizations.name
      into found_org_id, found_org_name;

    insert into public.organization_members (organization_id, user_id, role, created_by, updated_by)
    values (found_org_id, user_id, 'owner', user_id, user_id)
    on conflict (organization_id, user_id) do nothing;
  end if;

  return query select found_org_id, found_org_name;
end;
$$;

-- 2) create_project
create or replace function public.create_project(
  p_organization_id uuid,
  p_name text,
  p_code text default null,
  p_category text default null,
  p_location_city text default null,
  p_location_state text default null,
  p_address text default null,
  p_start_date date default null,
  p_expected_end_date date default null,
  p_estimated_cost_paise bigint default 0,
  p_description text default null
)
returns uuid
language plpgsql
security definer
set search_path = public, ledger_private, pg_temp
as $$
declare
  new_id uuid;
begin
  if not ledger_private.org_has_role(p_organization_id, array['owner','manager','accountant']::public.org_member_role[]) then
    raise exception 'Not permitted to create projects';
  end if;
  if p_expected_end_date is not null and p_start_date is not null
     and p_expected_end_date < p_start_date then
    raise exception 'Expected end date cannot be before start date';
  end if;

  insert into public.infra_projects (
    organization_id, name, code, category, location_city, location_state,
    address, start_date, expected_end_date, total_estimated_cost_paise,
    description, created_by, updated_by
  ) values (
    p_organization_id, p_name, p_code, p_category, p_location_city, p_location_state,
    p_address, p_start_date, p_expected_end_date, greatest(p_estimated_cost_paise, 0),
    p_description, auth.uid(), auth.uid()
  )
  returning id into new_id;
  return new_id;
end;
$$;

-- 3) add_project_investment (atomic: insert + bump project total)
create or replace function public.add_project_investment(
  p_project_id uuid,
  p_investor_id uuid,
  p_amount_paise bigint,
  p_investment_date date default current_date,
  p_payment_mode text default 'bank',
  p_reference_number text default null,
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
  if not ledger_private.org_has_role(org_id, array['owner','manager','accountant']::public.org_member_role[]) then
    raise exception 'Not permitted to add investments';
  end if;
  if p_amount_paise <= 0 then raise exception 'Investment amount must be greater than zero'; end if;

  insert into public.project_investments (
    organization_id, project_id, investor_id, amount_paise, investment_date,
    payment_mode, reference_number, notes, created_by, updated_by
  ) values (
    org_id, p_project_id, p_investor_id, p_amount_paise, p_investment_date,
    p_payment_mode, p_reference_number, p_notes, auth.uid(), auth.uid()
  )
  returning id into new_id;

  update public.infra_projects
    set total_investment_paise = total_investment_paise + p_amount_paise,
        updated_by = auth.uid(), updated_at = now()
  where id = p_project_id;

  return new_id;
end;
$$;

-- 4) add_government_fund
create or replace function public.add_government_fund(
  p_project_id uuid,
  p_department_name text,
  p_scheme_name text default null,
  p_sanction_order_number text default null,
  p_amount_sanctioned_paise bigint default 0,
  p_sanction_date date default null,
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
  new_id uuid;
begin
  select organization_id into org_id from public.infra_projects where id = p_project_id and deleted_at is null;
  if org_id is null then raise exception 'Project not found'; end if;
  if not ledger_private.org_has_role(org_id, array['owner','manager','accountant']::public.org_member_role[]) then
    raise exception 'Not permitted to add government funds';
  end if;

  insert into public.government_funds (
    organization_id, project_id, department_name, scheme_name, sanction_order_number,
    amount_sanctioned_paise, sanction_date, document_path, notes, created_by, updated_by
  ) values (
    org_id, p_project_id, p_department_name, p_scheme_name, p_sanction_order_number,
    greatest(p_amount_sanctioned_paise, 0), p_sanction_date, p_document_path, p_notes,
    auth.uid(), auth.uid()
  )
  returning id into new_id;

  update public.infra_projects
    set total_govt_sanctioned_paise = total_govt_sanctioned_paise + greatest(p_amount_sanctioned_paise, 0),
        updated_by = auth.uid(), updated_at = now()
  where id = p_project_id;

  return new_id;
end;
$$;

-- 5) add_government_fund_receipt (validates against sanctioned; updates fund + project)
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
        status = case
          when amount_received_paise + p_amount_paise >= sanctioned then 'fully_received'
          else 'partially_received'
        end,
        updated_by = auth.uid(), updated_at = now()
  where id = p_government_fund_id;

  update public.infra_projects
    set total_govt_received_paise = total_govt_received_paise + p_amount_paise,
        updated_by = auth.uid(), updated_at = now()
  where id = proj_id;

  return new_id;
end;
$$;

-- 6) add_project_expense (atomic: insert + bump project total)
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
  if not ledger_private.org_has_role(org_id, array['owner','manager','accountant','site_staff']::public.org_member_role[]) then
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
        updated_by = auth.uid(), updated_at = now()
  where id = p_project_id;

  return new_id;
end;
$$;

-- 7) update_project_progress
create or replace function public.update_project_progress(
  p_project_id uuid,
  p_progress_percent integer,
  p_note text default null
)
returns void
language plpgsql
security definer
set search_path = public, ledger_private, pg_temp
as $$
declare
  org_id uuid;
begin
  select organization_id into org_id from public.infra_projects where id = p_project_id and deleted_at is null;
  if org_id is null then raise exception 'Project not found'; end if;
  if not ledger_private.org_has_role(org_id, array['owner','manager','accountant','site_staff']::public.org_member_role[]) then
    raise exception 'Not permitted to update progress';
  end if;
  if p_progress_percent < 0 or p_progress_percent > 100 then
    raise exception 'Progress must be between 0 and 100';
  end if;

  insert into public.project_progress_updates (organization_id, project_id, progress_percent, note, created_by)
  values (org_id, p_project_id, p_progress_percent, p_note, auth.uid());

  update public.infra_projects
    set progress_percent = p_progress_percent,
        updated_by = auth.uid(), updated_at = now()
  where id = p_project_id;
end;
$$;

-- 8) dashboard_summary
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
    count(*) filter (where p.deleted_at is null),
    count(*) filter (where p.deleted_at is null and p.status = 'active'),
    count(*) filter (where p.deleted_at is null and p.status = 'completed'),
    count(*) filter (where p.deleted_at is null and p.status = 'on_hold'),
    coalesce(sum(p.total_investment_paise) filter (where p.deleted_at is null), 0),
    coalesce(sum(p.total_govt_sanctioned_paise) filter (where p.deleted_at is null), 0),
    coalesce(sum(p.total_govt_received_paise) filter (where p.deleted_at is null), 0),
    coalesce(sum(p.total_expense_paise) filter (where p.deleted_at is null), 0),
    coalesce(sum(greatest(p.total_govt_sanctioned_paise - p.total_govt_received_paise, 0)) filter (where p.deleted_at is null), 0)
  from public.infra_projects p
  where p.organization_id = p_organization_id
    and ledger_private.is_org_member(p_organization_id);
$$;

-- 9) project_financial_summary
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
    and ledger_private.is_org_member(p.organization_id);
$$;

-- 10) search_projects
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
    and ledger_private.is_org_member(p_organization_id)
    and (
      coalesce(trim(p_query), '') = ''
      or p.search_vector @@ plainto_tsquery('simple', p_query)
      or p.name ilike '%' || p_query || '%'
    )
  order by p.updated_at desc;
$$;

-- Grants.
revoke execute on function public.ensure_infra_workspace(text, text, text) from anon;
grant execute on function public.ensure_infra_workspace(text, text, text) to authenticated;
grant execute on function public.create_project(uuid, text, text, text, text, text, text, date, date, bigint, text) to authenticated;
grant execute on function public.add_project_investment(uuid, uuid, bigint, date, text, text, text) to authenticated;
grant execute on function public.add_government_fund(uuid, text, text, text, bigint, date, text, text) to authenticated;
grant execute on function public.add_government_fund_receipt(uuid, bigint, date, text, text, text, text) to authenticated;
grant execute on function public.add_project_expense(uuid, text, bigint, text, date, text, text, text, text) to authenticated;
grant execute on function public.update_project_progress(uuid, integer, text) to authenticated;
grant execute on function public.dashboard_summary(uuid) to authenticated;
grant execute on function public.project_financial_summary(uuid) to authenticated;
grant execute on function public.search_projects(uuid, text) to authenticated;
