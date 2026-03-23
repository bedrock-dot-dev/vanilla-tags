#!/usr/bin/env bash
set -euo pipefail

if [ "${CHANNEL:-stable}" = "preview" ]; then
  DL_TYPE="serverBedrockPreviewLinux"
else
  DL_TYPE="serverBedrockLinux"
fi

URL=$(curl -s https://net-secondary.web.minecraft-services.net/api/v1.0/download/links \
  | jq -r ".result.links[] | select(.downloadType==\"$DL_TYPE\") | .downloadUrl")
VERSION=$(echo "$URL" | sed 's/.*bedrock-server-\([^/]*\)\.zip/\1/')
echo "Downloading $URL (version $VERSION)"
if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "bds_version=$VERSION" >> "$GITHUB_OUTPUT"
fi
curl -L -A "Mozilla/5.0" "$URL" -o bds.zip
unzip -q bds.zip -d bds
chmod +x bds/bedrock_server

HEADER_UUID=$(uuidgen | tr '[:upper:]' '[:lower:]')
MODULE_UUID=$(uuidgen | tr '[:upper:]' '[:lower:]')

SCRIPT_VERSION=$(curl -s https://registry.npmjs.org/@minecraft/server/latest | jq -r '.version')
echo "Using @minecraft/server@$SCRIPT_VERSION"

# copy pack files
mkdir -p bds/behavior_packs/vanilla-tags/scripts
jq --arg h "$HEADER_UUID" --arg m "$MODULE_UUID" --arg v "$SCRIPT_VERSION" \
  '.header.uuid = $h | .modules[0].uuid = $m | .dependencies[0].version = $v' \
  scripts/bp/manifest.json > bds/behavior_packs/vanilla-tags/manifest.json
cp scripts/bp/scripts/main.js bds/behavior_packs/vanilla-tags/scripts/

# setup bds
echo "eula=true" > bds/eula.txt
cat > bds/server.properties << 'EOF'
level-name=tag-extractor
online-mode=false
server-port=19132
max-players=0
EOF

mkdir -p 'bds/worlds/tag-extractor'
jq -n --arg uuid "$HEADER_UUID" \
  '[{"pack_id": $uuid, "version": [1, 0, 0]}]' \
  > 'bds/worlds/tag-extractor/world_behavior_packs.json'
