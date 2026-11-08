#!/usr/bin/env bash
# Runs one blind council phase end to end: build the isolated workspace, write PROMPT.md,
# run the vendor, copy the outputs into the record.
#
#   run-phase.sh <record-folder> <propose|critique|judge|reconsider> <fable|gpt|grok|gemini> <output-file>
#                [--role councillor|judge] [--input name=path ...] [--copy-to <dir>]
#
# <record-folder>  docs/product-council/<yyyy-mm-dd>-<slug>/, must hold BRIEF.md.
# <output-file>    the phase's last file: PROPOSAL.md, REVISED.md, DECISION.md, RECONSIDER.md.
# --role           reconsider only; appends "You are the councillor." or "You are the judge." to PROMPT.md.
# --input          a file the phase may read, staged under <name> (OWN.md, PROPOSAL_A.md, REVISED_B.md,
#                  NOTE.md, DECISION.md, RECONSIDER_C.md). Repeatable.
# --copy-to        after the vendor returns, copy <output-file> and its companions (CRITIQUE.md,
#                  ROUND.md) into this directory, created if missing.
#
# The sheet travels inside PROMPT.md only, so no sheet name can collide with an output name.
# Prints the workspace path, then the output path. Exit 1 when the vendor wrote nothing.
# `council-stage.sh` prints the exact invocations for each round.
set -euo pipefail

usage() {
  echo "Usage: $0 <record-folder> <propose|critique|judge|reconsider> <fable|gpt|grok|gemini> <output-file> [--role councillor|judge] [--input name=path ...] [--copy-to <dir>]" >&2
  exit 1
}

[[ $# -ge 4 ]] || usage
record_folder="$1"
phase="$2"
vendor="$3"
output_file="$4"
shift 4

skill_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
clean_room_dir="$(dirname "$skill_dir")/clean-room-reset"
[[ -d "$clean_room_dir/references" ]] || { echo "The clean-room-reset skill must sit beside this one: $clean_room_dir not found" >&2; exit 1; }
brief="$record_folder/BRIEF.md"
forces="$clean_room_dir/references/product-forces.md"

case "$phase" in
  propose) sheet="$skill_dir/phases/propose.md" ;;
  critique) sheet="$skill_dir/phases/critique-and-revise.md" ;;
  judge) sheet="$skill_dir/phases/judge.md" ;;
  reconsider) sheet="$skill_dir/phases/reconsider.md" ;;
  *) echo "Unknown phase: $phase" >&2; usage ;;
esac
case "$vendor" in fable|gpt|grok|gemini) ;; *) echo "Unknown vendor: $vendor" >&2; usage ;; esac
[[ -f "$brief" ]] || { echo "No BRIEF.md in $record_folder" >&2; exit 1; }

role=""
copy_to=""
inputs=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --role)
      [[ $# -ge 2 ]] || usage
      role="$2"
      case "$role" in councillor|judge) ;; *) echo "Unknown role: $role" >&2; usage ;; esac
      shift 2 ;;
    --input)
      [[ $# -ge 2 && "$2" == *=* ]] || usage
      inputs+=("$2")
      shift 2 ;;
    --copy-to)
      [[ $# -ge 2 ]] || usage
      copy_to="$2"
      shift 2 ;;
    *) usage ;;
  esac
done
[[ "$phase" != reconsider || -n "$role" ]] || { echo "reconsider needs --role councillor|judge" >&2; exit 1; }

workspace="$("$clean_room_dir/scripts/make-clean-room-workspace.sh" --forces "$forces" \
  "BRIEF.md=$brief" ${inputs[@]+"${inputs[@]}"})"

cp "$sheet" "$workspace/PROMPT.md"
if [[ -n "$role" ]]; then
  printf '\nYou are the %s.\n' "$role" >>"$workspace/PROMPT.md"
fi

echo "$workspace"
"$skill_dir/scripts/run-model.sh" "$workspace" "$vendor" "$output_file"

if [[ -n "$copy_to" ]]; then
  mkdir -p "$copy_to"
  cp "$workspace/$output_file" "$copy_to/"
  for companion in CRITIQUE.md ROUND.md; do
    if [[ -f "$workspace/$companion" && "$companion" != "$output_file" ]]; then cp "$workspace/$companion" "$copy_to/"; fi
  done
fi
