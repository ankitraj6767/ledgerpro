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

## Download Windows App

LedgerPro ships a ready-to-run Windows x64 desktop build. No Flutter tooling is
required to use these downloads, just extract and run. The launcher executable
is `navdream.exe`.

### Option A: Latest GitHub Release (recommended)

1. Open the repository's **Releases** page on GitHub.
2. Download `LedgerPro-Windows-x64-v<version>.zip` from the latest release
   (for example `LedgerPro-Windows-x64-v1.0.1.zip`).
3. (Optional) Also download `LedgerPro-Windows-x64-v<version>.zip.sha256` to
   verify the download (see "Verify the checksum" below).
4. Right-click the ZIP and choose **Extract All** to unzip it.
5. Open the extracted `LedgerPro-Windows-x64-v<version>` folder and double-click
   `navdream.exe` to launch the app.

Releases are published by maintainers through the **Windows Desktop Release**
GitHub Actions workflow.

### Option B: GitHub Actions artifact (latest build)

1. Open the **Actions** tab and select a successful **Windows Desktop Build** run.
2. Under **Artifacts**, download `LedgerPro-Windows-x64-v<version>`.
3. GitHub wraps every artifact in its own ZIP, so extract the downloaded file
   first. Inside you will find `LedgerPro-Windows-x64-v<version>.zip` and its
   `.sha256` checksum.
4. Extract `LedgerPro-Windows-x64-v<version>.zip`, then run `navdream.exe` from
   the extracted folder.

### Option C: Build locally on Windows

Requires a Windows host with Flutter 3.44.0 (stable) installed.

```powershell
git clone <repository-url>
cd ledgerpro
.\scripts\build_windows_release.ps1
```

The script analyzes, tests, and builds the app, then writes the distributable
package to:

- `dist\windows\LedgerPro-Windows-x64-v<version>.zip`
- `dist\windows\LedgerPro-Windows-x64-v<version>.zip.sha256`

The raw build output used to create the ZIP is at
`build\windows\x64\runner\Release\`.

### Where is the app after extracting?

After extracting `LedgerPro-Windows-x64-v<version>.zip`, the launcher is:

```text
LedgerPro-Windows-x64-v<version>\navdream.exe
```

Keep `navdream.exe` together with the `data\` folder and the `.dll` files in the
same directory; they are all required for the app to start.

### Verify the checksum (optional)

In PowerShell, from the folder containing the ZIP:

```powershell
(Get-FileHash .\LedgerPro-Windows-x64-v<version>.zip -Algorithm SHA256).Hash
```

Compare the printed value with the hash inside the `.sha256` file. On macOS or
Linux you can instead run
`shasum -a 256 -c LedgerPro-Windows-x64-v<version>.zip.sha256`.

### Backend (Supabase) access in downloads

Downloaded builds connect to Supabase out of the box. The app reads
`SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY` from Dart defines and falls back to
the publishable config baked into `lib/app/constants/supabase_config.dart` when
they are not provided, so a downloaded `.exe` is backend-connected with no extra
setup. Only the public publishable (anon) key is shipped; Supabase RLS is the
real authorization boundary.

To point released builds at a specific Supabase project without editing code,
set repository variables (these are non-sensitive) under
**Settings > Secrets and variables > Actions > Variables**:

- `SUPABASE_URL`
- `SUPABASE_PUBLISHABLE_KEY`

The `Windows Desktop Build` and `Windows Desktop Release` workflows inject these
via `--dart-define` at build time. If they are unset, the baked-in fallback is
used. Never place service-role keys or payment secrets in the Flutter app or in
repository variables; those stay server-side in Supabase Edge Functions.

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

The release app is written to `build/windows/x64/runner/Release`. The
`scripts/build_windows_release.ps1` script then packages that folder into a
clean, versioned `dist/windows/LedgerPro-Windows-x64-v<version>.zip` with a
matching `.sha256` checksum. GitHub Actions can also build the same artifact
through the `Windows Desktop Build` workflow (uploaded as the
`LedgerPro-Windows-x64-v<version>` artifact), and the `Windows Desktop Release`
workflow publishes the ZIP and checksum to GitHub Releases. See the
[Download Windows App](#download-windows-app) section for download instructions.

macOS desktop builds must run on a macOS host. From Terminal on macOS:

```bash
./scripts/build_macos_release.sh
```

The release app bundle is written to
`build/macos/Build/Products/Release/NAVDREAM.app` and packaged for download at
`dist/macos/<architecture>/NAVDREAM-macos-<architecture>-release.zip` with a
matching `.sha256` checksum. GitHub Actions can also build downloadable Intel
and Apple Silicon artifacts through the `macOS Desktop Build` workflow and
uploads them as `NAVDREAM-macos-x64-release` and `NAVDREAM-macos-arm64-release`.
Download the matching artifact, extract the GitHub artifact zip, then extract
the included `.zip` to preserve the macOS app bundle metadata. Public macOS
downloads must be Developer ID signed and notarized by Apple to open normally
after download; see `docs/macos_distribution.md` for the required GitHub
Actions secrets.

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
