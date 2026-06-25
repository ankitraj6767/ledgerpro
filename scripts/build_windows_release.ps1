$ErrorActionPreference = "Stop"

flutter config --enable-windows-desktop
flutter pub get
flutter analyze lib test
flutter test
flutter build windows --release

$artifact = Resolve-Path "build/windows/x64/runner/Release"
Write-Host "NAVDREAM Windows build ready at: $artifact"

# Package a clean, versioned ZIP + SHA-256 checksum for distribution so local
# Windows builds produce the same downloadable artifact as CI.
& "$PSScriptRoot/package_windows_release.ps1"
