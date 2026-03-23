#!/usr/bin/env bash
set -euo pipefail

URL=$(curl -s https://net-secondary.web.minecraft-services.net/api/v1.0/download/links \
  | jq -r '.result.links[] | select(.downloadType=="serverBedrockLinux") | .downloadUrl')
echo "Downloading $URL"
curl --http1.1 -L "$URL" -o bds.zip
unzip -q bds.zip -d bds
chmod +x bds/bedrock_server

HEADER_UUID=$(uuidgen | tr '[:upper:]' '[:lower:]')
MODULE_UUID=$(uuidgen | tr '[:upper:]' '[:lower:]')

# copy pack files
mkdir -p bds/behavior_packs/vanilla-tags/scripts
jq --arg h "$HEADER_UUID" --arg m "$MODULE_UUID" \
  '.header.uuid = $h | .modules[0].uuid = $m' \
  bp/manifest.json > bds/behavior_packs/vanilla-tags/manifest.json
cp bp/scripts/main.js bds/behavior_packs/vanilla-tags/scripts/

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
