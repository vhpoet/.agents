#!/usr/bin/env bash
# Builds an isolated workspace for one blind phase: a fresh temp directory holding only
# the files the blind agent may read. The agent runs with this directory as its working
# directory and never opens the repository.
#
#   make-clean-room-workspace.sh [--forces <forces-file>] <path | name=path> ...
#
# Each argument is copied in. A bare path keeps its basename; `name=path` copies it under
# `name`, so several sources with the same basename (three REVISED.md) coexist, and the
# brief can land under the name the sheet expects (CLEAN_ROOM_BRIEF.md=docs/.../brief.md).
# --forces copies the line's forces reference in under its own basename
# (references/product-forces.md or references/architecture-forces.md).
# Prints the workspace path. Exit 1 on a missing source or a duplicate target name.
set -euo pipefail

usage() {
  echo "Usage: $0 [--forces <forces-file>] <path | name=path> ..." >&2
  exit 1
}

forces=""
sources=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --forces)
      [[ $# -ge 2 ]] || usage
      forces="$2"
      shift 2 ;;
    --*) usage ;;
    *) sources+=("$1"); shift ;;
  esac
done
[[ ${#sources[@]} -ge 1 ]] || usage

workspace="$(mktemp -d "${TMPDIR:-/tmp}/clean-room.XXXXXX")"

copy_in() {
  local target="$1" source="$2"
  [[ -f "$source" ]] || { echo "File not found: $source" >&2; exit 1; }
  [[ ! -e "$workspace/$target" ]] || { echo "Duplicate target name: $target" >&2; exit 1; }
  cp "$source" "$workspace/$target"
}

for entry in "${sources[@]}"; do
  if [[ "$entry" == *=* && ! -f "$entry" ]]; then
    copy_in "${entry%%=*}" "${entry#*=}"
  else
    copy_in "$(basename "$entry")" "$entry"
  fi
done
[[ -z "$forces" ]] || copy_in "$(basename "$forces")" "$forces"

cat > "$workspace/README.txt" <<'TXT'
Isolated clean-room workspace.

Allowed inputs: exactly the files in this directory (a brief, the phase sheet or
PROMPT.md with your instructions, the forces reference the sheet names, and any
candidates staged for you), plus public primary sources.

Do not read the repository, git metadata, screenshots or descriptions of the current
feature, previous conversations, or other candidates. One agent session produces one
output, written into this directory.
TXT

printf '%s\n' "$workspace"
