#!/usr/bin/env bash
#
# Publishes a built release artifact to a public Supabase Storage bucket and
# updates the shared update manifest (the "appcast") that the in-app updater
# reads. Used by the Android release workflow (runs on an Ubuntu runner).
#
# It performs three steps:
#   1. Upload the artifact (APK/ZIP) to <bucket>/<filename> (upsert).
#   2. Download the current update-manifest.json (or start fresh).
#   3. Patch this platform's entry and upload the manifest back (upsert).
#
# The artifact is referenced by its public URL:
#   <SUPABASE_URL>/storage/v1/object/public/<bucket>/<filename>
#
# Requirements: bash, curl, jq, sha256sum (all present on ubuntu-latest).
#
# Required environment variables:
#   SUPABASE_URL                 e.g. https://<project>.supabase.co
#   SUPABASE_SERVICE_ROLE_KEY    service-role key (GitHub secret, never shipped)
#
# Usage:
#   scripts/publish_supabase_release.sh \
#     --platform android \
#     --version 1.0.2 \
#     --build 4 \
#     --file build/app/outputs/flutter-apk/app-release.apk \
#     --notes "What changed" \
#     [--bucket app-releases] \
#     [--manifest update-manifest.json] \
#     [--content-type application/vnd.android.package-archive] \
#     [--mandatory false] \
#     [--min-supported 1.0.0] \
#     [--artifact-name LedgerPro-Android-v1.0.2.apk]

set -euo pipefail

PLATFORM=""
VERSION=""
BUILD=""
FILE=""
NOTES=""
BUCKET="app-releases"
MANIFEST_OBJECT="update-manifest.json"
CONTENT_TYPE=""
MANDATORY="false"
MIN_SUPPORTED=""
ARTIFACT_NAME=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --platform) PLATFORM="$2"; shift 2 ;;
    --version) VERSION="$2"; shift 2 ;;
    --build) BUILD="$2"; shift 2 ;;
    --file) FILE="$2"; shift 2 ;;
    --notes) NOTES="$2"; shift 2 ;;
    --bucket) BUCKET="$2"; shift 2 ;;
    --manifest) MANIFEST_OBJECT="$2"; shift 2 ;;
    --content-type) CONTENT_TYPE="$2"; shift 2 ;;
    --mandatory) MANDATORY="$2"; shift 2 ;;
    --min-supported) MIN_SUPPORTED="$2"; shift 2 ;;
    --artifact-name) ARTIFACT_NAME="$2"; shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done

: "${SUPABASE_URL:?SUPABASE_URL is required}"
: "${SUPABASE_SERVICE_ROLE_KEY:?SUPABASE_SERVICE_ROLE_KEY is required}"

if [[ -z "$PLATFORM" || -z "$VERSION" || -z "$FILE" ]]; then
  echo "::error::--platform, --version and --file are required." >&2
  exit 2
fi
if [[ ! -f "$FILE" ]]; then
  echo "::error::Artifact not found: $FILE" >&2
  exit 1
fi

# Normalize the version (strip a leading v and any +build suffix).
VERSION="${VERSION#v}"
VERSION="${VERSION%%+*}"

ORIGIN="${SUPABASE_URL%/}"
FILENAME="${ARTIFACT_NAME:-$(basename "$FILE")}"
PUBLIC_URL="$ORIGIN/storage/v1/object/public/$BUCKET/$FILENAME"

if [[ -z "$CONTENT_TYPE" ]]; then
  case "$FILENAME" in
    *.apk) CONTENT_TYPE="application/vnd.android.package-archive" ;;
    *.zip) CONTENT_TYPE="application/zip" ;;
    *) CONTENT_TYPE="application/octet-stream" ;;
  esac
fi

SHA256="$(sha256sum "$FILE" | awk '{print $1}')"

echo "Publishing $PLATFORM release:"
echo "  version:   $VERSION (build ${BUILD:-n/a})"
echo "  file:      $FILE"
echo "  artifact:  $FILENAME"
echo "  bucket:    $BUCKET"
echo "  sha256:    $SHA256"
echo "  publicUrl: $PUBLIC_URL"

# --- 1. Upload the artifact (upsert) ----------------------------------------
echo "Uploading artifact..."
curl -fsSL -X POST "$ORIGIN/storage/v1/object/$BUCKET/$FILENAME" \
  -H "Authorization: Bearer $SUPABASE_SERVICE_ROLE_KEY" \
  -H "x-upsert: true" \
  -H "Cache-Control: no-cache" \
  -H "Content-Type: $CONTENT_TYPE" \
  --data-binary "@$FILE" \
  -o /dev/null
echo "Artifact uploaded."

# --- 2. Fetch the current manifest (or start fresh) -------------------------
CURRENT="$(mktemp)"
if curl -fsSL "$ORIGIN/storage/v1/object/$BUCKET/$MANIFEST_OBJECT" \
  -H "Authorization: Bearer $SUPABASE_SERVICE_ROLE_KEY" \
  -o "$CURRENT" 2>/dev/null; then
  if ! jq empty "$CURRENT" >/dev/null 2>&1; then
    echo "Existing manifest was not valid JSON; starting fresh."
    echo '{}' > "$CURRENT"
  fi
else
  echo "No existing manifest found; creating a new one."
  echo '{}' > "$CURRENT"
fi

# --- 3. Patch this platform's entry and upload ------------------------------
BUILD_JSON="null"
if [[ -n "$BUILD" ]]; then BUILD_JSON="$BUILD"; fi
MANDATORY_JSON="false"
if [[ "$MANDATORY" == "true" ]]; then MANDATORY_JSON="true"; fi

UPDATED="$(mktemp)"
jq \
  --arg p "$PLATFORM" \
  --arg v "$VERSION" \
  --argjson b "$BUILD_JSON" \
  --arg u "$PUBLIC_URL" \
  --arg s "$SHA256" \
  --arg n "$NOTES" \
  --arg fn "$FILENAME" \
  --argjson m "$MANDATORY_JSON" \
  --arg min "$MIN_SUPPORTED" \
  '
  .[$p] = (
    {
      version: $v,
      buildNumber: $b,
      url: $u,
      sha256: $s,
      notes: $n,
      fileName: $fn,
      mandatory: $m
    }
    + (if $min == "" then {} else { minSupportedVersion: $min } end)
  )
  | .updatedAt = (now | todate)
  ' "$CURRENT" > "$UPDATED"

echo "New manifest:"
cat "$UPDATED"

echo "Uploading manifest..."
curl -fsSL -X POST "$ORIGIN/storage/v1/object/$BUCKET/$MANIFEST_OBJECT" \
  -H "Authorization: Bearer $SUPABASE_SERVICE_ROLE_KEY" \
  -H "x-upsert: true" \
  -H "Cache-Control: no-cache" \
  -H "Content-Type: application/json" \
  --data-binary "@$UPDATED" \
  -o /dev/null

rm -f "$CURRENT" "$UPDATED"
echo "Done. $PLATFORM $VERSION is now the latest release."
