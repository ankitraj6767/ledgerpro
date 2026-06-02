#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root_dir"

flutter config --enable-macos-desktop
flutter pub get
flutter analyze lib test
flutter test
flutter build macos --release

if [[ -n "${MACOS_CODESIGN_IDENTITY:-}" ]]; then
  ./scripts/sign_macos_app.sh

  if [[ -n "${APPLE_NOTARY_KEYCHAIN_PROFILE:-}" \
    || ( -n "${APPLE_API_KEY_ID:-}" && -n "${APPLE_API_ISSUER_ID:-}" && -n "${APPLE_API_KEY_P8_BASE64:-}" ) \
    || ( -n "${APPLE_ID:-}" && -n "${APPLE_APP_SPECIFIC_PASSWORD:-}" && -n "${APPLE_TEAM_ID:-}" ) ]]; then
    ./scripts/notarize_macos_app.sh
  elif [[ "${REQUIRE_MACOS_NOTARIZATION:-false}" == "true" ]]; then
    echo "REQUIRE_MACOS_NOTARIZATION=true but Apple notarization credentials are missing." >&2
    exit 1
  else
    echo "Skipping notarization because Apple notarization credentials are not configured."
  fi
elif [[ "${REQUIRE_MACOS_NOTARIZATION:-false}" == "true" ]]; then
  echo "REQUIRE_MACOS_NOTARIZATION=true but MACOS_CODESIGN_IDENTITY is missing." >&2
  exit 1
else
  echo "Skipping Developer ID signing. The packaged app will trigger macOS Gatekeeper after download."
fi

./scripts/package_macos_release.sh
