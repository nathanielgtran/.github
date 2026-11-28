# .github

Default community health files for every `nathanielgtran` repo that doesn't define its own.

- `PULL_REQUEST_TEMPLATE.md`: fleet PR template (What / Why / Proof / Risk + rollback / Checklist). GitHub pre-fills it on new PRs.
- `.github/workflows/pr-template-check.yml`: reusable workflow that fails a PR whose body is missing a section or leaves one empty. Bot PRs are skipped.
- `scripts/check-pr-body.sh`: the checker. Tests: `bash tests/test-check-pr-body.sh`.
- `openspec/`: behaviour specs for the template, the checker and the workflow. Changes go in `openspec/changes/<id>/`; see `CLAUDE.md`.

## Enforce in a repo

Add `.github/workflows/pr-template.yml`:

```yaml
name: PR template
on:
  pull_request:
    types: [opened, edited, reopened, synchronize]
jobs:
  pr-template:
    uses: nathanielgtran/.github/.github/workflows/pr-template-check.yml@<sha>
    with:
      ref: <same sha>
```

Then make `pr-template / check` a required status check if the repo uses branch protection.
