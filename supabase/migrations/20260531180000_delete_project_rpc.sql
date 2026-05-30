-- Royal Infra — delete_project: soft-delete a project and cascade the
-- soft-delete to all its child financial records (investments, government
-- funds + receipts, expenses, notes, documents, progress updates) atomically.
-- Hard deletes are blocked by triggers, so everything uses deleted_at.
-- Only owner/manager may delete a project.

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

grant execute on function public.delete_project(uuid) to authenticated;
