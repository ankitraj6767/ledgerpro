#!/usr/bin/env bash
set -euo pipefail

app_name="${APP_NAME:-NAVDREAM}"
release_dir="build/macos/Build/Products/Release"
app_path="${APP_PATH:-${release_dir}/${app_name}.app}"

if [[ ! -d "$app_path" ]]; then
  found_app="$(find "$release_dir" -maxdepth 1 -name "*.app" -type d | head -n 1 || true)"
  if [[ -z "$found_app" ]]; then
    echo "No macOS .app bundle found under ${release_dir}" >&2
    exit 1
  fi
  app_path="$found_app"
fi

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

notary_zip="${tmp_dir}/${app_name}-notary.zip"
api_key_path="${tmp_dir}/notary-api-key.p8"

ditto -c -k --keepParent "$app_path" "$notary_zip"

notary_args=()
if [[ -n "${APPLE_NOTARY_KEYCHAIN_PROFILE:-}" ]]; then
  notary_args=(--keychain-profile "$APPLE_NOTARY_KEYCHAIN_PROFILE")
elif [[ -n "${APPLE_API_KEY_ID:-}" && -n "${APPLE_API_ISSUER_ID:-}" && -n "${APPLE_API_KEY_P8_BASE64:-}" ]]; then
  printf '%s' "$APPLE_API_KEY_P8_BASE64" | base64 --decode > "$api_key_path" 2>/dev/null \
    || printf '%s' "$APPLE_API_KEY_P8_BASE64" | base64 -D > "$api_key_path"
  notary_args=(--key "$api_key_path" --key-id "$APPLE_API_KEY_ID" --issuer "$APPLE_API_ISSUER_ID")
elif [[ -n "${APPLE_ID:-}" && -n "${APPLE_APP_SPECIFIC_PASSWORD:-}" && -n "${APPLE_TEAM_ID:-}" ]]; then
  notary_args=(--apple-id "$APPLE_ID" --password "$APPLE_APP_SPECIFIC_PASSWORD" --team-id "$APPLE_TEAM_ID")
else
  echo "Apple notarization credentials are required." >&2
  exit 1
fi

echo "Submitting ${app_path} to Apple notarization."
xcrun notarytool submit "$notary_zip" "${notary_args[@]}" --wait

echo "Stapling notarization ticket."
xcrun stapler staple "$app_path"
xcrun stapler validate "$app_path"
spctl --assess --type execute --verbose=4 "$app_path"

echo "Notarization complete."
