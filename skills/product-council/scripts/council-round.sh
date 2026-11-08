#!/usr/bin/env bash
# Runs one parallel council round: the three councillor commands council-stage.sh prints
# for that round, all at once, each through run-phase.sh (which builds the blind workspace,
# runs the vendor through run-model.sh and copies the outputs into the record).
#
#   council-round.sh <record> <propose|critique-1|critique-2> [--dry-run]
#
# <record>    docs/product-council/<yyyy-mm-dd>-<slug>/ with BRIEF.md and RUN.md's letter map
#             (council-stage.sh letters writes it).
# --dry-run   prints the three commands and runs nothing; the default runs them and spends
#             on each vendor (Claude, Codex, Grok or Gemini CLIs, each with its own sign-in).
#
# Writes: proposals/<vendor>/PROPOSAL.md (propose), critiques/round-<n>/<vendor>/CRITIQUE.md
# and REVISED.md (critique), via run-phase.sh's --copy-to; each councillor's console output
# goes to $TMPDIR/council-logs/<record name>/<round>-<vendor>.log, outside the record.
# Exit 1 when any councillor wrote nothing; the others'
# outputs are kept, and the failed one is re-run alone with its printed command.
# The judge and reconsider rounds are single or sequential: run council-stage.sh's command.
# Credentials: none here; each vendor CLI reads its own.
set -euo pipefail

usage() { sed -n '2,19p' "$0" | sed 's/^# \{0,1\}//'; exit "${1:-2}"; }
case "${1:-}" in -h|--help) usage 0 ;; esac

dry_run=0
positional=()
for argument in "$@"; do
  case "$argument" in
    --dry-run) dry_run=1 ;;
    -h|--help) usage 0 ;;
    -*) echo "Unknown option: $argument" >&2; usage ;;
    *) positional+=("$argument") ;;
  esac
done
[[ ${#positional[@]} -eq 2 ]] || usage
record="${positional[0]%/}"
round="${positional[1]}"

stage="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/council-stage.sh"
case "$round" in
  propose) commands="$("$stage" propose "$record")" ;;
  critique-1|critique-2) commands="$("$stage" critique "$record" "${round#critique-}")" ;;
  *) echo "Unknown round: $round (propose|critique-1|critique-2)" >&2; usage ;;
esac

if [[ $dry_run -eq 1 ]]; then
  echo "# dry run: would run these in parallel"
  echo "$commands"
  exit 0
fi

logs="${TMPDIR:-/tmp}/council-logs/$(basename "$record")"
mkdir -p "$logs"
pids=()
names=()
while IFS= read -r command; do
  [[ -n "$command" ]] || continue
  # The vendor record name is the --copy-to directory's basename.
  vendor="$(basename "${command##*--copy-to }")"
  log="$logs/$round-$vendor.log"
  echo "start $vendor -> $log"
  bash -c "$command" >"$log" 2>&1 &
  pids+=("$!")
  names+=("$vendor|$command")
done <<<"$commands"

failed=0
for i in "${!pids[@]}"; do
  vendor="${names[$i]%%|*}"
  if wait "${pids[$i]}"; then
    echo "done  $vendor"
  else
    failed=1
    echo "FAIL  $vendor (log: $logs/$round-$vendor.log); re-run alone:"
    echo "      ${names[$i]#*|}"
  fi
done
exit $failed
