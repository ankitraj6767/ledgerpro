-- One-time cleanup: archive any active transaction whose party has been
-- soft-deleted (or no longer exists). These previously rendered as
-- "Unknown party" on the dashboard. Going forward, deleting a party also
-- archives its transactions in the same operation (see app repository).
update public.transactions t
set deleted_at = now(),
    updated_at = now()
from public.parties p
where t.party_id = p.id
  and t.deleted_at is null
  and p.deleted_at is not null;

-- Also archive transactions whose party row is entirely missing (defensive).
update public.transactions t
set deleted_at = now(),
    updated_at = now()
where t.deleted_at is null
  and not exists (
    select 1 from public.parties p where p.id = t.party_id
  );
