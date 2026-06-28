-- Keep gross contributions and returned capital as separate aggregates so all
-- app surfaces can derive net investment consistently without losing history.
alter table public.infra_projects
  add column if not exists total_investment_returned_paise bigint not null default 0
  check (total_investment_returned_paise >= 0);

comment on column public.infra_projects.total_investment_returned_paise is
  'Sum of non-deleted investment_returns for this project, in paise.';

create or replace function ledger_private.sync_project_investment_returned()
returns trigger
language plpgsql
security definer
set search_path = public, ledger_private, pg_temp
as $$
declare
  v_project_id uuid;
begin
  v_project_id := case when tg_op = 'DELETE' then old.project_id else new.project_id end;

  update public.infra_projects p
  set total_investment_returned_paise = coalesce((
        select sum(r.amount_paise)
        from public.investment_returns r
        where r.project_id = v_project_id
          and r.deleted_at is null
      ), 0),
      updated_at = now()
  where p.id = v_project_id;

  if tg_op = 'UPDATE' and old.project_id is distinct from new.project_id then
    update public.infra_projects p
    set total_investment_returned_paise = coalesce((
          select sum(r.amount_paise)
          from public.investment_returns r
          where r.project_id = old.project_id
            and r.deleted_at is null
        ), 0),
        updated_at = now()
    where p.id = old.project_id;
  end if;

  if tg_op = 'DELETE' then
    return old;
  end if;
  return new;
end;
$$;

revoke all on function ledger_private.sync_project_investment_returned()
  from public, anon, authenticated;

drop trigger if exists sync_project_investment_returned
  on public.investment_returns;
create trigger sync_project_investment_returned
after insert or update or delete on public.investment_returns
for each row execute function ledger_private.sync_project_investment_returned();

-- Correct all projects that already have return history.
update public.infra_projects p
set total_investment_returned_paise = coalesce((
  select sum(r.amount_paise)
  from public.investment_returns r
  where r.project_id = p.id
    and r.deleted_at is null
), 0);

-- Preserve the existing RPC response shape while returning net investment.
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
    coalesce(sum(greatest(p.total_investment_paise - p.total_investment_returned_paise, 0)) filter (where p.deleted_at is null and ledger_private.can_read_project(p.id)), 0),
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
    greatest(p.total_investment_paise - p.total_investment_returned_paise, 0),
    p.total_govt_sanctioned_paise,
    p.total_govt_received_paise,
    greatest(p.total_govt_sanctioned_paise - p.total_govt_received_paise, 0),
    p.total_expense_paise,
    (greatest(p.total_investment_paise - p.total_investment_returned_paise, 0)
      + p.total_govt_received_paise - p.total_expense_paise)
  from public.infra_projects p
  where p.id = p_project_id
    and p.deleted_at is null
    and ledger_private.can_read_project(p.id);
$$;
