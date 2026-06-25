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

## Royal Infra Customers

- Owner or manager can create a Supabase Auth customer through the `create-customer-user` Edge Function.
- Customer has an `organization_members.role = customer` row for the active organization.
- Customer can call `get_my_infra_workspace()` and receives the existing organization and `customer` role.
- Customer can select organization, projects, reports, investments, government funds, receipts, and expenses.
- Customer can insert a project expense through `add_project_expense`.
- Customer can update only a project expense where `project_expenses.created_by = auth.uid()`.
- Customer cannot delete expenses through RLS or `delete_project_expense`.
- Customer cannot create, update, or delete projects.
- Customer cannot call `add_project_investment`, `add_government_fund`, `add_government_fund_receipt`, or `update_project_progress`.
- Customer cannot update organization settings, manage organization members, or read project audit logs.
- A signed-in auth user with no organization membership must fail `get_my_infra_workspace()` and must not auto-create an owner workspace.
