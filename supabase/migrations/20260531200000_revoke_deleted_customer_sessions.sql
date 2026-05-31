-- Revoke a deleted customer's active Supabase Auth refresh sessions.
-- Access JWTs remain valid until expiry, so RLS still checks active membership.

create or replace function public.revoke_auth_sessions_for_user(p_user_id uuid)
returns void
language plpgsql
security definer
set search_path = public, auth, pg_temp
as $$
begin
  delete from auth.refresh_tokens
  where session_id in (
    select id
    from auth.sessions
    where user_id = p_user_id
  );

  delete from auth.sessions
  where user_id = p_user_id;
end;
$$;

revoke all on function public.revoke_auth_sessions_for_user(uuid) from anon;
revoke all on function public.revoke_auth_sessions_for_user(uuid) from authenticated;
grant execute on function public.revoke_auth_sessions_for_user(uuid) to service_role;

update auth.users u
set banned_until = 'infinity',
    updated_at = now()
where exists (
  select 1
  from public.organization_members m
  where m.user_id = u.id
    and m.role::text = 'customer'
    and m.deleted_at is not null
)
and not exists (
  select 1
  from public.organization_members active_m
  where active_m.user_id = u.id
    and active_m.deleted_at is null
);

do $$
declare
  v_user_id uuid;
begin
  for v_user_id in
    select distinct m.user_id
    from public.organization_members m
    where m.role::text = 'customer'
      and m.deleted_at is not null
      and not exists (
        select 1
        from public.organization_members active_m
        where active_m.user_id = m.user_id
          and active_m.deleted_at is null
      )
  loop
    perform public.revoke_auth_sessions_for_user(v_user_id);
  end loop;
end $$;
