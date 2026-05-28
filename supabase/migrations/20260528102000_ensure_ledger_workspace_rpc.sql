create or replace function public.ensure_ledger_workspace(
  p_email text default null,
  p_full_name text default null
)
returns table (
  business_id uuid,
  book_id uuid,
  business_name text
)
language plpgsql
security definer
set search_path = public, ledger_private, pg_temp
as $$
declare
  user_id uuid := auth.uid();
  found_business_id uuid;
  found_book_id uuid;
  found_business_name text;
  owner_name text;
begin
  if user_id is null then
    raise exception 'Authentication required';
  end if;

  owner_name := coalesce(
    nullif(trim(p_full_name), ''),
    nullif(split_part(coalesce(p_email, ''), '@', 1), ''),
    'LedgerPro Owner'
  );

  insert into public.profiles (
    id,
    full_name,
    default_language
  )
  values (
    user_id,
    owner_name,
    'en'
  )
  on conflict (id) do update
    set full_name = coalesce(public.profiles.full_name, excluded.full_name),
        updated_at = now(),
        deleted_at = null;

  select b.id, b.business_name
    into found_business_id, found_business_name
  from public.businesses b
  where b.owner_id = user_id
    and b.deleted_at is null
  order by b.created_at
  limit 1;

  if found_business_id is null then
    insert into public.businesses (
      owner_id,
      business_name,
      owner_name,
      phone,
      default_language,
      default_currency,
      business_category,
      created_by,
      updated_by
    )
    values (
      user_id,
      'LedgerPro Business',
      owner_name,
      '+910000000000',
      'en',
      'INR',
      'General store',
      user_id,
      user_id
    )
    returning id, business_name into found_business_id, found_business_name;
  end if;

  select b.id
    into found_book_id
  from public.books b
  where b.business_id = found_business_id
    and b.deleted_at is null
  order by b.is_default desc, b.created_at
  limit 1;

  if found_book_id is null then
    insert into public.books (
      business_id,
      name,
      is_default,
      created_by,
      updated_by
    )
    values (
      found_business_id,
      'Main book',
      true,
      user_id,
      user_id
    )
    returning id into found_book_id;
  end if;

  return query
  select found_business_id, found_book_id, found_business_name;
end;
$$;

revoke execute on function public.ensure_ledger_workspace(text, text) from public;
revoke execute on function public.ensure_ledger_workspace(text, text) from anon;
grant execute on function public.ensure_ledger_workspace(text, text) to authenticated;
