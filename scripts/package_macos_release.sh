#!/usr/bin/env bash
set -euo pipefail

app_name="${APP_NAME:-NAVDREAM}"
architecture="${1:-${MACOS_ARCHITECTURE:-}}"

if [[ -z "$architecture" ]]; then
  case "$(uname -m)" in
    arm64) architecture="arm64" ;;
    x86_64) architecture="x64" ;;
    *) architecture="$(uname -m)" ;;
  esac
fi

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

dist_dir="dist/macos/${architecture}"
archive_name="${app_name}-macos-${architecture}-release.zip"
archive_path="${dist_dir}/${archive_name}"
checksum_path="${archive_path}.sha256"

rm -rf "$dist_dir"
mkdir -p "$dist_dir"

if xcrun stapler validate "$app_path" >/dev/null 2>&1; then
  echo "Stapled notarization ticket found on ${app_path}."
else
  echo "No stapled notarization ticket found on ${app_path}."
fi

ditto -c -k --sequesterRsrc --keepParent "$app_path" "$archive_path"
shasum -a 256 "$archive_path" | tee "$checksum_path"

echo "NAVDREAM macOS artifact ready at: ${archive_path}"
