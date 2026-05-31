# LedgerPro Mobile

Private internal-use mobile ledger application for Android-first business bookkeeping.

LedgerPro Mobile is an original fintech ledger app inspired by digital bahi khata workflows. It does not use Khatabook branding, layouts, copy, screenshots, icons, colors, or proprietary flows.

## Stack

- Flutter 3.44.0 / Dart 3.12
- Riverpod, GoRouter, Freezed, json_serializable
- Supabase Auth, Postgres, Storage, Realtime-ready migration
- Drift local database for offline-first ledger data
- Secure storage, PIN lock, biometrics
- PDF generation, sharing, WhatsApp/phone/UPI links
- Mobile scanner and Firebase Cloud Messaging integration hooks

## Run

```bash
flutter pub get
dart run build_runner build
flutter run --dart-define-from-file=supabase/dart_defines.dev.json
```

The app also includes the LedgerPro Supabase publishable config as a safe fallback,
so release APKs remain connected if the dart-define file is accidentally omitted.

### Supabase Dart Defines

This project reads Supabase config from Dart defines:

- `SUPABASE_URL`
- `SUPABASE_PUBLISHABLE_KEY`

A local (gitignored) file is provided at `supabase/dart_defines.dev.json`. If missing, use
`supabase/dart_defines.dev.json.example` as a template. The publishable key is safe to ship in
the client; never place service-role keys or payment secrets in Flutter.

## Supabase

The core schema migration is:

```text
supabase/migrations/20260527084243_ledgerpro_core_schema.sql
```

It creates UUID tables, business/book scoping, paise-based money columns, RLS policies, explicit authenticated grants, audit triggers, soft-delete guardrails for financial records, a private storage bucket, and realtime publication entries.

Do not place service-role keys or payment gateway secrets in the Flutter app. Future payment gateway webhooks should be implemented with Supabase Edge Functions.

### Navdream Infra Customer Logins

Customer logins are admin-managed. Owners/managers create customers from
`Profile > Customers`, which calls the `create-customer-user` Edge Function.
The Flutter app only uses the publishable key; the function uses the Supabase
service-role key server-side to create Auth users and insert a
`organization_members.role = customer` membership.

Deploy the function after applying migrations:

```bash
supabase functions deploy create-customer-user
```

Required function secrets:

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `SUPABASE_SERVICE_ROLE_KEY`

Customers can view organization/project finance data and add or edit their own
project expenses. They cannot manage projects, investments, government funds,
receipts, settings, users, audit logs, or delete expenses. Supabase RLS/RPCs are
the final permission boundary; UI gating only mirrors those database rules.

## Verification

```bash
flutter analyze
flutter test
cd android && ./gradlew assembleDebug --no-daemon
```

Local Supabase migration execution requires Docker/Supabase local services. Docker was not available in this environment, so the migration was generated but not applied locally.
