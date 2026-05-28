create or replace function public.create_ledger_transaction(
  p_business_id uuid,
  p_book_id uuid,
  p_party_id uuid,
  p_type public.ledger_transaction_type,
  p_amount_paise bigint,
  p_payment_mode public.payment_mode default 'cash',
  p_note text default null,
  p_due_date date default null,
  p_balance_delta_paise bigint default 0,
  p_actor_id uuid default auth.uid()
)
returns uuid
language plpgsql
security invoker
set search_path = public, ledger_private, pg_temp
as $$
declare
  transaction_id uuid;
begin
  if auth.uid() is null then
    raise exception 'Authentication required';
  end if;

  if p_actor_id is distinct from auth.uid() then
    raise exception 'Actor mismatch';
  end if;

  if p_amount_paise <= 0 then
    raise exception 'Amount must be greater than zero';
  end if;

  if not ledger_private.has_permission(p_business_id, 'add_transaction') then
    raise exception 'Missing add_transaction permission';
  end if;

  if not exists (
    select 1
    from public.parties
    where id = p_party_id
      and business_id = p_business_id
      and book_id = p_book_id
      and deleted_at is null
  ) then
    raise exception 'Party not found for active book';
  end if;

  insert into public.transactions (
    business_id,
    book_id,
    party_id,
    type,
    amount_paise,
    payment_mode,
    note,
    due_date,
    sync_status,
    created_by,
    updated_by
  )
  values (
    p_business_id,
    p_book_id,
    p_party_id,
    p_type,
    p_amount_paise,
    p_payment_mode,
    nullif(trim(p_note), ''),
    p_due_date,
    'synced',
    auth.uid(),
    auth.uid()
  )
  returning id into transaction_id;

  update public.parties
  set cached_balance_paise = cached_balance_paise + p_balance_delta_paise,
      updated_by = auth.uid(),
      updated_at = now()
  where id = p_party_id
    and business_id = p_business_id
    and book_id = p_book_id;

  return transaction_id;
end;
$$;

revoke execute on function public.create_ledger_transaction(
  uuid,
  uuid,
  uuid,
  public.ledger_transaction_type,
  bigint,
  public.payment_mode,
  text,
  date,
  bigint,
  uuid
) from anon;

grant execute on function public.create_ledger_transaction(
  uuid,
  uuid,
  uuid,
  public.ledger_transaction_type,
  bigint,
  public.payment_mode,
  text,
  date,
  bigint,
  uuid
) to authenticated;
