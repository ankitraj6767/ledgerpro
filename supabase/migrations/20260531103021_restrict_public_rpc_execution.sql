-- Restrict exposed RPC execution to signed-in users.
--
-- PostgreSQL grants function EXECUTE to PUBLIC by default. Revoking only from
-- anon is not enough because anon also inherits PUBLIC. The mobile app calls
-- these RPCs after Supabase Auth login, so authenticated access remains.
revoke execute on all functions in schema public from public;
revoke execute on all functions in schema public from anon;
grant execute on all functions in schema public to authenticated;

alter default privileges in schema public
  revoke execute on functions from public;

alter default privileges in schema public
  revoke execute on functions from anon;

alter default privileges in schema public
  grant execute on functions to authenticated;
