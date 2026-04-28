#!/usr/bin/env zsh
set -euo pipefail

script_dir="${0:A:h}"
repo_root="${script_dir:h:h}"
index_file="$repo_root/docs/context/index.yml"
failures=0

error() {
  printf 'context-check: ERROR: %s\n' "$1" >&2
  failures=$((failures + 1))
}

required_files=(
  "docs/architecture.md"
  "docs/decisions.md"
  "docs/current-state.md"
  "docs/tasks.md"
  "docs/context/index.yml"
  "scripts/context/load.sh"
  "scripts/context/save-session.sh"
  "scripts/context/check.sh"
)

for rel_path in "${required_files[@]}"; do
  [[ -f "$repo_root/$rel_path" ]] || error "missing required file: $rel_path"
done

if [[ -f "$index_file" ]]; then
  while IFS= read -r rel_path; do
    [[ -z "$rel_path" ]] && continue
    [[ -e "$repo_root/$rel_path" ]] || error "index path does not resolve: $rel_path"
  done < <(
    awk '
      /^[[:space:]]+-[[:space:]]+docs\// {
        sub(/^[[:space:]]+-[[:space:]]+/, "")
        gsub(/^"|"$/, "")
        print
      }
      /^[[:space:]]+path:[[:space:]]+docs\// {
        sub(/^[[:space:]]+path:[[:space:]]+/, "")
        gsub(/^"|"$/, "")
        print
      }
    ' "$index_file" | sort -u
  )

  duplicate_ids="$(
    awk '
      /^session_summaries:/ { in_sessions = 1; next }
      /^[A-Za-z_]+:/ {
        if (in_sessions) exit
      }
      in_sessions && /^[[:space:]]+- id:[[:space:]]*/ {
        sub(/^[[:space:]]+- id:[[:space:]]*/, "")
        gsub(/^"|"$/, "")
        print
      }
    ' "$index_file" | sort | uniq -d
  )"
  [[ -z "$duplicate_ids" ]] || error "duplicate session ids: $duplicate_ids"
fi

private_pattern='(<private|BEGIN (RSA |OPENSSH |DSA |EC |PGP )?PRIVATE KEY|API[_-]?KEY=|TOKEN=|SECRET=|PASSWORD=|password:)'
if command -v rg >/dev/null 2>&1; then
  if rg -n -i "$private_pattern" "$repo_root/docs" >/tmp/dikte-context-private-matches.$$ 2>/dev/null; then
    cat /tmp/dikte-context-private-matches.$$ >&2
    error "possible private marker found in docs"
  fi
  rm -f /tmp/dikte-context-private-matches.$$
else
  if grep -R -n -E -i "$private_pattern" "$repo_root/docs" >/tmp/dikte-context-private-matches.$$ 2>/dev/null; then
    cat /tmp/dikte-context-private-matches.$$ >&2
    error "possible private marker found in docs"
  fi
  rm -f /tmp/dikte-context-private-matches.$$
fi

if (( failures > 0 )); then
  exit 1
fi

printf 'context-check: OK\n'
