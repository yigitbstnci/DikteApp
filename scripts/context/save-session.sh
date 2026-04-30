#!/usr/bin/env zsh
set -euo pipefail

script_dir="${0:A:h}"
repo_root="${script_dir:h:h}"
index_file="$repo_root/docs/context/index.yml"
sessions_dir="$repo_root/docs/context/sessions"

summary="${SUMMARY:-${1:-}}"
title="${TITLE:-}"
date_value="${DATE:-$(date +%F)}"

if [[ -z "$summary" ]]; then
  printf 'usage: SUMMARY=/path/to/session.md TITLE="short-title" scripts/context/save-session.sh\n' >&2
  exit 2
fi

if [[ ! -f "$summary" ]]; then
  printf 'save-session: summary file not found: %s\n' "$summary" >&2
  exit 2
fi

if [[ ! -s "$summary" ]]; then
  printf 'save-session: summary file is empty: %s\n' "$summary" >&2
  exit 2
fi

private_pattern='(<private|BEGIN (RSA |OPENSSH |DSA |EC |PGP )?PRIVATE KEY|API[_-]?KEY=|TOKEN=|SECRET=|PASSWORD=|password:)'
if grep -E -i "$private_pattern" "$summary" >/dev/null 2>&1; then
  printf 'save-session: possible private marker found in summary; refusing to save\n' >&2
  exit 2
fi

raw_log_line_count="$(
  awk '
    /^[0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{3}[[:space:]]+(ACT|INF|WRN|ERR)[[:space:]]+[[:alnum:]_.-]+\.[[:alnum:]_.-]+/ { count++ }
    /^[0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{3}[[:space:]]+(--|!!)[[:space:]]+(ACTION|INFO|WARNING|ERROR)/ { count++ }
    /^[0-9]{4}-[0-9]{2}-[0-9]{2}[[:space:]][0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{3}[[:space:]]+(--|!!)[[:space:]]+(ACTION|INFO|WARNING|ERROR)/ { count++ }
    END { print count + 0 }
  ' "$summary"
)"
if (( raw_log_line_count >= 5 )); then
  printf 'save-session: possible raw Dikte runtime log dump found; save a concise summary instead\n' >&2
  exit 2
fi

if [[ -z "$title" ]]; then
  title="$(
    awk '/^#[[:space:]]+/ {
      sub(/^#[[:space:]]+/, "")
      print
      exit
    }' "$summary"
  )"
fi

if [[ -z "$title" ]]; then
  title="${summary:t:r}"
fi

title="$(printf '%s' "$title" | tr '\n' ' ' | sed -E 's/[[:space:]]+/ /g; s/^ //; s/ $//')"
slug="$(
  printf '%s' "$title" |
    tr '[:upper:]' '[:lower:]' |
    sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//; s/-+/-/g'
)"
[[ -n "$slug" ]] || slug="session"

session_id="${date_value}-${slug}"
dest_rel="docs/context/sessions/${session_id}.md"
dest="$repo_root/$dest_rel"

mkdir -p "$sessions_dir"

if [[ -e "$dest" && "${FORCE:-0}" != "1" ]]; then
  printf 'save-session: destination already exists: %s\n' "$dest_rel" >&2
  printf 'save-session: set FORCE=1 to overwrite the summary file\n' >&2
  exit 2
fi

cp "$summary" "$dest"

if grep -q "^[[:space:]]+- id:[[:space:]]*${session_id}$" "$index_file"; then
  printf 'save-session: session already listed in index: %s\n' "$session_id"
  exit 0
fi

escaped_title="$(printf '%s' "$title" | sed 's/"/\\"/g')"
tmp_index="$(mktemp "${TMPDIR:-/tmp}/dikte-context-index.XXXXXX")"

awk -v date_value="$date_value" \
    -v session_id="$session_id" \
    -v title="$escaped_title" \
    -v dest_rel="$dest_rel" '
  BEGIN { inserted = 0 }
  /^updated_at:/ {
    print "updated_at: \"" date_value "\""
    next
  }
  /^session_summaries:[[:space:]]*$/ {
    print
    print "  - id: " session_id
    print "    date: \"" date_value "\""
    print "    title: \"" title "\""
    print "    path: " dest_rel
    print "    status: active"
    inserted = 1
    next
  }
  { print }
  END {
    if (!inserted) {
      print "session_summaries:"
      print "  - id: " session_id
      print "    date: \"" date_value "\""
      print "    title: \"" title "\""
      print "    path: " dest_rel
      print "    status: active"
    }
  }
' "$index_file" > "$tmp_index"

mv "$tmp_index" "$index_file"
printf 'save-session: saved %s\n' "$dest_rel"
