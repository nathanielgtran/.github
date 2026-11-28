## Why

The fleet PR template reads as a wall of headings and raw log text. Proof sections end up as long pasted output and Risk + rollback as an unstructured sentence. The owner finds it visually ugly while liking the structure.

## What Changes

- Template keeps the five headings and adds a pre-filled skeleton: a summary line slot plus a folded `<details><summary>Full output</summary>` block with an empty fence under Proof, and `**Risk:**` / `**Rollback:**` labels under Risk + rollback. Hints become one-line comments.
- Checker treats skeleton-only lines as empty: after comments are stripped, a line that is only a `<details>` / `</details>` tag, the template's `<summary>Full output</summary>` line, an empty code fence line, or a bold label with nothing after it does not count as content.

Fleet-visible behaviour: the headings, required sections and exit codes are unchanged. Newly failing input (with the new checker): a section holding only skeleton lines. Newly passing: nothing that has text. Existing plain-text bodies pass as before; a body that previously passed only because of a bare label or lone fence line in a section now fails.

Pickup: callers pin the workflow by SHA, so they keep the old checker until the pin is bumped. With the old checker a skeleton-only `**Risk:**` section passes.

## Non-goals

- Changing heading names, required sections, or the Checklist items.
- Full Markdown parsing; only the five line shapes above are skeleton.
- Bumping fleet pins.

## Impact

- Specs: `pr-template`, `pr-body-check`.
- Code: `PULL_REQUEST_TEMPLATE.md`, `scripts/check-pr-body.sh`, `tests/test-check-pr-body.sh`, `CHANGELOG.md`.
