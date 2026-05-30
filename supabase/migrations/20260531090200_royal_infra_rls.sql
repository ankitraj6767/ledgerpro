-- =============================================================================
-- Royal Infra — RLS: organization-scoped access control
-- =============================================================================

-- Membership / access helpers.
create or replace function ledger_private.is_org_member(target_org_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public, ledger_private, pg_temp
as $$
  select exists (
    select 1
    from public.organization_members m
    where m.organization_id = target_org_id
      and m.user_id = auth.uid()
      and m.deleted_at is null
  );
$$;

-- Role check. Roles are hierarchical for write access:
--   owner > manager > accountant > site_staff > viewer
create or replace function ledger_private.org_has_role(
  target_org_id uuid,
  allowed_roles public.org_member_role[]
)
returns boolean
language sql
stable
security definer
set search_path = public, ledger_private, pg_temp
as $$
  select exists (
    select 1
    from public.organization_members m
    where m.organization_id = target_org_id
      and m.user_id = auth.uid()
      and m.deleted_at is null
      and m.role = any(allowed_roles)
  );
$$;

-- Enable RLS on all infra tables.
do $$
declare
  t text;
  tables text[] := array[
    'organizations',
    'organization_members',
    'infra_projects',
    'investors',
    'project_investments',
    'government_funds',
    'government_fund_receipts',
    'project_expenses',
    'project_documents',
    'project_notes',
    'project_progress_updates',
    'project_audit_logs'
  ];
begin
  foreach t in array tables loop
    execute format('alter table public.%I enable row level security', t);
  end loop;
end $$;

-- Organizations: members can read; owner can update; any authenticated user
-- can insert their own org (bootstrap via ensure_infra_workspace).
drop policy if exists "orgs_select_members" on public.organizations;
create policy "orgs_select_members" on public.organizations
  for select to authenticated
  using (ledger_private.is_org_member(id));

drop policy if exists "orgs_insert_owner" on public.organizations;
create policy "orgs_insert_owner" on public.organizations
  for insert to authenticated
  with check (owner_id = (select auth.uid()));

drop policy if exists "orgs_update_owner" on public.organizations;
create policy "orgs_update_owner" on public.organizations
  for update to authenticated
  using (ledger_private.org_has_role(id, array['owner','manager']::public.org_member_role[]))
  with check (ledger_private.org_has_role(id, array['owner','manager']::public.org_member_role[]));

-- Organization members: members can read; owner/manager can manage.
drop policy if exists "org_members_select" on public.organization_members;
create policy "org_members_select" on public.organization_members
  for select to authenticated
  using (ledger_private.is_org_member(organization_id));

drop policy if exists "org_members_manage" on public.organization_members;
create policy "org_members_manage" on public.organization_members
  for all to authenticated
  using (ledger_private.org_has_role(organization_id, array['owner','manager']::public.org_member_role[]))
  with check (ledger_private.org_has_role(organization_id, array['owner','manager']::public.org_member_role[]));

-- Allow bootstrap: a user inserting their own owner membership row.
drop policy if exists "org_members_bootstrap_self" on public.organization_members;
create policy "org_members_bootstrap_self" on public.organization_members
  for insert to authenticated
  with check (user_id = (select auth.uid()));

-- Helper to write standard policies for a project-scoped table:
--   select: any member
--   write : roles vary per table (passed in)
-- We inline policies below for clarity.

-- Projects: members read; owner/manager/accountant write.
drop policy if exists "projects_select" on public.infra_projects;
create policy "projects_select" on public.infra_projects
  for select to authenticated
  using (ledger_private.is_org_member(organization_id));

drop policy if exists "projects_write" on public.infra_projects;
create policy "projects_write" on public.infra_projects
  for all to authenticated
  using (ledger_private.org_has_role(organization_id, array['owner','manager','accountant']::public.org_member_role[]))
  with check (ledger_private.org_has_role(organization_id, array['owner','manager','accountant']::public.org_member_role[]));

-- Investors.
drop policy if exists "investors_select" on public.investors;
create policy "investors_select" on public.investors
  for select to authenticated
  using (ledger_private.is_org_member(organization_id));

drop policy if exists "investors_write" on public.investors;
create policy "investors_write" on public.investors
  for all to authenticated
  using (ledger_private.org_has_role(organization_id, array['owner','manager','accountant']::public.org_member_role[]))
  with check (ledger_private.org_has_role(organization_id, array['owner','manager','accountant']::public.org_member_role[]));

-- Investments.
drop policy if exists "investments_select" on public.project_investments;
create policy "investments_select" on public.project_investments
  for select to authenticated
  using (ledger_private.is_org_member(organization_id));

drop policy if exists "investments_write" on public.project_investments;
create policy "investments_write" on public.project_investments
  for all to authenticated
  using (ledger_private.org_has_role(organization_id, array['owner','manager','accountant']::public.org_member_role[]))
  with check (ledger_private.org_has_role(organization_id, array['owner','manager','accountant']::public.org_member_role[]));

-- Government funds.
drop policy if exists "govt_funds_select" on public.government_funds;
create policy "govt_funds_select" on public.government_funds
  for select to authenticated
  using (ledger_private.is_org_member(organization_id));

drop policy if exists "govt_funds_write" on public.government_funds;
create policy "govt_funds_write" on public.government_funds
  for all to authenticated
  using (ledger_private.org_has_role(organization_id, array['owner','manager','accountant']::public.org_member_role[]))
  with check (ledger_private.org_has_role(organization_id, array['owner','manager','accountant']::public.org_member_role[]));

-- Government fund receipts.
drop policy if exists "govt_receipts_select" on public.government_fund_receipts;
create policy "govt_receipts_select" on public.government_fund_receipts
  for select to authenticated
  using (ledger_private.is_org_member(organization_id));

drop policy if exists "govt_receipts_write" on public.government_fund_receipts;
create policy "govt_receipts_write" on public.government_fund_receipts
  for all to authenticated
  using (ledger_private.org_has_role(organization_id, array['owner','manager','accountant']::public.org_member_role[]))
  with check (ledger_private.org_has_role(organization_id, array['owner','manager','accountant']::public.org_member_role[]));

-- Expenses: also writable by site_staff.
drop policy if exists "expenses_select" on public.project_expenses;
create policy "expenses_select" on public.project_expenses
  for select to authenticated
  using (ledger_private.is_org_member(organization_id));

drop policy if exists "expenses_write" on public.project_expenses;
create policy "expenses_write" on public.project_expenses
  for all to authenticated
  using (ledger_private.org_has_role(organization_id, array['owner','manager','accountant','site_staff']::public.org_member_role[]))
  with check (ledger_private.org_has_role(organization_id, array['owner','manager','accountant','site_staff']::public.org_member_role[]));

-- Documents: site_staff can add.
drop policy if exists "documents_select" on public.project_documents;
create policy "documents_select" on public.project_documents
  for select to authenticated
  using (ledger_private.is_org_member(organization_id));

drop policy if exists "documents_write" on public.project_documents;
create policy "documents_write" on public.project_documents
  for all to authenticated
  using (ledger_private.org_has_role(organization_id, array['owner','manager','accountant','site_staff']::public.org_member_role[]))
  with check (ledger_private.org_has_role(organization_id, array['owner','manager','accountant','site_staff']::public.org_member_role[]));

-- Notes: site_staff can add.
drop policy if exists "notes_select" on public.project_notes;
create policy "notes_select" on public.project_notes
  for select to authenticated
  using (ledger_private.is_org_member(organization_id));

drop policy if exists "notes_write" on public.project_notes;
create policy "notes_write" on public.project_notes
  for all to authenticated
  using (ledger_private.org_has_role(organization_id, array['owner','manager','accountant','site_staff']::public.org_member_role[]))
  with check (ledger_private.org_has_role(organization_id, array['owner','manager','accountant','site_staff']::public.org_member_role[]));

-- Progress updates: site_staff can add.
drop policy if exists "progress_select" on public.project_progress_updates;
create policy "progress_select" on public.project_progress_updates
  for select to authenticated
  using (ledger_private.is_org_member(organization_id));

drop policy if exists "progress_write" on public.project_progress_updates;
create policy "progress_write" on public.project_progress_updates
  for all to authenticated
  using (ledger_private.org_has_role(organization_id, array['owner','manager','accountant','site_staff']::public.org_member_role[]))
  with check (ledger_private.org_has_role(organization_id, array['owner','manager','accountant','site_staff']::public.org_member_role[]));

-- Audit logs: owner/manager read only.
drop policy if exists "project_audit_select" on public.project_audit_logs;
create policy "project_audit_select" on public.project_audit_logs
  for select to authenticated
  using (ledger_private.org_has_role(organization_id, array['owner','manager']::public.org_member_role[]));
