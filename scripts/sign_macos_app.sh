#!/usr/bin/env bash
set -euo pipefail

app_name="${APP_NAME:-NAVDREAM}"
release_dir="build/macos/Build/Products/Release"
app_path="${APP_PATH:-${release_dir}/${app_name}.app}"
identity="${MACOS_CODESIGN_IDENTITY:-}"
entitlements="${MACOS_SIGNING_ENTITLEMENTS:-macos/Runner/Release.entitlements}"

if [[ -z "$identity" ]]; then
  echo "MACOS_CODESIGN_IDENTITY is required for Developer ID signing." >&2
  exit 1
fi

if [[ ! -d "$app_path" ]]; then
  found_app="$(find "$release_dir" -maxdepth 1 -name "*.app" -type d | head -n 1 || true)"
  if [[ -z "$found_app" ]]; then
    echo "No macOS .app bundle found under ${release_dir}" >&2
    exit 1
  fi
  app_path="$found_app"
fi

if [[ ! -f "$entitlements" ]]; then
  echo "Signing entitlements file not found: ${entitlements}" >&2
  exit 1
fi

echo "Signing ${app_path} with ${identity}"

sign_without_entitlements() {
  local item="$1"
  codesign --force --timestamp --options runtime --sign "$identity" "$item"
}

if [[ -d "${app_path}/Contents/Frameworks" ]]; then
  while IFS= read -r -d '' executable; do
    sign_without_entitlements "$executable"
  done < <(find "${app_path}/Contents/Frameworks" -type f \( -perm -111 -o -name "*.dylib" -o -name "*.so" \) -print0 | sort -z)

  while IFS= read -r -d '' bundle; do
    sign_without_entitlements "$bundle"
  done < <(find "${app_path}/Contents/Frameworks" -type d \( -name "*.framework" -o -name "*.bundle" -o -name "*.app" -o -name "*.appex" -o -name "*.xpc" \) -print0 | sort -z)
fi

codesign --force \
  --timestamp \
  --options runtime \
  --entitlements "$entitlements" \
  --sign "$identity" \
  "$app_path"

codesign --verify --deep --strict --verbose=2 "$app_path"
echo "Developer ID signing complete."
