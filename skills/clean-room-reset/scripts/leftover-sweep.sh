#!/usr/bin/env bash
# Leftover sweep after a slice: names of the replaced mechanisms in, every hit that is not
# a deliberately frozen name out. The builder runs it before declaring done; the reviewer
# runs it again independently.
#
#   leftover-sweep.sh --names <file> [--frozen <file>] [--root <repo-root>] [--exclude <dir>]...
#
# <names file>   one name per line (tables, columns, types, constants, routes, env vars,
#                telemetry names, test names, i18n keys); blank lines and # comments ignored.
# <frozen file>  names that stay on purpose (wire contracts held by installed clients or
#                partners), same format; hits on these are not reported.
# --root         defaults to the git root of the current directory.
# --exclude      extra directories to skip, relative to root; repeatable. node_modules,
#                .git, build outputs and the reset folders themselves are always skipped.
# Prints hits grouped by name (file:line: text). Exit 0 when nothing is left, 1 otherwise.
set -euo pipefail

usage() {
  echo "Usage: $0 --names <file> [--frozen <file>] [--root <repo-root>] [--exclude <dir>]..." >&2
  exit 2
}

names_file="" frozen_file="" root=""
excludes=(node_modules .git dist build .next .expo coverage docs/architecture-resets docs/product-resets)
while [[ $# -gt 0 ]]; do
  case "$1" in
    --names) [[ $# -ge 2 ]] || usage; names_file="$2"; shift 2 ;;
    --frozen) [[ $# -ge 2 ]] || usage; frozen_file="$2"; shift 2 ;;
    --root) [[ $# -ge 2 ]] || usage; root="$2"; shift 2 ;;
    --exclude) [[ $# -ge 2 ]] || usage; excludes+=("$2"); shift 2 ;;
    *) usage ;;
  esac
done
[[ -n "$names_file" && -f "$names_file" ]] || usage
[[ -z "$frozen_file" || -f "$frozen_file" ]] || { echo "Frozen file not found: $frozen_file" >&2; exit 2; }
[[ -n "$root" ]] || root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

read_list() { grep -v '^[[:space:]]*\(#\|$\)' "$1" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//'; }

frozen=()
if [[ -n "$frozen_file" ]]; then
  while IFS= read -r line; do frozen+=("$line"); done < <(read_list "$frozen_file")
fi

is_frozen() {
  local name="$1" f
  for f in ${frozen[@]+"${frozen[@]}"}; do [[ "$f" == "$name" ]] && return 0; done
  return 1
}

# The files git tracks or would track (untracked, not ignored), minus the excluded directories.
exclude_pattern="$(printf '^%s/|' "${excludes[@]}" | sed 's/|$//')"
file_list="$(mktemp "${TMPDIR:-/tmp}/leftover-files.XXXXXX")"
trap 'rm -f "$file_list"' EXIT
if git -C "$root" rev-parse --show-toplevel >/dev/null 2>&1; then
  git -C "$root" ls-files -co --exclude-standard | grep -Ev "$exclude_pattern" | grep -Ev '\.(lock|map|min\.js|png|jpg|jpeg|gif|webp|mp4|mov|pdf|woff2?|ttf|otf)$' >"$file_list" || true
else
  (cd "$root" && find . -type f | sed 's#^\./##' | grep -Ev "$exclude_pattern") >"$file_list"
fi

total=0
while IFS= read -r name; do
  if is_frozen "$name"; then
    echo "frozen, not swept: $name"
    continue
  fi
  hits="$(cd "$root" && tr '\n' '\0' <"$file_list" | xargs -0 grep -nIF -- "$name" 2>/dev/null \
    | { if [[ -n "$frozen_file" ]]; then grep -v -F -f "$frozen_file"; else cat; fi; } || true)"
  if [[ -n "$hits" ]]; then
    count="$(printf '%s\n' "$hits" | wc -l | tr -d ' ')"
    total=$((total + count))
    echo "== $name ($count)"
    printf '%s\n' "$hits"
  else
    echo "== $name (0)"
  fi
done < <(read_list "$names_file")

echo "total hits: $total"
[[ $total -eq 0 ]]
