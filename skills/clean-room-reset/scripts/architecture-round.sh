#!/usr/bin/env bash
# Runs one blind round of the architecture line: builds each isolated workspace
# (make-clean-room-workspace.sh), puts the phase sheet in PROMPT.md, runs the vendor through
# the product council's run-model.sh, and copies the answer into the reset folder. The jobs
# of a round run in parallel.
#
#   architecture-round.sh <reset-folder> <architect|simplify|judge> [--vendors fable,gpt] [--dry-run]
#
# <reset-folder>  docs/architecture-resets/<slug>/ holding CLEAN_ROOM_BRIEF.md and
#                 ARCHITECTURE_APPETITE.md.
# architect       one clean-room-architect.md run per vendor (default fable,gpt; fable-2 is a
#                 second fresh fable run standing in for an unavailable vendor)
#                 -> candidates/<vendor>/CANDIDATE.md
# simplify        one fresh fable simplify-architecture-candidate.md run per CANDIDATE.md
#                 -> candidates/<vendor>/SIMPLIFIED.md
# judge           shuffles letters over the simplified candidates once (candidates/LETTER_MAP.txt,
#                 reused when present), stages them as SIMPLIFIED_<letter>.md and runs one fresh
#                 fable select-target-architecture.md -> TARGET_ARCHITECTURE.md in the folder
# --dry-run       prints each job's workspace inputs and vendor command and runs nothing;
#                 the default runs them and spends on each vendor CLI.
#
# Console output per job: $TMPDIR/architecture-round/<slug>/<round>-<vendor>.log. Exit 1 when
# any job wrote nothing; the others' outputs are kept. Credentials: none here; each vendor CLI
# reads its own (run-model.sh lists them).
set -euo pipefail

usage() { sed -n '2,24p' "$0" | sed 's/^# \{0,1\}//'; exit "${1:-2}"; }

dry_run=0
vendors="fable,gpt"
positional=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) dry_run=1; shift ;;
    --vendors) [[ $# -ge 2 ]] || usage; vendors="$2"; shift 2 ;;
    -h|--help) usage 0 ;;
    -*) echo "Unknown option: $1" >&2; usage ;;
    *) positional+=("$1"); shift ;;
  esac
done
[[ ${#positional[@]} -eq 2 ]] || usage
reset="$(cd "${positional[0]}" && pwd)"
round="${positional[1]}"

skill="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
make_workspace="$skill/scripts/make-clean-room-workspace.sh"
run_model="$(dirname "$skill")/product-council/scripts/run-model.sh"
[[ -x "$run_model" ]] || { echo "The product-council skill must sit beside this one: $run_model not found" >&2; exit 1; }
forces="$skill/references/architecture-forces.md"
brief="$reset/CLEAN_ROOM_BRIEF.md"
appetite="$reset/ARCHITECTURE_APPETITE.md"
for file in "$brief" "$appetite"; do
  [[ -f "$file" ]] || { echo "Missing $file" >&2; exit 1; }
done

# Jobs: "label|vendor|sheet|output|copy-to|extra name=path inputs..."
jobs=()
case "$round" in
  architect)
    IFS=',' read -ra list <<<"$vendors"
    for v in "${list[@]}"; do
      case "${v%%-*}" in fable|gpt|grok|gemini) ;; *) echo "Unknown vendor: $v" >&2; exit 1 ;; esac
      jobs+=("$v|${v%%-*}|clean-room-architect.md|CANDIDATE.md|$reset/candidates/$v|")
    done ;;
  simplify)
    shopt -s nullglob
    for candidate in "$reset"/candidates/*/CANDIDATE.md; do
      v="$(basename "$(dirname "$candidate")")"
      jobs+=("$v|fable|simplify-architecture-candidate.md|SIMPLIFIED.md|$(dirname "$candidate")|CANDIDATE.md=$candidate")
    done
    [[ ${#jobs[@]} -gt 0 ]] || { echo "No candidates/<vendor>/CANDIDATE.md in $reset; run the architect round first" >&2; exit 1; } ;;
  judge)
    map="$reset/candidates/LETTER_MAP.txt"
    shopt -s nullglob
    simplified=("$reset"/candidates/*/SIMPLIFIED.md)
    [[ ${#simplified[@]} -ge 2 ]] || { echo "Need at least two candidates/<vendor>/SIMPLIFIED.md in $reset" >&2; exit 1; }
    if [[ ! -f "$map" ]]; then
      shuffled="$(for f in "${simplified[@]}"; do basename "$(dirname "$f")"; done \
        | awk 'BEGIN { srand() } { print rand() "\t" $0 }' | sort -n | cut -f2- \
        | awk '{ printf "%c = %s\n", 65 + NR - 1, $0 }')"
      if [[ $dry_run -eq 1 ]]; then
        echo "# would write $map:"; echo "$shuffled" | sed 's/^/#   /'
      else
        echo "$shuffled" >"$map"
      fi
    else
      shuffled="$(cat "$map")"
    fi
    inputs=""
    while read -r letter _ v; do
      [[ -f "$reset/candidates/$v/SIMPLIFIED.md" ]] || { echo "Letter map names $v, which has no SIMPLIFIED.md" >&2; exit 1; }
      inputs+="SIMPLIFIED_$letter.md=$reset/candidates/$v/SIMPLIFIED.md "
    done <<<"$shuffled"
    jobs+=("judge|fable|select-target-architecture.md|TARGET_ARCHITECTURE.md|$reset|${inputs% }") ;;
  *) echo "Unknown round: $round (architect|simplify|judge)" >&2; usage ;;
esac

logs="${TMPDIR:-/tmp}/architecture-round/$(basename "$reset")"
run_job() {
  local vendor="$1" sheet="$2" output="$3" copy_to="$4"; shift 4
  local workspace
  workspace="$("$make_workspace" --forces "$forces" "CLEAN_ROOM_BRIEF.md=$brief" "ARCHITECTURE_APPETITE.md=$appetite" "$@")"
  cp "$skill/phases/$sheet" "$workspace/PROMPT.md"
  echo "workspace $workspace"
  "$run_model" "$workspace" "$vendor" "$output"
  mkdir -p "$copy_to"
  cp "$workspace/$output" "$copy_to/"
  echo "copied $output -> $copy_to/"
}

pids=()
names=()
for job in "${jobs[@]}"; do
  IFS='|' read -r v vendor sheet output copy_to extra <<<"$job"
  read -ra extra_inputs <<<"$extra"
  if [[ $dry_run -eq 1 ]]; then
    echo "# $round $v: workspace = brief, appetite, architecture-forces.md${extra:+, $extra}; PROMPT.md = phases/$sheet"
    echo "  run-model.sh <workspace> $vendor $output   -> $copy_to/$output"
    continue
  fi
  mkdir -p "$logs"
  log="$logs/$round-$v.log"
  echo "start $round $v -> $log"
  run_job "$vendor" "$sheet" "$output" "$copy_to" ${extra_inputs[@]+"${extra_inputs[@]}"} >"$log" 2>&1 &
  pids+=("$!")
  names+=("$v")
done
[[ $dry_run -eq 0 ]] || exit 0

failed=0
for i in "${!pids[@]}"; do
  if wait "${pids[$i]}"; then echo "done  ${names[$i]}"; else failed=1; echo "FAIL  ${names[$i]} (log: $logs/$round-${names[$i]}.log)"; fi
done
exit $failed
