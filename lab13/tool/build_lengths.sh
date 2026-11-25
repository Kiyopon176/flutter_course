#!/usr/bin/env bash
# Prints every build() longer than 60 lines (nothing = rule holds).
# Usage: tool/build_lengths.sh [--all]   (--all lists every build() with its length)
cd "$(dirname "$0")/.." || exit 2
limit=60
[ "$1" = "--all" ] && limit=0
status=0
for f in $(grep -rl "Widget build(" lib); do
  awk -v F="$f" -v L="$limit" '
    /Widget build\(/ { s = NR; d = 0; inb = 1 }
    inb {
      d += gsub(/{/, "{") - gsub(/}/, "}")
      if (d == 0 && NR > s) { n = NR - s + 1; if (n > L) print n, F; inb = 0 }
    }' "$f"
done | sort -rn | tee /dev/stderr | grep -q . && [ "$limit" -ne 0 ] && status=1
exit $status
