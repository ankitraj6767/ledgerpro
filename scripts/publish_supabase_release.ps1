<#
.SYNOPSIS
    Publishes a built release artifact to a public Supabase Storage bucket and
    updates the shared update manifest (the "appcast") read by the in-app
    updater. Used by the Windows release workflow (runs on a Windows runner).

.DESCRIPTION
    1. Uploads the artifact (ZIP/APK) to <bucket>/<filename> (upsert).
    2. Downloads the current update-manifest.json (or starts fresh).
    3. Patches this platform's entry and uploads the manifest back (upsert).

    The artifact is referenced by its public URL:
      <SupabaseUrl>/storage/v1/object/public/<bucket>/<filename>

.NOTES
    Requires environment variables:
      SUPABASE_URL                e.g. https://<project>.supabase.co
      SUPABASE_SERVICE_ROLE_KEY   service-role key (GitHub secret)
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$Platform,
    [Parameter(Mandatory = $true)][string]$Version,
    [Parameter(Mandatory = $true)][string]$File,
    [string]$Build = "",
    [string]$Notes = "",
    [string]$Bucket = "app-releases",
    [string]$ManifestObject = "update-manifest.json",
    [string]$ContentType = "",
    [string]$ArtifactName = "",
    [bool]$Mandatory = $false,
    [string]$MinSupported = ""
)

$ErrorActionPreference = "Stop"

$supabaseUrl = $env:SUPABASE_URL
$serviceKey = $env:SUPABASE_SERVICE_ROLE_KEY
if ([string]::IsNullOrWhiteSpace($supabaseUrl)) {
    throw "SUPABASE_URL environment variable is required."
}
if ([string]::IsNullOrWhiteSpace($serviceKey)) {
    throw "SUPABASE_SERVICE_ROLE_KEY environment variable is required."
}
if (-not (Test-Path $File)) {
    throw "Artifact not found: $File"
}

# Normalize the version (strip a leading v and any +build suffix).
$Version = $Version.Trim()
if ($Version -match '^[vV]') { $Version = $Version.Substring(1) }
$Version = ($Version -split '\+')[0].Trim()

$origin = $supabaseUrl.TrimEnd('/')
$fileName = if ([string]::IsNullOrWhiteSpace($ArtifactName)) {
    Split-Path -Leaf $File
} else {
    $ArtifactName
}
$publicUrl = "$origin/storage/v1/object/public/$Bucket/$fileName"

if ([string]::IsNullOrWhiteSpace($ContentType)) {
    switch -Wildcard ($fileName) {
        "*.zip" { $ContentType = "application/zip" }
        "*.apk" { $ContentType = "application/vnd.android.package-archive" }
        default { $ContentType = "application/octet-stream" }
    }
}

$sha256 = (Get-FileHash -Path $File -Algorithm SHA256).Hash.ToLower()

Write-Host "Publishing $Platform release:"
Write-Host "  version:   $Version (build $Build)"
Write-Host "  file:      $File"
Write-Host "  artifact:  $fileName"
Write-Host "  bucket:    $Bucket"
Write-Host "  sha256:    $sha256"
Write-Host "  publicUrl: $publicUrl"

$authHeaders = @{
    "Authorization" = "Bearer $serviceKey"
    "x-upsert"      = "true"
    "Cache-Control" = "no-cache"
}

# --- 1. Upload the artifact (upsert) ----------------------------------------
Write-Host "Uploading artifact..."
Invoke-RestMethod -Method Post `
    -Uri "$origin/storage/v1/object/$Bucket/$fileName" `
    -Headers $authHeaders `
    -ContentType $ContentType `
    -InFile $File | Out-Null
Write-Host "Artifact uploaded."

# --- 2. Fetch the current manifest (or start fresh) -------------------------
$manifest = $null
try {
    $existing = Invoke-RestMethod -Method Get `
        -Uri "$origin/storage/v1/object/$Bucket/$ManifestObject" `
        -Headers @{ "Authorization" = "Bearer $serviceKey" }
    if ($existing -is [string]) {
        $manifest = $existing | ConvertFrom-Json
    } else {
        $manifest = $existing
    }
} catch {
    Write-Host "No existing manifest found; creating a new one."
}
if ($null -eq $manifest) {
    $manifest = [pscustomobject]@{}
}

# --- 3. Patch this platform's entry -----------------------------------------
$entry = [ordered]@{
    version   = $Version
    buildNumber = if ([string]::IsNullOrWhiteSpace($Build)) { $null } else { [int]$Build }
    url       = $publicUrl
    sha256    = $sha256
    notes     = $Notes
    fileName  = $fileName
    mandatory = [bool]$Mandatory
}
if (-not [string]::IsNullOrWhiteSpace($MinSupported)) {
    $entry["minSupportedVersion"] = $MinSupported
}

# Add or replace the platform property on the manifest object.
$manifest | Add-Member -NotePropertyName $Platform -NotePropertyValue ([pscustomobject]$entry) -Force
$manifest | Add-Member -NotePropertyName "updatedAt" -NotePropertyValue ((Get-Date).ToUniversalTime().ToString("o")) -Force

$json = $manifest | ConvertTo-Json -Depth 8
Write-Host "New manifest:"
Write-Host $json

$tempManifest = Join-Path ([System.IO.Path]::GetTempPath()) "update-manifest-$([guid]::NewGuid()).json"
# Write UTF-8 WITHOUT a BOM. A leading BOM would break the client's JSON parse.
[System.IO.File]::WriteAllText(
    $tempManifest,
    $json,
    (New-Object System.Text.UTF8Encoding($false))
)

Write-Host "Uploading manifest..."
Invoke-RestMethod -Method Post `
    -Uri "$origin/storage/v1/object/$Bucket/$ManifestObject" `
    -Headers $authHeaders `
    -ContentType "application/json" `
    -InFile $tempManifest | Out-Null

Remove-Item -Path $tempManifest -Force -ErrorAction SilentlyContinue
Write-Host "Done. $Platform $Version is now the latest release."
