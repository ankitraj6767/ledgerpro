# LedgerPro Sync Architecture

## Current Architecture Summary

LedgerPro uses Supabase as the source of truth for Auth, Postgres, RLS, RPCs,
Storage, Edge Functions, and Realtime. Flutter uses Riverpod providers and
repositories for online data access, with Drift reserved for local cache and
offline mutation queues.

The infra module is reusable for cross-platform work because financial writes
already go through server-side RPCs for projects, investments, government
funds, receipts, expenses, progress, and delete flows. These RPCs keep totals in
paise and enforce RLS-backed permissions.

The older Drift schema is mobile-ledger focused: businesses, books, parties,
transactions, reminders, audit logs, and pending mutations. It does not yet
mirror every infra table locally, so full offline infra editing still requires
the next local-cache phase.

## P0/P1/P2 Audit

P0: queued mutations were previously marked `synced` without a Supabase write.
This is now fixed in `OfflineSyncService`: each mutation moves to `inFlight`,
calls a remote writer, and only then becomes `synced`. Failures remain retryable
with exponential backoff.

P0: infra Realtime was not subscribed from Flutter. `infraRealtimeBridgeProvider`
now subscribes to the important organization and project tables and invalidates
Riverpod providers so desktop and mobile views refresh after inserts, updates,
soft deletes, and reconnect fetches.

P1: local Drift cache is incomplete for infra tables. The current app can show
queue/error status and safely retry queued writes, but true offline-first infra
screens still need Drift tables for projects, investors, funds, expenses, notes,
documents, progress, and assignments.

P1: server-side replay metadata was missing for infra sync. The
`infra_sync_mutations` migration adds per-device mutation tracking with RLS and
Realtime publication.

P2: desktop UX was mobile-stretched. The app now has adaptive navigation and
desktop project/dashboard layouts, but reports and settings can still be made
denser in later passes.

## Offline Sync Flow

1. UI performs an optimistic local write and inserts a `local_pending_mutations`
   row with `entity_type`, `entity_id`, `action`, and JSON payload.
2. `OfflineSyncService.syncPending()` loads pending/failed mutations in
   dependency order.
3. Failed mutations wait for exponential backoff before retry.
4. The service marks the row `inFlight`.
5. `SupabaseLedgerApi.applyQueuedMutation()` applies a whitelisted table upsert,
   archive, or RPC call.
6. Optional payload fields `organization_id`, `device_id`, and `payload_hash`
   record replay state in `infra_sync_mutations`.
7. Success marks the local mutation `synced`; errors mark it `failed`.
8. `SyncQueueScreen` exposes per-entity pending, failed, last synced, and error
   state.

## Realtime Flow

`infraRealtimeBridgeProvider` subscribes to:

- organizations
- organization_members
- infra_projects
- investors
- project_investments
- government_funds
- government_fund_receipts
- project_expenses
- project_notes
- project_progress_updates
- project_documents
- customer_project_assignments
- project_audit_logs

On change, the provider invalidates dashboard, projects, project detail
families, customers, investors, and audit providers. This keeps UI reactive
across mobile and desktop while preserving Supabase RLS as the final boundary.

## Known Limitations

- Infra local cache tables are not complete yet, so offline-created infra
  entries need a follow-up Drift migration and repository adapter.
- Conflict resolution currently fails the mutation with a visible error when
  `expected_updated_at` does not match the server; a guided merge UI is still
  needed.
- CSV expense import is not wired to a desktop file picker yet.
- Supabase migrations should be applied and verified against a real project or
  local Supabase before release.

## Release Checklist

- Apply all migrations through `20260601160000_infra_realtime_and_sync_idempotency.sql`.
- Deploy `create-customer-user` Edge Function with service-role secret only in
  Supabase.
- Run `flutter analyze` and `flutter test`.
- Build Android, iOS, macOS, Windows, and Linux release artifacts.
- Verify Realtime by adding an expense on one signed-in device and watching the
  dashboard/project totals refresh on another.
- Verify offline retry by queuing a mutation, reconnecting, and confirming it is
  marked `synced` only after the RPC/table write succeeds.
