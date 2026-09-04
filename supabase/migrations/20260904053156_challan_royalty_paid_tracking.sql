-- =============================================================================
-- E-Pass Challan: government royalty payment tracking
-- =============================================================================
-- A saved challan is not proof that royalty has been paid. Keep that
-- operational state separate, auditable, and safely defaulted for old rows.

alter table public.epass_challans
  add column if not exists royalty_paid boolean not null default false,
  add column if not exists royalty_paid_at timestamptz,
  add column if not exists royalty_paid_by uuid references auth.users(id);

create index if not exists epass_challans_royalty_paid_idx
  on public.epass_challans (organization_id, royalty_paid, challan_date desc)
  where deleted_at is null;

-- Only the royalty fields can be changed through this RPC. This prevents the
-- operational checkbox from becoming a backdoor for editing challan details.
create or replace function public.set_epass_challan_royalty_paid(
  p_challan_id uuid,
  p_royalty_paid boolean
)
returns public.epass_challans
language plpgsql
security definer
set search_path = public, ledger_private, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
  v_org_id uuid;
  v_project_id uuid;
  v_row public.epass_challans;
begin
  if v_uid is null then
    raise exception 'Sign in again to update royalty status';
  end if;

  select c.organization_id, c.project_id
    into v_org_id, v_project_id
  from public.epass_challans c
  where c.id = p_challan_id
    and c.deleted_at is null;

  if v_org_id is null then
    raise exception 'Challan not found';
  end if;

  if not ledger_private.org_has_role(
    v_org_id,
    array['owner','manager','accountant','site_staff']::public.org_member_role[]
  ) then
    raise exception 'Not permitted to update royalty status';
  end if;

  update public.epass_challans
  set royalty_paid = p_royalty_paid,
      royalty_paid_at = case when p_royalty_paid then coalesce(royalty_paid_at, now()) else null end,
      royalty_paid_by = case when p_royalty_paid then v_uid else null end,
      updated_by = v_uid,
      updated_at = now()
  where id = p_challan_id
  returning * into v_row;

  insert into public.project_audit_logs (
    organization_id, project_id, actor_id, entity_table, entity_id, action
  ) values (
    v_org_id, v_project_id, v_uid, 'epass_challans', p_challan_id,
    case when p_royalty_paid
      then 'challan_royalty_marked_paid'
      else 'challan_royalty_marked_pending'
    end
  );

  return v_row;
end;
$$;

grant execute on function public.set_epass_challan_royalty_paid(uuid, boolean)
  to authenticated;
revoke execute on function public.set_epass_challan_royalty_paid(uuid, boolean)
  from public, anon;
