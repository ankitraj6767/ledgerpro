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

## Conflict Handling

- Update the same party on two devices.
- Confirm the later sync creates a visible conflict or failed mutation.
- Confirm remote values are never overwritten without explicit resolution.

## Reports

- Generate a party statement PDF offline.
- Share after reconnect.
- Confirm exported balances match ledger timeline.
