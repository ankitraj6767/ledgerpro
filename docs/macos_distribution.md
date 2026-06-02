# macOS Distribution

The macOS build from GitHub must be Developer ID signed and notarized before it
is treated like a normal downloadable app by Gatekeeper. If this is skipped,
users can see a dialog like "Apple could not verify NAVDREAM is free of
malware" after downloading from GitHub.

Apple requires a Developer ID certificate and notarization for direct
distribution outside the Mac App Store. The workflow therefore fails by default
when signing or notarization credentials are missing. For internal testing only,
run the workflow manually with `allow_unsigned_artifact=true`; that artifact is
not suitable for public downloads.

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

1. Push to `main` or run `macOS Desktop Build` manually.
2. The workflow imports the Developer ID certificate into a temporary keychain.
3. The workflow signs `NAVDREAM.app` with hardened runtime enabled.
4. The workflow submits the app to Apple notarization and staples the returned
   ticket.
5. The workflow packages the stapled app with `ditto` as
   `NAVDREAM-macos-<architecture>-release.zip`.
6. Download the matching artifact:
   - `NAVDREAM-macos-arm64-release` for Apple Silicon Macs.
   - `NAVDREAM-macos-x64-release` for Intel Macs.

## Local Validation

After signing and notarization, verify the app before packaging:

```bash
codesign --verify --deep --strict --verbose=2 build/macos/Build/Products/Release/NAVDREAM.app
xcrun stapler validate build/macos/Build/Products/Release/NAVDREAM.app
spctl --assess --type execute --verbose=4 build/macos/Build/Products/Release/NAVDREAM.app
```
