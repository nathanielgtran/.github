## MODIFIED Requirements

### Requirement: Hint text is HTML comments
Each of `What`, `Why`, `Proof` and `Risk + rollback` SHALL carry one short hint line wrapped in an HTML comment, so the hint is invisible in rendered Markdown and ignored by the checker. The `Proof` hint SHALL state that proof is required and that "Tested locally" is not proof.

#### Scenario: Untouched template body
- **WHEN** a PR body is the template with no edits
- **THEN** every required section contains only comments and skeleton lines, so the checker reports all four required sections as empty

## ADDED Requirements

### Requirement: Pre-filled skeleton
Under `Proof` the template SHALL pre-fill a `<details>` block with `<summary>Full output</summary>` and an empty code fence, for the long output. Under `Risk + rollback` it SHALL pre-fill the bold labels `**Risk:**` and `**Rollback:**`, each on its own line. `What` and `Why` SHALL carry only their hint.

#### Scenario: Author opens a PR
- **WHEN** GitHub pre-fills the body from the template
- **THEN** Proof offers a folded output block and Risk + rollback offers the two labels, and the checker still fails the untouched body
