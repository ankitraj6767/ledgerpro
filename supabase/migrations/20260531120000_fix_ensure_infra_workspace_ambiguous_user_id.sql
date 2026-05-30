-- Fix: "column reference \"user_id\" is ambiguous" in ensure_infra_workspace.
--
-- Root cause: the function declared a PL/pgSQL variable named `user_id`, then
-- ran `insert into organization_members (...) on conflict (organization_id,
-- user_id) ...`. In the ON CONFLICT inference clause `user_id` is ambiguous
-- between the table column and the variable, so the function aborted and rolled
-- back — no organization was ever created, which cascaded to every screen.
--
-- Fix: rename the variable to `v_uid` so it can never collide with a column.

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
  v_uid uuid := auth.uid();
  found_org_id uuid;
  found_org_name text;
  owner_name text;
begin
  if v_uid is null then
    raise exception 'Authentication required';
  end if;

  owner_name := coalesce(
    nullif(trim(p_full_name), ''),
    nullif(split_part(coalesce(p_email, ''), '@', 1), ''),
    'Royal Infra Owner'
  );

  insert into public.profiles (id, full_name, default_language)
  values (v_uid, owner_name, 'en')
  on conflict (id) do update
    set full_name = coalesce(public.profiles.full_name, excluded.full_name),
        updated_at = now(),
        deleted_at = null;

  select o.id, o.name
    into found_org_id, found_org_name
  from public.organizations o
  join public.organization_members m
    on m.organization_id = o.id and m.user_id = v_uid and m.deleted_at is null
  where o.deleted_at is null
  order by o.created_at
  limit 1;

  if found_org_id is null then
    insert into public.organizations (owner_id, name, owner_name, created_by, updated_by)
    values (
      v_uid,
      coalesce(nullif(trim(p_org_name), ''), 'My Organization'),
      owner_name,
      v_uid,
      v_uid
    )
    returning organizations.id, organizations.name
      into found_org_id, found_org_name;

    insert into public.organization_members (organization_id, user_id, role, created_by, updated_by)
    values (found_org_id, v_uid, 'owner', v_uid, v_uid)
    on conflict (organization_id, user_id) do nothing;
  end if;

  return query select found_org_id, found_org_name;
end;
$$;

revoke execute on function public.ensure_infra_workspace(text, text, text) from anon;
grant execute on function public.ensure_infra_workspace(text, text, text) to authenticated;
