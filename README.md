# LedgerPro

Private internal-use ledger and infrastructure finance application for mobile,
tablet, and desktop.

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

## Desktop

LedgerPro now uses the same Flutter codebase across Android, iOS, macOS,
Windows, and Linux. Mobile keeps bottom navigation, tablet uses a navigation
rail, and desktop uses a permanent sidebar with a command bar, search, quick
actions, realtime refresh, and sync status.

Run desktop targets:

```bash
flutter run -d macos --dart-define-from-file=supabase/dart_defines.dev.json
flutter run -d windows --dart-define-from-file=supabase/dart_defines.dev.json
flutter run -d linux --dart-define-from-file=supabase/dart_defines.dev.json
```

Build release desktop targets:

```bash
flutter build macos --release --dart-define-from-file=supabase/dart_defines.dev.json
flutter build windows --release --dart-define-from-file=supabase/dart_defines.dev.json
flutter build linux --release --dart-define-from-file=supabase/dart_defines.dev.json
```

Windows desktop builds must run on a Windows host. From PowerShell on Windows:

```powershell
.\scripts\build_windows_release.ps1
```

Or double-click/run the batch wrapper:

```bat
scripts\build_windows_release.bat
```

The release app is written to `build/windows/x64/runner/Release`. GitHub
Actions can also build the same artifact through the `Windows Desktop Build`
workflow and uploads it as `NAVDREAM-windows-release`.

macOS desktop builds must run on a macOS host. From Terminal on macOS:

```bash
./scripts/build_macos_release.sh
```

The release app bundle is written to
`build/macos/Build/Products/Release/NAVDREAM.app` and packaged for download at
`dist/macos/<architecture>/NAVDREAM-macos-<architecture>-release.tar.gz` with a
matching `.sha256` checksum. GitHub Actions can also build downloadable Intel
and Apple Silicon artifacts through the `macOS Desktop Build` workflow and
uploads them as `NAVDREAM-macos-x64-release` and `NAVDREAM-macos-arm64-release`.
Download the matching artifact, extract the GitHub artifact zip, then extract
the included `.tar.gz` to preserve the macOS app bundle permissions. These are
unsigned direct-download builds, so macOS Gatekeeper may require right-clicking
the app and choosing Open.

Desktop platform folders are generated under `macos/`, `windows/`, and
`linux/`. Platform-specific capabilities are guarded in Flutter: biometric
unlock is disabled on unsupported platforms, FCM is skipped where unavailable,
and scanner-dependent flows should use a manual-entry fallback on desktop.
Desktop PDF exports are written to `Downloads/NAVDREAM Reports` and then
revealed in the platform file manager.

## Supabase

The core schema migration is:

```text
supabase/migrations/20260527084243_ledgerpro_core_schema.sql
```

It creates UUID tables, business/book scoping, paise-based money columns, RLS policies, explicit authenticated grants, audit triggers, soft-delete guardrails for financial records, a private storage bucket, and realtime publication entries.

Infra finance migrations add organization/project finance tables, customer
project assignment RLS, atomic RPCs for totals, Supabase Realtime publication
entries, and `infra_sync_mutations` metadata for device mutation replay
tracking. See `docs/sync_architecture.md`.

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

Desktop smoke checks:

```bash
flutter build macos --debug
flutter test test/core/sync/offline_sync_service_test.dart
```

Local Supabase migration execution requires Docker/Supabase local services. Docker was not available in this environment, so the migration was generated but not applied locally.
