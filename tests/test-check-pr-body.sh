#!/bin/bash
# Tests for scripts/check-pr-body.sh. Run: bash tests/test-check-pr-body.sh
set -uo pipefail

cd "$(dirname "$0")/.."
CHECK=scripts/check-pr-body.sh
failures=0

expect() {
  local name="$1" want="$2" body="$3"
  local got=0
  printf '%s' "$body" | bash "$CHECK" >/dev/null 2>&1 || got=$?
  [ "$got" -ne 0 ] && got=1
  if [ "$got" -eq "$want" ]; then
    echo "ok   - $name"
  else
    echo "FAIL - $name (want exit $want, got $got)"
    failures=$((failures + 1))
  fi
}

FILLED='## What
Add login page.

## Why
[ABC-1] users cannot sign in.

## Proof
![screenshot](https://example.com/a.png)

## Risk + rollback
Low. Revert the PR.

## Checklist
- [x] Tests added or updated'

expect "filled template passes" 0 "$FILLED"
expect "untouched template fails" 1 "$(cat PULL_REQUEST_TEMPLATE.md)"
expect "empty body fails" 1 ""
expect "missing Proof fails" 1 "$(printf '%s\n' "$FILLED" | sed '/^## Proof/,/^$/d')"
expect "Proof with only a comment fails" 1 \
  "$(printf '%s\n' "$FILLED" | sed 's|^!\[screenshot\].*|<!-- todo -->|')"
expect "multi-line comment in Proof fails" 1 \
  "$(printf '%s\n' "$FILLED" | sed 's|^!\[screenshot\].*|<!--\nlater\n-->|')"
expect "heading case-insensitive passes" 0 \
  "$(printf '%s\n' "$FILLED" | sed 's/^## Proof/## proof/')"
expect "text after inline comment counts" 0 \
  "$(printf '%s\n' "$FILLED" | sed 's|^!\[screenshot\].*|<!-- hint --> pytest: 12 passed|')"

[ "$failures" -eq 0 ] && echo "all passed" || { echo "$failures failed"; exit 1; }
