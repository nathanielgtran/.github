# pr-template Specification

## Purpose
The fleet pull request template that GitHub pre-fills on new PRs in every nathanielgtran repo without its own template. It fixes the section headings and hint text authors fill in, and is the reference the checker's required sections come from.

## Requirements

### Requirement: Template sections
The template SHALL contain, in this order, the level-2 headings `## What`, `## Why`, `## Proof`, `## Risk + rollback` and `## Checklist`.

#### Scenario: Author opens a PR in a repo with no template of its own
- **WHEN** a PR is opened in a fleet repo that has no PULL_REQUEST_TEMPLATE.md
- **THEN** GitHub pre-fills the body with the five headings in the order above

### Requirement: Hint text is HTML comments
Each of `What`, `Why`, `Proof` and `Risk + rollback` SHALL carry one hint line wrapped in an HTML comment, so the hint is invisible in rendered Markdown and ignored by the checker. The `Proof` hint SHALL state that proof is required and that "Tested locally" is not proof.

#### Scenario: Untouched template body
- **WHEN** a PR body is the template with no edits
- **THEN** every required section contains only an HTML comment, so the checker reports all four required sections as empty

### Requirement: Checklist items
The `Checklist` section SHALL contain two unchecked task items: `Tests added or updated` and `CHANGELOG / TODO / PLAN updated`.

#### Scenario: Checklist is advisory
- **WHEN** a PR body has all four required sections filled and its Checklist is missing or has unticked items
- **THEN** the checker still passes, because `Checklist` is not a required section
