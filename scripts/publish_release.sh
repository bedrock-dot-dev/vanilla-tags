#!/usr/bin/env bash
set -euo pipefail

gh release create "v$BDS_VERSION" items.json blocks.json \
  --title "Bedrock $BDS_VERSION" \
  --notes "Tag data extracted from Bedrock Dedicated Server $BDS_VERSION."
