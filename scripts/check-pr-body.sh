#!/bin/bash
# Fail if a PR body is missing a required template section or leaves it empty.
# Usage: check-pr-body.sh <body-file>   (or body on stdin)
# HTML comments (the template's hints) don't count as content.
set -euo pipefail

REQUIRED=("What" "Why" "Proof" "Risk + rollback")

body=$(cat "${1:-/dev/stdin}")

# Strip HTML comments, including multi-line ones.
stripped=$(printf '%s\n' "$body" | awk '
  {
    line = $0
    out = ""
    while (length(line) > 0) {
      if (in_comment) {
        end = index(line, "-->")
        if (end == 0) { line = ""; break }
        line = substr(line, end + 3)
        in_comment = 0
      } else {
        start = index(line, "<!--")
        if (start == 0) { out = out line; line = ""; break }
        out = out substr(line, 1, start - 1)
        line = substr(line, start + 4)
        in_comment = 1
      }
    }
    print out
  }')

# Print the non-blank content under "## <heading>" up to the next "## ".
section_content() {
  printf '%s\n' "$stripped" | awk -v want="$1" '
    /^##[[:space:]]/ {
      h = $0
      sub(/^##[[:space:]]+/, "", h)
      sub(/[[:space:]]+$/, "", h)
      in_sec = (tolower(h) == tolower(want))
      found = found || in_sec
      next
    }
    in_sec && $0 ~ /[^[:space:]]/ { print }
    END { if (!found) exit 2 }'
}

errors=0
for heading in "${REQUIRED[@]}"; do
  status=0
  content=$(section_content "$heading") || status=$?
  if [ "$status" -eq 2 ]; then
    echo "::error::PR body is missing the '## ${heading}' section"
    errors=$((errors + 1))
  elif [ -z "$content" ]; then
    echo "::error::'## ${heading}' is empty"
    errors=$((errors + 1))
  fi
done

if [ "$errors" -gt 0 ]; then
  echo "PR body fails the template check (${errors} problem(s)). Template: https://github.com/nathanielgtran/.github/blob/main/PULL_REQUEST_TEMPLATE.md"
  exit 1
fi
echo "PR body passes the template check"
