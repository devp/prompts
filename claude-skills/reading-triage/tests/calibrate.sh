#!/usr/bin/env bash
# usage: tests/calibrate.sh   Runs wr on each doc in tests/labeled/labels.tsv
# (<path relative to labeled/> TAB <accepted verdicts, e.g. skim|skip>) and reports agreement.
set -euo pipefail
dir=$(cd "$(dirname "$0")" && pwd)/labeled
out=$(mktemp -d)
while IFS=$'\t' read -r doc want; do
  "$dir/../../wr" "$dir/$doc" >"$out/$(basename "$doc").out" 2>&1 &
done <"$dir/labels.tsv"
wait
pass=0 total=0
while IFS=$'\t' read -r doc want; do
  got=$(sed -n 's/^verdict: //p' "$out/$(basename "$doc").out")
  [[ $got =~ ^($want)$ ]] && { mark=ok; pass=$((pass + 1)); } || mark=MISS
  total=$((total + 1))
  printf '%-4s %-8s want %-10s %s\n' "$mark" "${got:-?}" "$want" "$doc"
done <"$dir/labels.tsv"
echo "$pass/$total agree; full output in $out"
