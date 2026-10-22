#!/usr/bin/env bash
# Check presence only; certificate import and Apple validate the credentials later.
set -euo pipefail

event="${MACOS_RELEASE_EVENT:-workflow_dispatch}"
missing=()
for name in MACOS_CERTIFICATE_P12_BASE64 MACOS_CERTIFICATE_PASSWORD; do
  if [[ -z "${!name:-}" ]]; then
    missing+=("$name")
  fi
done

has_api_key=false
has_apple_id=false
if [[ -n "${APPLE_API_KEY_ID:-}" && -n "${APPLE_API_ISSUER_ID:-}" && -n "${APPLE_API_KEY_P8_BASE64:-}" ]]; then
  has_api_key=true
fi
if [[ -n "${APPLE_ID:-}" && -n "${APPLE_APP_SPECIFIC_PASSWORD:-}" && -n "${APPLE_TEAM_ID:-}" ]]; then
  has_apple_id=true
fi
if [[ "$has_api_key" != true && "$has_apple_id" != true ]]; then
  missing+=("one complete notarization group: APPLE_ID + APPLE_APP_SPECIFIC_PASSWORD + APPLE_TEAM_ID, or APPLE_API_KEY_ID + APPLE_API_ISSUER_ID + APPLE_API_KEY_P8_BASE64")
fi

mode=release
status=0
if (( ${#missing[@]} > 0 )); then
  if [[ "$event" == workflow_dispatch && "${ALLOW_UNSIGNED_MACOS_ARTIFACT:-false}" == true ]]; then
    mode=internal
    echo "::warning::Internal macOS test build only. Signing/notarization configuration is incomplete; public release and update-feed publication are disabled."
  elif [[ "$event" == push ]]; then
    mode=skip
    echo "::warning::macOS release skipped: Apple signing/notarization secrets are not configured. No macOS build or update will be published."
  else
    mode=skip
    status=1
    echo "::error::Cannot release macOS: configure Apple signing/notarization secrets, or explicitly select allow_unsigned_artifact=true for an internal test artifact."
  fi
  printf 'Missing configuration: %s\n' "${missing[@]}"
fi

if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
  echo "mode=$mode" >> "$GITHUB_OUTPUT"
fi
if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
  {
    echo '### macOS release configuration'
    echo "Mode: **$mode**."
    if (( ${#missing[@]} > 0 )); then
      echo
      printf -- '- Missing: %s\n' "${missing[@]}"
      echo
      echo 'No public macOS release or update-feed change will be made. Existing downloads remain unchanged.'
      echo 'See docs/macos_distribution.md for setup; internal testing requires a manual run with allow_unsigned_artifact=true.'
    else
      echo 'Required secrets are present. Certificate import, signing, notarization and verification must still succeed before publication.'
    fi
  } >> "$GITHUB_STEP_SUMMARY"
fi
exit "$status"
