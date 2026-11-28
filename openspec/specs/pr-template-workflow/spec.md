# pr-template-workflow Specification

## Purpose
The reusable GitHub Actions workflow `.github/workflows/pr-template-check.yml` that fleet repos call to run the checker against a PR's body, and the repo's own CI that tests the checker and applies the check to this repo's PRs.

## Requirements

### Requirement: Reusable workflow interface
The workflow SHALL be callable through `workflow_call` with two optional string inputs: `ref`, the `nathanielgtran/.github` ref the checker is loaded from, defaulting to `main`; and `runs_on`, a JSON runner label or list of labels, defaulting to `["self-hosted", "nuc"]`. It SHALL request only `contents: read`.

#### Scenario: Fleet caller with defaults
- **WHEN** a fleet repo calls the workflow without `runs_on`
- **THEN** the job runs on a runner labelled `self-hosted` and `nuc`

#### Scenario: Caller overrides the runner
- **WHEN** a caller passes `runs_on: '"ubuntu-latest"'`
- **THEN** the job runs on `ubuntu-latest`

#### Scenario: Caller pins the checker
- **WHEN** a caller passes `ref` as a commit SHA
- **THEN** the checker script is checked out from `nathanielgtran/.github` at that SHA, not from `main`

### Requirement: Checks the PR body
The job SHALL check out `nathanielgtran/.github` at `ref` into `.pr-template-check` without persisting credentials, pass the PR body to `scripts/check-pr-body.sh` on stdin through an environment variable, and fail when the script exits non-zero. It SHALL time out after 2 minutes.

#### Scenario: Body satisfies the template
- **WHEN** a human opens a PR whose body has all four required sections filled
- **THEN** the job succeeds

#### Scenario: Body skips a section
- **WHEN** a human opens a PR whose body leaves `## Proof` empty
- **THEN** the job fails with the checker's `::error::` annotation

#### Scenario: Body is edited
- **WHEN** a caller triggers on `edited` and the author fixes the body
- **THEN** the job runs again against the new body

### Requirement: Bot PRs skipped
The job SHALL NOT run when the PR author's user type is `Bot`.

#### Scenario: Dependabot PR
- **WHEN** Dependabot opens a PR
- **THEN** the check job is skipped and does not fail the PR

### Requirement: Repo CI
`.github/workflows/ci.yml` SHALL, on pull requests (opened, edited, reopened, synchronize) and pushes to `main`, run `bash tests/test-check-pr-body.sh` on `ubuntu-latest`. On pull requests it SHALL also call the reusable workflow from the local path with `ref` set to the PR head SHA and `runs_on` set to `"ubuntu-latest"`, so this repo's own PRs are held to the template using the checker as changed in the PR.

#### Scenario: Checker change is tested
- **WHEN** a PR changes `scripts/check-pr-body.sh`
- **THEN** CI runs the checker tests and the template check, which loads the PR's version of the script

#### Scenario: Public repo never uses the NUC
- **WHEN** CI runs for a PR from a fork
- **THEN** both jobs run on GitHub-hosted `ubuntu-latest`
