# Offline and Online Test Checklist

## Offline Entry

- Launch app with network disabled.
- Add a party locally.
- Add `You gave` and `You got` transactions locally.
- Confirm entries display with `Pending` sync badge.
- Confirm balance updates from local transaction history.

## Reconnect Sync

- Restore network.
- Run sync.
- Confirm businesses/books sync before parties.
- Confirm parties sync before transactions.
- Confirm attachments sync after transaction rows.
- Confirm failed mutations remain retryable and do not overwrite remote rows silently.
- Confirm a mutation remains `failed` if the Supabase write/RPC fails.
- Confirm a mutation becomes `synced` only after the remote write/RPC succeeds.
- Confirm Sync Queue shows pending counts, last synced time, and last error.

## Cross-Device Infra Realtime

- Sign in to the same organization on mobile and desktop.
- Add an expense on mobile and confirm desktop project totals refresh.
- Add an investment on desktop and confirm mobile project totals refresh.
- Soft-delete a project record and confirm the other device removes it after Realtime/refetch.
- Confirm a customer login sees only assigned projects on both devices.

## Conflict Handling

- Update the same party on two devices.
- Confirm the later sync creates a visible conflict or failed mutation.
- Confirm remote values are never overwritten without explicit resolution.

## Reports

- Generate a party statement PDF offline.
- Share after reconnect.
- Confirm exported balances match ledger timeline.
