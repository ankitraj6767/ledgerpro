# Final Quality Checklist

- No Khatabook branding, logo, UI, screenshots, text, icons, color system, or proprietary flows are used.
- Money is represented in paise as integers in app logic and Postgres schema.
- Balance calculation is reproducible from transaction history.
- Transaction reversal behavior is unit-tested.
- Financial records use soft delete/reversal guardrails; no mobile delete policy is granted.
- Offline-first tables exist locally for businesses, books, parties, transactions, reminders, audit logs, and pending mutations.
- Sync order is encoded and unit-tested: businesses, books, parties, transactions, attachments, reminders, reports.
- WhatsApp reminders open with prefilled text through `url_launcher`.
- SMS sending is not faked; the UI says provider is not connected.
- UPI links/QR are static or amount-based and never fake payment success.
- PDF statement generation is implemented through the `pdf` package and shared through `share_plus`.
- App lock supports secure PIN hashing and biometric unlock hooks.
- Supabase migration enables RLS on every app table.
- No service-role key or secret key is present in Flutter code.
- Staff permissions are represented in RLS helper functions and role policies.
- Audit logs are created by database triggers for business-owned changes.
- Android debug build succeeds.

## Remaining Environment Checks

- Apply the Supabase migration against a real project or local Docker Supabase.
- Configure phone OTP/SMS provider in Supabase Auth.
- Add Firebase Android configuration files before enabling production FCM.
- Run manual device QA on a low-end Android phone with airplane-mode entry and later sync.
