# macOS Distribution

The macOS build from GitHub must be Developer ID signed and notarized before it
is treated like a normal downloadable app by Gatekeeper. If this is skipped,
users can see a dialog like "Apple could not verify NAVDREAM is free of
malware" after downloading from GitHub.

Public downloads require a Developer ID certificate and Apple notarization to
pass the default Gatekeeper checks. Both macOS workflows check for the required
secrets before allocating a macOS runner or building the app:

- Automatic pushes skip the macOS release with a warning and a job summary when
  credentials are missing. Existing downloads and the update feed are unchanged.
- Manual runs fail early with the missing secret names, unless
  `allow_unsigned_artifact=true` is explicitly selected.
- That opt-in allows an internal test artifact when configuration is incomplete.
  It does not allow publication to GitHub Releases or the update feed, including
  when signing succeeds but notarization credentials are missing.
- With complete configuration, signing, notarization, ticket stapling and
  Gatekeeper verification must all succeed before a public release is published.
  Invalid credentials still fail the workflow; they do not silently downgrade to
  an internal build.

A successful configuration check does not mean an app was released. Check its
summary and the release job status. Adding the Apple secrets below enables
automatic releases on the next matching push without another code change.

## Required Apple Setup

1. Join the Apple Developer Program.
2. Create a `Developer ID Application` certificate for the team.
3. Export the certificate and private key from Keychain Access as a `.p12`.
4. Create an app-specific password for the Apple ID that can notarize apps, or
   create an App Store Connect API key for notarization.

## GitHub Secrets

Set these repository secrets for Developer ID signing:

```text
MACOS_CERTIFICATE_P12_BASE64
MACOS_CERTIFICATE_PASSWORD
```

Optional signing secrets:

```text
MACOS_CODESIGN_IDENTITY
MACOS_KEYCHAIN_PASSWORD
```

`MACOS_CODESIGN_IDENTITY` should look like:

```text
Developer ID Application: Company Name (TEAMID)
```

Set one notarization credential group.

Apple ID method:

```text
APPLE_ID
APPLE_APP_SPECIFIC_PASSWORD
APPLE_TEAM_ID
```

App Store Connect API key method:

```text
APPLE_API_KEY_ID
APPLE_API_ISSUER_ID
APPLE_API_KEY_P8_BASE64
```

Existing keychain profile method:

```text
APPLE_NOTARY_KEYCHAIN_PROFILE
```

This profile method is only for local builds or self-hosted runners where the
profile has already been saved with `xcrun notarytool store-credentials`. On
GitHub-hosted runners, use the Apple ID or API key method.

To create the base64 certificate secret on macOS:

```bash
base64 -i DeveloperIDApplication.p12 | tr -d '\n' | pbcopy
```

Paste the clipboard into `MACOS_CERTIFICATE_P12_BASE64`.

## Release Flow

1. Push to `main` or run `macOS Desktop Release` manually for a universal release
   supporting Apple Silicon and Intel. The workflow checks configuration first.
2. The workflow builds the app and imports the Developer ID certificate into a
   temporary keychain.
3. The workflow signs `NAVDREAM.app` with hardened runtime enabled.
4. The workflow submits the app to Apple notarization, staples the returned
   ticket and verifies it with Gatekeeper.
5. The workflow packages the stapled app and publishes
   `LedgerPro-macOS-v<version>.zip` to the GitHub Release, then updates the macOS
   entry in the shared update feed.

For internal testing without Apple credentials, manually run either macOS
workflow with `allow_unsigned_artifact=true`:

- `macOS Desktop Release` uploads
  `NAVDREAM-macos-universal-internal-<run-id>` to the run's **Artifacts** section.
- `macOS Desktop Build` uploads separate `NAVDREAM-macos-arm64-release` and
  `NAVDREAM-macos-x64-release` artifacts for Apple Silicon and Intel.

Artifacts are retained for five days. Extract the artifact download, then the
included app zip to preserve bundle metadata. Internal artifacts can trigger
Gatekeeper and are not public, notarized releases.

## Configuration Regression Checks

The preflight runs the credential-policy tests on Linux before inspecting real
secrets. Run the same tests locally without Apple credentials or app builds:

```bash
python3 scripts/tests/test_macos_release_config.py
actionlint .github/workflows/macos-desktop-release.yml .github/workflows/macos-desktop-build.yml
shellcheck scripts/check_macos_release_config.sh
```

## Local Validation

After signing and notarization, verify the app before packaging:

```bash
codesign --verify --deep --strict --verbose=2 build/macos/Build/Products/Release/NAVDREAM.app
xcrun stapler validate build/macos/Build/Products/Release/NAVDREAM.app
spctl --assess --type execute --verbose=4 build/macos/Build/Products/Release/NAVDREAM.app
```
