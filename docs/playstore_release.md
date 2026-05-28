# Play Store Release (APK/AAB)

This project supports proper Android release signing via `android/key.properties`.

## 1) Generate a keystore (one time)

From the repo root:

```bash
keytool -genkeypair -v \
  -keystore ledgerpro-release.keystore \
  -alias ledgerpro \
  -keyalg RSA -keysize 2048 -validity 10000
```

Important:

- Backup `ledgerpro-release.keystore`. If you lose it, you cannot update the app on Play Store.
- Do not commit keystore files to git.

## 2) Create `android/key.properties` (one time)

Create a file at `android/key.properties`:

```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=ledgerpro
storeFile=../ledgerpro-release.keystore
```

This file is gitignored.

## 3) Build signed release APK (for direct install/testing)

```bash
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter build apk --release --dart-define-from-file=supabase/dart_defines.dev.json
```

Output:

`build/app/outputs/flutter-apk/app-release.apk`

## 4) Build signed App Bundle (recommended for Play Store)

```bash
flutter build appbundle --release --dart-define-from-file=supabase/dart_defines.dev.json
```

Output:

`build/app/outputs/bundle/release/app-release.aab`

## 5) Verify the APK is release-signed

```bash
jarsigner -verify -verbose -certs build/app/outputs/flutter-apk/app-release.apk | head -n 30
```
