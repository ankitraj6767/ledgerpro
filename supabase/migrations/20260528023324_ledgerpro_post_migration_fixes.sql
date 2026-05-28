-- Post-migration fixes based on Supabase advisors (security + performance).

-- 1) Security: make helper triggers deterministic w.r.t. search_path.
create or replace function ledger_private.set_updated_at()
returns trigger
language plpgsql
set search_path = public, pg_temp
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create or replace function ledger_private.set_party_search_vector()
returns trigger
language plpgsql
set search_path = public, pg_temp
as $$
begin
  new.search_vector :=
    to_tsvector(
      'simple',
      coalesce(new.name, '') || ' ' ||
      coalesce(new.phone, '') || ' ' ||
      coalesce(new.alternate_phone, '') || ' ' ||
      coalesce(new.notes, '') || ' ' ||
      array_to_string(coalesce(new.tags, '{}'), ' ')
    );
  return new;
end;
$$;

create or replace function ledger_private.prevent_hard_delete()
returns trigger
language plpgsql
set search_path = public, pg_temp
as $$
begin
  raise exception 'Hard delete is disabled for %. Use deleted_at, archive, or reversal entries.', tg_table_name;
end;
$$;

-- 2) Security: revoke execution of an unexpected SECURITY DEFINER rpc in public schema.
do $$
begin
  if exists (
    select 1
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public'
      and p.proname = 'rls_auto_enable'
  ) then
    revoke all on function public.rls_auto_enable() from anon;
    revoke all on function public.rls_auto_enable() from authenticated;
  end if;
end $$;

-- 3) Performance: add covering indexes for common foreign keys flagged by advisors.
create index if not exists app_settings_book_id_idx on public.app_settings(book_id) where deleted_at is null;
create index if not exists app_settings_created_by_idx on public.app_settings(created_by) where deleted_at is null;
create index if not exists app_settings_updated_by_idx on public.app_settings(updated_by) where deleted_at is null;

create index if not exists audit_logs_book_id_idx on public.audit_logs(book_id);
create index if not exists audit_logs_actor_id_idx on public.audit_logs(actor_id);
