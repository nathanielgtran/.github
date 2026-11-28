# pr-body-check Specification

## Purpose
`scripts/check-pr-body.sh` decides whether a PR body honours the fleet template: every required section must be present and hold real content. It is the single implementation behind the `pr-template` check in the fleet repos.

## Requirements

### Requirement: Input and exit status
The script SHALL read the PR body from the file named by its first argument, or from stdin when no argument is given. It SHALL exit 0 and print `PR body passes the template check` when every required section is present and non-empty, and SHALL exit 1 otherwise. A body file that cannot be read SHALL make it exit non-zero without printing a pass message.

#### Scenario: Body supplied on stdin
- **WHEN** a body with all four required sections filled is piped to the script
- **THEN** it prints `PR body passes the template check` and exits 0

#### Scenario: Body supplied as a file
- **WHEN** the script is given the path of a file holding a body with all four required sections filled
- **THEN** it prints `PR body passes the template check` and exits 0

#### Scenario: Body file does not exist
- **WHEN** the script is given a path that does not exist
- **THEN** it exits non-zero and does not print the pass message

### Requirement: Required sections
The script SHALL require the sections `What`, `Why`, `Proof` and `Risk + rollback`. `Checklist` and any other section SHALL NOT be required.

#### Scenario: Missing section
- **WHEN** a body has no `## Proof` section
- **THEN** the script prints `::error::PR body is missing the '## Proof' section` and exits 1

#### Scenario: Empty body
- **WHEN** the body is empty
- **THEN** the script reports all four sections as missing, ends with `PR body fails the template check (4 problem(s)).` and a link to the template, and exits 1

#### Scenario: Checklist omitted
- **WHEN** a body has the four required sections filled and no `## Checklist`
- **THEN** the script exits 0

#### Scenario: Every problem is reported
- **WHEN** a body has one required section missing and another empty
- **THEN** the script prints one `::error::` line for each and the failure summary counts both

### Requirement: Heading matching
A section heading SHALL be a line that starts with `##` followed by whitespace, and the heading text, after trailing whitespace is trimmed, SHALL equal the required name compared case-insensitively. Headings at other levels, headings without a space after `##`, indented headings and headings with extra words SHALL NOT match.

#### Scenario: Case-insensitive heading
- **WHEN** a body uses `## proof` instead of `## Proof`
- **THEN** the section is found and judged on its content

#### Scenario: Trailing whitespace on a heading
- **WHEN** a body uses `## Proof` followed by trailing spaces
- **THEN** the section is found

#### Scenario: Wrong heading level
- **WHEN** a body uses `### Proof` instead of `## Proof`
- **THEN** the script reports the Proof section as missing

#### Scenario: Heading with extra words
- **WHEN** a body uses `## Proof of work`
- **THEN** the script reports the Proof section as missing

#### Scenario: Heading without a space
- **WHEN** a body uses `##Proof`
- **THEN** the script reports the Proof section as missing

#### Scenario: Indented heading
- **WHEN** a body indents `## Proof` by a space
- **THEN** the script reports the Proof section as missing

### Requirement: Section content
A section's content SHALL be every non-blank line after its heading up to the next `## ` heading or the end of the body. A line of only whitespace SHALL NOT count as content. A section with no content SHALL be reported as `::error::'## <name>' is empty` and fail the check. Deeper headings such as `###` SHALL be content, not section boundaries.

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

### Requirement: HTML comments are not content
Before sections are located, the script SHALL strip HTML comments, including comments spanning several lines. Text outside a comment on the same line SHALL still count as content. A heading inside a comment SHALL NOT be a heading. An unterminated `<!--` SHALL hide the rest of the body.

#### Scenario: Template hint only
- **WHEN** the Proof section holds only the template's HTML comment hint
- **THEN** the script reports `'## Proof' is empty`

#### Scenario: Multi-line comment only
- **WHEN** the Proof section holds only a comment spanning several lines
- **THEN** the script reports `'## Proof' is empty`

#### Scenario: Text after an inline comment
- **WHEN** a Proof line is `<!-- hint --> pytest: 12 passed`
- **THEN** the line counts as content and the section passes

#### Scenario: Heading inside a comment
- **WHEN** the only `## Proof` heading in the body sits inside an HTML comment
- **THEN** the script reports the Proof section as missing

#### Scenario: Unterminated comment
- **WHEN** a body contains `<!--` with no closing `-->` inside the Proof section
- **THEN** everything after the opening is dropped, so the Proof section is empty and later sections are reported missing

### Requirement: Line endings
The script SHALL treat CRLF line endings the same as LF.

#### Scenario: CRLF body
- **WHEN** a filled body uses CRLF line endings
- **THEN** the script exits 0

### Requirement: Untouched template fails
A body identical to `PULL_REQUEST_TEMPLATE.md` SHALL fail the check.

#### Scenario: Author submits the template unedited
- **WHEN** the PR body is the unedited template
- **THEN** the script exits 1 with an empty-section error for each required section
