## MODIFIED Requirements

### Requirement: Section content
A section's content SHALL be every non-blank line after its heading up to the next `## ` heading or the end of the body, except skeleton lines. A line of only whitespace SHALL NOT count as content. A skeleton line is, after comments are stripped and surrounding whitespace is trimmed, one that is only an opening `<details>` tag, a closing `</details>` tag, the template's own `<summary>Full output</summary>` element (any other summary text is content, so a result written in the summary counts), a code fence marker (three backticks or tildes with an optional language word), or a bold label ending in a colon with nothing after it, such as `**Risk:**`. Skeleton lines SHALL NOT count as content. A section with no content SHALL be reported as `::error::'## <name>' is empty` and fail the check. Deeper headings such as `###` SHALL be content, not section boundaries.

#### Scenario: Whitespace-only section
- **WHEN** the Proof section holds only spaces
- **THEN** the script reports `'## Proof' is empty` and exits 1

#### Scenario: Sub-heading counts as content
- **WHEN** the Proof section holds a `### Run` heading and a line of output
- **THEN** the section is non-empty and the check passes

#### Scenario: Next heading ends the section
- **WHEN** the Proof heading is followed directly by `## Risk + rollback`
- **THEN** Proof is reported empty, and the Risk + rollback content is not credited to it

#### Scenario: Repeated heading
- **WHEN** a body has a filled `## Proof` and a later empty `## Proof`
- **THEN** the contents are combined and the check passes

#### Scenario: Skeleton-only Proof
- **WHEN** the Proof section holds only `<details>`, `<summary>Full output</summary>`, an empty code fence and `</details>`
- **THEN** the script reports `'## Proof' is empty` and exits 1

#### Scenario: Skeleton-only Risk and rollback
- **WHEN** the Risk + rollback section holds only `**Risk:**` and `**Rollback:**`
- **THEN** the script reports `'## Risk + rollback' is empty` and exits 1

#### Scenario: Filled details block
- **WHEN** the Proof section has a result line and a details block with output inside the fence
- **THEN** the check passes

#### Scenario: Label with text
- **WHEN** a Risk + rollback line is `**Risk:** low`
- **THEN** the line counts as content and the section passes

#### Scenario: Old-style plain text
- **WHEN** Proof and Risk + rollback hold plain sentences with no skeleton
- **THEN** the check passes
