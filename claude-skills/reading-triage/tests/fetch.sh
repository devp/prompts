#!/usr/bin/env bash
# Checks connector-fetch extraction against a canned stream; no LLM call.
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
out=$(PATH="$here/stub:$PATH" "$here/../wr" --stats https://linear.app/x/issue/X-1)
for expected in "words: 8 "; do
  grep -q -- "$expected" <<<"$out" || { echo "FAIL: want '$expected', got:"; echo "$out"; exit 1; }
done
echo ok
