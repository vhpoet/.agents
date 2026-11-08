#!/usr/bin/env bash
# The conductor's deterministic plumbing: letters, input staging and the record layout.
# It spends nothing; it prints the run-phase.sh commands the conductor runs in the background.
#
#   council-stage.sh letters    <record> <vendor> <vendor> <vendor>
#   council-stage.sh propose    <record>
#   council-stage.sh critique   <record> <round>
#   council-stage.sh judge      <record> <round>
#   council-stage.sh reconsider <record> <n> <vendor>...
#
# Record layout (docs/product-council/<yyyy-mm-dd>-<slug>/):
#   BRIEF.md                           proposals/<vendor>/PROPOSAL.md
#   critiques/round-<n>/<vendor>/      CRITIQUE.md and REVISED.md
#   DECISION.md                        rounds/<n>/NOTE.md, rounds/<n>/<vendor>/RECONSIDER.md, rounds/<n>/ROUND.md
#   RUN.md                             vendors, the letter map, why critique stopped, any fallback
#
# `letters` shuffles A, B, C over the vendors once per decision and appends the map to RUN.md;
# every later round and the judge reuse it, because revised texts refer to each other by letter.
# Vendor names are the record names (fable, gpt, fable-2 for a second fable run), so the same
# vendor may appear twice under two names.
set -euo pipefail

usage() { sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//' >&2; exit 2; }

run_phase="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/run-phase.sh"

[[ $# -ge 2 ]] || usage
command="$1"
record="${2%/}"
shift 2
[[ -f "$record/BRIEF.md" ]] || { echo "No BRIEF.md in $record" >&2; exit 1; }

# Prints "letter vendor" lines from RUN.md's letter map.
letter_map() {
  awk '/^## Letter map/ { on = 1; next } /^## / { on = 0 } on && /^- [A-Z] = / { print $2, $4 }' "$record/RUN.md" 2>/dev/null
}
require_map() { [[ -n "$(letter_map)" ]] || { echo "No letter map in $record/RUN.md; run: $0 letters $record <vendor> <vendor> <vendor>" >&2; exit 1; }; }
letter_of() { letter_map | awk -v v="$1" '$2 == v { print $1 }'; }
vendors() { letter_map | awk '{ print $2 }'; }
last_critique_round() { ls -d "$record"/critiques/round-* 2>/dev/null | sed 's/.*round-//' | sort -n | tail -1; }

case "$command" in
  letters)
    [[ $# -eq 3 ]] || usage
    if [[ -n "$(letter_map)" ]]; then echo "RUN.md already holds a letter map; one shuffle per decision" >&2; exit 1; fi
    [[ -f "$record/RUN.md" ]] && lead=$'\n' || lead=$'# Run log\n\n'
    { printf '%s' "$lead"
      printf 'Vendors: %s\n\n## Letter map\n\n' "$(printf '%s, ' "$@" | sed 's/, $//')"
      printf '%s\n' "$@" | awk 'BEGIN { srand() } { print rand() "\t" $0 }' | sort -n | cut -f2- \
        | awk '{ printf "- %c = %s\n", 65 + NR - 1, $0 }'
    } >>"$record/RUN.md"
    letter_map ;;

  propose)
    [[ $# -eq 0 ]] || usage
    require_map
    for v in $(vendors); do
      echo "$run_phase $record propose ${v%%-*} PROPOSAL.md --copy-to $record/proposals/$v"
    done ;;

  critique)
    [[ $# -eq 1 ]] || usage
    round="$1"; require_map
    for v in $(vendors); do
      args=()
      for w in $(vendors); do
        if [[ $round -eq 1 ]]; then src="$record/proposals/$w/PROPOSAL.md"; else src="$record/critiques/round-$((round - 1))/$w/REVISED.md"; fi
        [[ -f "$src" ]] || { echo "Missing input: $src" >&2; exit 1; }
        if [[ "$w" == "$v" ]]; then args+=("--input OWN.md=$src"); else args+=("--input PROPOSAL_$(letter_of "$w").md=$src"); fi
      done
      echo "$run_phase $record critique ${v%%-*} REVISED.md ${args[*]} --copy-to $record/critiques/round-$round/$v"
    done ;;

  judge)
    [[ $# -eq 1 ]] || usage
    round="$1"; require_map
    args=()
    for v in $(vendors); do
      src="$record/critiques/round-$round/$v/REVISED.md"
      [[ -f "$src" ]] || { echo "Missing input: $src" >&2; exit 1; }
      args+=("--input REVISED_$(letter_of "$v").md=$src")
    done
    echo "$run_phase $record judge fable DECISION.md ${args[*]} --copy-to $record" ;;

  reconsider)
    [[ $# -ge 2 ]] || usage
    n="$1"; shift; require_map
    note="$record/rounds/$n/NOTE.md"
    [[ -f "$note" ]] || { echo "Save the founder's note verbatim first: $note" >&2; exit 1; }
    last="$(last_critique_round)"
    [[ -n "$last" ]] || { echo "No critique round found" >&2; exit 1; }
    judge_args=("--input DECISION.md=$record/DECISION.md" "--input NOTE.md=$note")
    for v in "$@"; do
      own="$record/critiques/round-$last/$v/REVISED.md"
      [[ -f "$own" ]] || { echo "Missing final revised direction: $own" >&2; exit 1; }
      echo "$run_phase $record reconsider ${v%%-*} RECONSIDER.md --role councillor --input DECISION.md=$record/DECISION.md --input NOTE.md=$note --input OWN.md=$own --copy-to $record/rounds/$n/$v"
      judge_args+=("--input RECONSIDER_$(letter_of "$v").md=$record/rounds/$n/$v/RECONSIDER.md")
    done
    echo "# after every councillor above has returned:"
    echo "$run_phase $record reconsider fable DECISION.md --role judge ${judge_args[*]} --copy-to $record/rounds/$n && cp $record/rounds/$n/DECISION.md $record/DECISION.md" ;;

  *) usage ;;
esac
