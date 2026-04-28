#!/usr/bin/env zsh
set -euo pipefail

script_dir="${0:A:h}"
repo_root="${script_dir:h:h}"
index_file="$repo_root/docs/context/index.yml"
max_lines="${CONTEXT_MAX_LINES_PER_FILE:-160}"
session_limit="${CONTEXT_SESSION_LIMIT:-3}"

print_file() {
  local title="$1"
  local rel_path="$2"
  local abs_path="$repo_root/$rel_path"

  if [[ ! -f "$abs_path" ]]; then
    printf '\n## %s\n\nMissing: %s\n' "$title" "$rel_path"
    return
  fi

  printf '\n## %s\n\n' "$title"
  sed -n "1,${max_lines}p" "$abs_path"

  local line_count
  line_count="$(wc -l < "$abs_path" | tr -d ' ')"
  if (( line_count > max_lines )); then
    printf '\n[truncated: showing %s of %s lines]\n' "$max_lines" "$line_count"
  fi
}

latest_session_paths() {
  awk '
    /^session_summaries:/ { in_sessions = 1; next }
    /^[A-Za-z_]+:/ {
      if (in_sessions) exit
    }
    in_sessions && /^[[:space:]]+path:[[:space:]]*/ {
      sub(/^[[:space:]]+path:[[:space:]]*/, "")
      gsub(/^"|"$/, "")
      print
    }
  ' "$index_file" | head -n "$session_limit"
}

printf '# Dikte Agent Startup Context\n'
printf '\nGenerated from committed repo context files.\n'

print_file "Current State" "docs/current-state.md"
print_file "Tasks" "docs/tasks.md"

session_count=0
while IFS= read -r session_path; do
  [[ -z "$session_path" ]] && continue
  session_count=$((session_count + 1))
  print_file "Recent Session $session_count" "$session_path"
done < <(latest_session_paths)

if (( session_count == 0 )); then
  printf '\n## Recent Sessions\n\nNo committed session summaries are listed yet.\n'
fi

print_file "Decisions" "docs/decisions.md"
print_file "Architecture" "docs/architecture.md"
