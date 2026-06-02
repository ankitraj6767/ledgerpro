$ErrorActionPreference = "Stop"

flutter config --enable-windows-desktop
flutter pub get
flutter analyze lib test
flutter test
flutter build windows --release

$artifact = Resolve-Path "build/windows/x64/runner/Release"
Write-Host "NAVDREAM Windows build ready at: $artifact"
