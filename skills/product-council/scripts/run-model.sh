#!/usr/bin/env bash
# Runs one blind phase through one LLM vendor, headless, inside an isolated workspace.
#
#   run-model.sh <workspace-dir> <fable|gpt|grok|gemini> <output-file-basename>
#
# The workspace holds only what the phase may read plus PROMPT.md, the instruction.
# The vendor runs with cwd = workspace, may write files there, and must write its answer
# to <output-file-basename>. Raw vendor output lands in .runner/<vendor>.log.
# Exit 1 when the answer file is missing or empty.
#
# Vendors: fable  = Claude via `claude -p` (acceptEdits keeps writes inside cwd)
#          gpt    = OpenAI via `codex exec` (model from ~/.codex/config.toml, workspace-write sandbox)
#          grok   = xAI via `grok -p` (needs GROK_API_KEY)
#          gemini = Google via `gemini -p` (needs the gemini CLI signed in)
# Adding a vendor: one case below that reads PROMPT.md and runs the CLI with cwd = workspace.
set -euo pipefail

# Model ids, the one place they live. Override per run with the environment variables.
fable_model="${COUNCIL_FABLE_MODEL:-claude-fable-5-1}"
grok_model="${GROK_MODEL:-grok-4-1-fast-reasoning}"

if [[ $# -ne 3 ]]; then
  echo "Usage: $0 <workspace-dir> <fable|gpt|grok|gemini> <output-file-basename>" >&2
  exit 1
fi
workspace="$(cd "$1" && pwd)"
vendor="$2"
output="$3"
prompt_file="$workspace/PROMPT.md"
[[ -f "$prompt_file" ]] || { echo "No PROMPT.md in $workspace" >&2; exit 1; }
mkdir -p "$workspace/.runner"
log="$workspace/.runner/$vendor.log"
rm -f "$workspace/$output"
instruction="$(cat "$prompt_file")
Write your complete answer to the file $output in the current directory. Read nothing outside the current directory."
cd "$workspace"
case "$vendor" in
  fable)
    claude -p "$instruction" --model "$fable_model" --permission-mode acceptEdits \
      --allowedTools "Read,Write,Edit,Glob,Grep,WebSearch,WebFetch" >"$log" 2>&1 || true ;;
  gpt)
    codex exec -C "$workspace" -s workspace-write --skip-git-repo-check - <<<"$instruction" >"$log" 2>&1 || true ;;
  grok)
    grok -d "$workspace" -m "$grok_model" -p "$instruction" >"$log" 2>&1 || true ;;
  gemini)
    gemini -p "$instruction" --yolo >"$log" 2>&1 || true ;;
  *)
    echo "Unknown vendor: $vendor (fable|gpt|grok|gemini)" >&2; exit 1 ;;
esac
if [[ ! -s "$workspace/$output" ]]; then
  echo "$vendor wrote no $output; see $log" >&2
  tail -5 "$log" >&2
  exit 1
fi
echo "$workspace/$output"
