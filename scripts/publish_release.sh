#!/usr/bin/env bash
set -euo pipefail

if [ "${CHANNEL:-stable}" = "preview" ]; then
  TAG="v${BDS_VERSION}-preview"
  EXTRA_FLAGS="--prerelease"
else
  TAG="v${BDS_VERSION}"
  EXTRA_FLAGS=""
fi

gh release create "$TAG" items.json blocks.json \
  --title "Bedrock $BDS_VERSION" \
  --notes "Tag data extracted from Bedrock Dedicated Server $BDS_VERSION." \
  $EXTRA_FLAGS
