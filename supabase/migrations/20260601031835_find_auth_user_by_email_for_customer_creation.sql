-- Customer creation needs a targeted Auth lookup from the Edge Function.
-- Supabase does not expose the auth schema through the normal Data API, and
-- Auth Admin listUsers can fail project-wide if any auth row is problematic.
-- Keep this narrowly scoped and callable only with the service role.

create or replace function public.find_auth_user_by_email(p_email text)
returns table (
  id uuid,
  email text
)
language sql
stable
security definer
set search_path = auth, public, pg_temp
as $$
  select u.id, u.email::text
  from auth.users u
  where lower(u.email::text) = lower(trim(p_email))
  order by u.created_at desc
  limit 1;
$$;

revoke execute on function public.find_auth_user_by_email(text) from public;
revoke execute on function public.find_auth_user_by_email(text) from anon;
revoke execute on function public.find_auth_user_by_email(text) from authenticated;
grant execute on function public.find_auth_user_by_email(text) to service_role;
