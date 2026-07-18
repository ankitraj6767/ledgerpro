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

function Copy-VCRuntime {
    <#
        Copies the Microsoft Visual C++ runtime redistributable DLLs into the
        release directory (app-local deployment).

        The Flutter runner and several plugin DLLs (notably
        flutter_secure_storage_windows_plugin.dll) link dynamically against the
        MSVC runtime: vcruntime140.dll, vcruntime140_1.dll, msvcp140.dll and
        friends. On target machines without an up-to-date "Microsoft Visual C++
        Redistributable", one of those dependencies is missing, so a plugin DLL
        fails to load and Windows reports the "Bad Image" error with status
        0xc0e90002.

        Shipping these DLLs next to the executable makes the app self-contained:
        the Windows loader resolves them from the application directory first, so
        no machine-wide install is required on the target. Microsoft explicitly
        permits this app-local redistribution of the CRT DLLs.

        Best-effort: if Visual Studio / the redist cannot be located (for example
        when packaging on a host without VS), a warning is emitted and packaging
        continues. On the CI Windows runner VS is always present, so released
        ZIPs always include the runtime.
    #>
    param([Parameter(Mandatory = $true)] [string]$Destination)

    # These MUST be present next to the exe or a clean target machine fails with
    # the "Bad Image" 0xc0e90002 error. vcruntime140_1.dll in particular is the
    # one most often missing on machines with only an older redistributable.
    $required = @('vcruntime140.dll', 'vcruntime140_1.dll', 'msvcp140.dll')
    # Nice-to-have companions that some C++ standard-library features pull in.
    $optional = @(
        'msvcp140_1.dll', 'msvcp140_2.dll', 'msvcp140_atomic_wait.dll',
        'msvcp140_codecvt_ids.dll', 'concrt140.dll', 'vccorlib140.dll',
        'vcruntime140_threads.dll'
    )
    $wanted = $required + $optional

    # Build the ordered list of source directories to pull DLLs from.
    $sourceDirs = New-Object System.Collections.Generic.List[string]

    # Primary source: the official VC++ redistributable that ships with Visual
    # Studio. Discover the CRT folder directly (its version can differ from
    # Microsoft.VCRedistVersion.default.txt), preferring the newest.
    $vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'
    if (Test-Path $vswhere) {
        $vsPath = & $vswhere -latest -products * -property installationPath 2>$null | Select-Object -First 1
        if (-not [string]::IsNullOrWhiteSpace($vsPath)) {
            $redistRoot = Join-Path $vsPath 'VC\Redist\MSVC'
            if (Test-Path $redistRoot) {
                foreach ($versionDir in (Get-ChildItem -Path $redistRoot -Directory | Sort-Object Name -Descending)) {
                    $crt = Get-ChildItem -Path (Join-Path $versionDir.FullName 'x64') -Directory -Filter 'Microsoft.VC*.CRT' -ErrorAction SilentlyContinue |
                        Sort-Object Name -Descending | Select-Object -First 1
                    if ($crt) { $sourceDirs.Add($crt.FullName); break }
                }
            }
        }
    }

    # Fallback source: the live system runtime. It is always present on a host
    # that can build the Windows app in the first place, and contains the exact
    # same DLLs. Guarantees bundling even if the redist folder cannot be located.
    $sourceDirs.Add((Join-Path $env:WINDIR 'System32'))

    foreach ($name in $wanted) {
        if (Test-Path (Join-Path $Destination $name)) { continue }
        foreach ($dir in $sourceDirs) {
            $src = Join-Path $dir $name
            if (Test-Path $src) {
                Copy-Item -Path $src -Destination $Destination -Force
                Write-Host "  Bundled runtime DLL: $name (from $dir)"
                break
            }
        }
    }

    # Hard-fail if any required runtime DLL is still missing. Publishing a ZIP
    # without these produces the exact "Bad Image" crash we are fixing, so we
    # must never ship one silently.
    $missing = @($required | Where-Object { -not (Test-Path (Join-Path $Destination $_)) })
    if ($missing.Count -gt 0) {
        throw "VC++ runtime bundling failed; missing: $($missing -join ', '). Install Visual Studio or the Microsoft Visual C++ Redistributable on the build host and retry."
    }
    Write-Host "Verified Visual C++ runtime is bundled ($($required -join ', '))."
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

# --- Bundle the Visual C++ runtime (app-local deployment) -------------------
# Makes the app self-contained so it launches on machines that do not have the
# Microsoft Visual C++ Redistributable installed. Without this, plugin DLLs such
# as flutter_secure_storage_windows_plugin.dll fail to load with the Windows
# "Bad Image" error (status 0xc0e90002).
Copy-VCRuntime -Destination $stagingDir

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
