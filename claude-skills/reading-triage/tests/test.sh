#!/usr/bin/env bash
# Checks tic and structure counting on a fixture; no LLM call.
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
out=$("$here/../wr" --stats "$here/slop.md")
for expected in "tics: 13 " "2 bold" "2 em-dashes" "template sections: Overview"; do
  grep -q -- "$expected" <<<"$out" || { echo "FAIL: want '$expected', got:"; echo "$out"; exit 1; }
done
echo ok
