#!/usr/bin/env python3
import json
import os
import subprocess
import sys

proc = subprocess.Popen(
    ["./bedrock_server"],
    cwd="bds",
    stdin=subprocess.PIPE,
    stdout=subprocess.PIPE,
    stderr=subprocess.STDOUT,
    text=True,
    bufsize=1,
)

version = None
data = None
for line in proc.stdout:
    print(line, end="", flush=True)
    if version is None and "] Version: " in line:
        version = line.split("] Version: ", 1)[1].strip()
    if "BEDROCK_TAG_DATA:" in line:
        data = json.loads(line.split("BEDROCK_TAG_DATA:", 1)[1].strip())
        proc.stdin.write("stop\n")
        proc.stdin.flush()
        break

proc.wait(timeout=30)

if version is None:
    print("ERROR: never saw version line in server output", file=sys.stderr)
    sys.exit(1)

if data is None:
    print("ERROR: never saw BEDROCK_TAG_DATA in server output", file=sys.stderr)
    sys.exit(1)

github_output = os.environ.get("GITHUB_OUTPUT")
if github_output:
    with open(github_output, "a") as f:
        f.write(f"bds_version={version}\n")

with open("items.json", "w") as f:
    json.dump(data["items"], f, indent=2)
    f.write("\n")

with open("blocks.json", "w") as f:
    json.dump(data["blocks"], f, indent=2)
    f.write("\n")

item_count = sum(len(v) for v in data["items"].values())
block_count = sum(len(v) for v in data["blocks"].values())
print(
    f"Wrote {len(data['items'])} item tags ({item_count} entries) "
    f"and {len(data['blocks'])} block tags ({block_count} entries)"
)
