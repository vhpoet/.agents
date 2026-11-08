#!/usr/bin/env bash
# Computes the assess-pass verdict block from the assessment files, so the headline is a
# function of the scorecards and not of the conductor's mood.
#
#   assess-verdict.sh <assess-dir> [<feature name>]
#
# Reads PRODUCT_ASSESSMENT.md and ARCHITECTURE_ASSESSMENT.md (whichever exist) in the
# directory. From each: the `Concepts: <n>` line, the Severity column of the scorecard
# table, the `## Fails` bullet lines and the `## Cuts` numbered lines.
#
# Headline rule: `reset warranted on <forces>` when any scorecard row is `structural`;
# otherwise `simplify: <N> cuts` when any cut is listed; otherwise `keep as is`.
# Prints the verdict block ready for the board thread. Exit 1 when no assessment is found.
set -euo pipefail

[[ $# -ge 1 && -d "$1" ]] || { echo "Usage: $0 <assess-dir> [<feature name>]" >&2; exit 2; }
dir="$1"
feature="${2:-$(basename "$dir")}"

product="$dir/PRODUCT_ASSESSMENT.md"
architecture="$dir/ARCHITECTURE_ASSESSMENT.md"
[[ -f "$product" || -f "$architecture" ]] || { echo "No *_ASSESSMENT.md in $dir" >&2; exit 1; }

# Rows of a scorecard table whose last cell is `structural`; prints the Force cell.
structural_forces() {
  awk -F'|' '
    /^\|/ && NF >= 6 {
      sev = $(NF-1); gsub(/^[[:space:]`]+|[[:space:]`]+$/, "", sev)
      force = $2; gsub(/^[[:space:]*]+|[[:space:]*]+$/, "", force)
      if (tolower(sev) == "structural" && force != "Force") print force
    }' "$1"
}

section_lines() {
  # Lines of the section whose heading contains $2 (case-insensitive), until the next heading.
  awk -v want="$(printf '%s' "$2" | tr '[:upper:]' '[:lower:]')" '
    /^#/ { on = (index(tolower($0), want) > 0); next }
    on { print }' "$1"
}

concepts_line() { grep -m1 -E '^\**Concepts:\**' "$1" | sed -E 's/^\**Concepts:\**[[:space:]]*//' || true; }

forces=()
fails=()
cuts=()
concept_parts=()
for file in "$product" "$architecture"; do
  [[ -f "$file" ]] || continue
  label="user"; [[ "$file" == "$architecture" ]] && label="maintainer"
  c="$(concepts_line "$file")"
  [[ -n "$c" ]] && concept_parts+=("$c a $label must learn")
  while IFS= read -r f; do [[ -n "$f" ]] && forces+=("$f"); done < <(structural_forces "$file")
  while IFS= read -r l; do [[ -n "$l" ]] && fails+=("$l"); done < <(section_lines "$file" "fails" | grep -E '^[-*] ' | sed -E 's/^[-*] //')
  while IFS= read -r l; do [[ -n "$l" ]] && cuts+=("$l"); done < <(section_lines "$file" "cuts" | grep -E '^[0-9]+\. ' | sed -E 's/^[0-9]+\. //')
done

if [[ ${#forces[@]} -gt 0 ]]; then
  unique="$(printf '%s\n' "${forces[@]}" | awk '!seen[$0]++' | paste -sd ',' - | sed 's/,/, /g')"
  headline="reset warranted on $unique"
elif [[ ${#cuts[@]} -gt 0 ]]; then
  headline="simplify: ${#cuts[@]} concrete cuts"
else
  headline="keep as is"
fi

echo "$feature: $headline"
if [[ ${#concept_parts[@]} -gt 0 ]]; then
  echo "Concepts: $(printf '%s\n' "${concept_parts[@]}" | paste -sd ',' - | sed 's/,/, /g')"
fi
n=0
for f in ${fails[@]+"${fails[@]}"}; do
  n=$((n + 1)); [[ $n -gt 5 ]] && break
  echo "Fails: $f"
done
if [[ ${#cuts[@]} -gt 0 ]]; then
  echo "Cuts, by what they remove:"
  i=0
  for c in "${cuts[@]}"; do i=$((i + 1)); echo "  $i. $c"; done
fi
