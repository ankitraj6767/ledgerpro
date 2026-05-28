# LedgerPro Mobile RLS Test Plan

Use the Supabase Dashboard RLS tester or local SQL sessions with `request.jwt.claims`.

## Owner

- Can create own `profiles` row where `profiles.id = auth.uid()`.
- Can create a `businesses` row where `owner_id = auth.uid()`.
- Automatically receives an `owner` row in `business_members`.
- Can read and update own business, books, parties, transactions, invoices, inventory, settings, exports, and audit logs.

## Staff

- Can read only assigned business data through `business_members`.
- Can add transactions when role/permissions allow `add_transaction`.
- Cannot update transactions without `edit_transaction`.
- Cannot manage staff unless role/permissions allow `manage_staff`.
- Cannot read audit logs unless allowed to manage settings.

## Isolation

- User A cannot read, insert, or update rows for User B's business.
- A staff member removed with `deleted_at` immediately loses table access after JWT refresh.
- Direct deletes against financial tables must fail; use `deleted_at` or reversal entries.

## Storage

- `ledger-attachments` objects must live under `{business_id}/...`.
- Only business members can select, insert, or update files under that business folder.
- No public bucket access is allowed.

## Payments

- Mobile clients can create pending/manual payment rows only through RLS.
- Gateway-confirmed payment changes must be performed by future Edge Functions with secrets server-side.
