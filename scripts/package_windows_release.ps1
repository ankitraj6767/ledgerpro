<#
.SYNOPSIS
    Packages an already-built Flutter Windows release into a clean, versioned
    ZIP plus a SHA-256 checksum for distribution to non-technical users.

.DESCRIPTION
    Stages the contents of build/windows/x64/runner/Release into a single
    top-level folder named "LedgerPro-Windows-x64-v<version>", compresses it to
    "LedgerPro-Windows-x64-v<version>.zip", and writes a coreutils-compatible
    "<zip>.sha256" checksum next to it under dist/windows.

    The script does not build the app and does not touch any application code or
    Supabase dart-define configuration. Run "flutter build windows --release"
    first.

.PARAMETER Version
    Optional version string (for example "1.0.1" or "v1.0.1"). When omitted, the
    version is read from pubspec.yaml. Any leading "v" and any "+<build>" suffix
    are stripped.

.PARAMETER ReleaseDir
    The Flutter Windows release output directory. Defaults to
    "build/windows/x64/runner/Release".

.PARAMETER DistDir
    The output directory for the packaged ZIP and checksum. Defaults to
    "dist/windows".

.NOTES
    Intended to be run from the repository root, on a Windows host, after a
    successful "flutter build windows --release".
#>
[CmdletBinding()]
param(
    [string]$Version = "",
    [string]$ReleaseDir = "build/windows/x64/runner/Release",
    [string]$DistDir = "dist/windows"
)

$ErrorActionPreference = "Stop"

function Get-PubspecVersion {
    $pubspecPath = "pubspec.yaml"
    if (-not (Test-Path $pubspecPath)) {
        throw "pubspec.yaml not found. Run this script from the repository root."
    }

    foreach ($line in Get-Content $pubspecPath) {
        if ($line -match '^\s*version:\s*(.+?)\s*$') {
            return $Matches[1]
        }
    }

    throw "Could not find a 'version:' entry in pubspec.yaml."
}

# --- Resolve and normalize the version --------------------------------------
if ([string]::IsNullOrWhiteSpace($Version)) {
    $Version = Get-PubspecVersion
}

$Version = $Version.Trim()
if ($Version -match '^[vV]') {
    $Version = $Version.Substring(1)
}
# Drop any "+<build-number>" suffix (pubspec uses "1.0.1+3").
$Version = ($Version -split '\+')[0].Trim()

if ([string]::IsNullOrWhiteSpace($Version)) {
    throw "Resolved an empty version string. Pass -Version or set it in pubspec.yaml."
}

# --- Validate the build output ----------------------------------------------
if (-not (Test-Path $ReleaseDir)) {
    throw "Windows release directory '$ReleaseDir' not found. Run 'flutter build windows --release' first."
}

$releaseFull = (Resolve-Path $ReleaseDir).Path
$exe = Get-ChildItem -Path $releaseFull -Filter *.exe -File | Select-Object -First 1
if (-not $exe) {
    throw "No .exe found in '$ReleaseDir'. The Windows release build appears to be incomplete."
}

# --- Compute names and paths ------------------------------------------------
$archiveBase = "LedgerPro-Windows-x64-v$Version"
$archiveName = "$archiveBase.zip"
$checksumName = "$archiveName.sha256"

# Clean any previous output, then stage into a single, clearly named folder so
# the ZIP extracts to one tidy directory instead of scattering loose files.
if (Test-Path $DistDir) {
    Remove-Item -Path $DistDir -Recurse -Force
}
$distFull = (New-Item -ItemType Directory -Path $DistDir -Force).FullName
$stagingDir = Join-Path $distFull $archiveBase
$zipPath = Join-Path $distFull $archiveName
$checksumPath = Join-Path $distFull $checksumName
New-Item -ItemType Directory -Path $stagingDir -Force | Out-Null

Copy-Item -Path (Join-Path $releaseFull '*') -Destination $stagingDir -Recurse -Force

# --- Create the ZIP ---------------------------------------------------------
# Prefer the .NET API (deterministic single top-level folder via
# includeBaseDirectory=$true) and fall back to Compress-Archive if unavailable.
# Absolute paths are required because .NET's working directory may differ from
# the PowerShell location.
$useDotNetZip = $true
try {
    Add-Type -AssemblyName System.IO.Compression.FileSystem -ErrorAction Stop
} catch {
    if (-not ([System.Management.Automation.PSTypeName]'System.IO.Compression.ZipFile').Type) {
        $useDotNetZip = $false
    }
}

if ($useDotNetZip) {
    [System.IO.Compression.ZipFile]::CreateFromDirectory(
        $stagingDir,
        $zipPath,
        [System.IO.Compression.CompressionLevel]::Optimal,
        $true)
} else {
    Compress-Archive -Path $stagingDir -DestinationPath $zipPath -Force
}

if (-not (Test-Path $zipPath)) {
    throw "Packaging failed: '$zipPath' was not created."
}

# --- Generate the SHA-256 checksum ------------------------------------------
# coreutils format ("<hash>  <filename>") so it verifies with `shasum -a 256 -c`.
$hash = (Get-FileHash -Path $zipPath -Algorithm SHA256).Hash.ToLower()
Set-Content -Path $checksumPath -Value "$hash  $archiveName" -Encoding ascii

# --- Report -----------------------------------------------------------------
Write-Host "LedgerPro Windows artifact ready:"
Write-Host "  Version:  $Version"
Write-Host "  ZIP:      $zipPath"
Write-Host "  Checksum: $checksumPath"
Write-Host "  SHA-256:  $hash"
Write-Host "  Launch after extracting: $archiveBase\$($exe.Name)"

# --- Emit GitHub Actions step outputs when available ------------------------
if ($env:GITHUB_OUTPUT) {
    $zipRel = ("$DistDir/$archiveName") -replace '\\', '/'
    $checksumRel = ("$DistDir/$checksumName") -replace '\\', '/'
    $distRel = $DistDir -replace '\\', '/'

    Add-Content -Path $env:GITHUB_OUTPUT -Value "version=$Version"
    Add-Content -Path $env:GITHUB_OUTPUT -Value "artifact_base=$archiveBase"
    Add-Content -Path $env:GITHUB_OUTPUT -Value "artifact_name=$archiveName"
    Add-Content -Path $env:GITHUB_OUTPUT -Value "checksum_name=$checksumName"
    Add-Content -Path $env:GITHUB_OUTPUT -Value "zip_path=$zipRel"
    Add-Content -Path $env:GITHUB_OUTPUT -Value "checksum_path=$checksumRel"
    Add-Content -Path $env:GITHUB_OUTPUT -Value "dist_dir=$distRel"
    Add-Content -Path $env:GITHUB_OUTPUT -Value "exe_name=$($exe.Name)"
}
