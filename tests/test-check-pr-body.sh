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
  "$(printf '%s\n' "$FILLED" | sed 's|^!\[screenshot\].*|@@C@@|' | awk '/^@@C@@$/ { print "<!--"; print "later"; print "-->"; next } { print }')"
expect "heading case-insensitive passes" 0 \
  "$(printf '%s\n' "$FILLED" | sed 's/^## Proof/## proof/')"
expect "text after inline comment counts" 0 \
  "$(printf '%s\n' "$FILLED" | sed 's|^!\[screenshot\].*|<!-- hint --> pytest: 12 passed|')"

SKEL_PROOF='<details>
<summary>Full output</summary>

```

```

</details>'
SKEL_RISK='**Risk:**
**Rollback:**'
with_proof() { printf '%s\n' "$FILLED" | R="$1" awk '/^!\[screenshot\]/ { print ENVIRON["R"]; next } { print }'; }
with_risk() { printf '%s\n' "$FILLED" | R="$1" awk '/^Low\. Revert/ { print ENVIRON["R"]; next } { print }'; }
crlf() { while IFS= read -r l || [ -n "$l" ]; do printf '%s\r\n' "$l"; done; }

expect "skeleton-only Proof fails" 1 "$(with_proof "$SKEL_PROOF")"
expect "skeleton-only Risk + rollback fails" 1 "$(with_risk "$SKEL_RISK")"
expect "skeleton with comment hints only fails" 1 "$(with_proof "<!-- hint -->
$SKEL_PROOF")"
expect "CRLF skeleton-only Proof fails" 1 "$(with_proof "$SKEL_PROOF" | crlf)"
expect "filled details block passes" 0 "$(with_proof '87 ok, 0 FAIL

<details>
<summary>Full output</summary>

```
ok - a
ok - b
```

</details>')"
expect "result written in the summary passes" 0 "$(with_proof '<details>
<summary>87 ok, 0 FAIL</summary>

```
```

</details>')"
expect "text after the summary tag passes" 0 "$(with_proof '<details>
<summary>Full output</summary> 12 passed
</details>')"
expect "tilde fence skeleton fails" 1 "$(with_proof '<details>
<summary>Full output</summary>
~~~
~~~
</details>')"
expect "details open skeleton fails" 1 "$(with_proof '<details open>
<summary>Full output</summary>
```
```
</details>')"
expect "summary line plus empty skeleton passes" 0 "$(with_proof "87 ok, 0 FAIL
$SKEL_PROOF")"
expect "labels with text pass" 0 "$(with_risk '**Risk:** low, docs only.
**Rollback:** revert the PR.')"
expect "one label with text passes" 0 "$(with_risk '**Risk:**
**Rollback:** revert the PR.')"
expect "plain text Proof (old style) passes" 0 "$(with_proof 'pytest: 12 passed')"
expect "plain text Risk (old style) passes" 0 "$(with_risk 'Low. Revert the PR.')"
expect "new-shape template filled passes" 0 "$(cat PULL_REQUEST_TEMPLATE.md | sed \
  -e 's|^<!-- One line: what changed. -->|Add login page.|' \
  -e 's|^<!-- Ticket.*-->|[ABC-1] users cannot sign in.|' \
  -e 's|^<!-- Required\. One line.*-->|87 ok, 0 FAIL|' \
  -e 's|^\*\*Risk:\*\*.*|**Risk:** low.|')"

[ "$failures" -eq 0 ] && echo "all passed" || { echo "$failures failed"; exit 1; }
