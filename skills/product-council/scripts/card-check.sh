#!/usr/bin/env bash
# Counts the founder card in a DECISION.md: the state at most 600 characters, the question at
# most 200. Prints both counts and exits 1 when either is over or missing, so the conductor
# sends the judge the one line it needs instead of editing the card.
#
#   card-check.sh <DECISION.md>
#
# Expects, under the heading that contains "Founder card", one paragraph starting with
# `**State.**` and one starting with `**Question.**` (the judge sheet prescribes this shape).
set -euo pipefail

[[ $# -eq 1 && -f "$1" ]] || { echo "Usage: $0 <DECISION.md>" >&2; exit 2; }
file="$1"

section="$(awk '/^#/ { on = (tolower($0) ~ /founder card/); next } on { print }' "$file")"
[[ -n "$section" ]] || { echo "no 'Founder card' section" >&2; exit 1; }

paragraph() {
  # The paragraph (up to a blank line) that starts with the given bold label, label removed.
  printf '%s\n' "$section" | awk -v label="$1" '
    index($0, label) == 1 { on = 1; $0 = substr($0, length(label) + 1); sub(/^[[:space:]]+/, "") }
    on && /^[[:space:]]*$/ { exit }
    on { print }' | paste -sd ' ' - | sed 's/[[:space:]]\{2,\}/ /g; s/^ //; s/ $//'
}

count() { printf '%s' "$1" | LC_ALL=en_US.UTF-8 wc -m | tr -d ' '; }

state="$(paragraph '**State.**')"
question="$(paragraph '**Question.**')"
status=0

if [[ -z "$state" ]]; then echo "state: missing (expected a paragraph starting with **State.**)"; status=1
else n="$(count "$state")"; echo "state: $n characters (limit 600)"; [[ $n -le 600 ]] || status=1; fi

if [[ -z "$question" ]]; then echo "question: missing (expected a paragraph starting with **Question.**)"; status=1
else n="$(count "$question")"; echo "question: $n characters (limit 200)"; [[ $n -le 200 ]] || status=1
  [[ "$question" == *"Yes = I proceed as recommended."* ]] || { echo "question: does not end with 'Yes = I proceed as recommended.'"; status=1; }; fi

exit $status
