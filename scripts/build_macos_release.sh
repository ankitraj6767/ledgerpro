#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root_dir"

flutter config --enable-macos-desktop
flutter pub get
flutter analyze
flutter test
flutter build macos --release

./scripts/package_macos_release.sh
