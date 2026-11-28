# .github (dotgithub)

Fleet PR template (`PULL_REQUEST_TEMPLATE.md`) and the reusable `pr-template` check (`scripts/check-pr-body.sh`, `.github/workflows/pr-template-check.yml`). Public repo; ~23 fleet repos pin the workflow by SHA.

- Tests: `bash tests/test-check-pr-body.sh` (must print `all passed`).
- Template headings and the checker's pass/fail semantics are a fleet-wide contract. Add the failing test case first.
- Workflow runs on `ubuntu-latest` here because the repo is public; fleet callers default to the NUC.

## OpenSpec

- `openspec/specs/<capability>/spec.md` is the source of truth for what the code does today (3 capabilities: `pr-template`, `pr-body-check`, `pr-template-workflow`). Read the relevant spec before changing behaviour; if code and spec disagree, treat it as a bug in one of them and say which.
- Non-trivial changes start as `openspec/changes/<id>/` (proposal.md, delta specs, tasks.md, design.md when warranted) before code. Run `openspec validate <id> --strict` before writing code.
- Never hand-edit `openspec/specs/` outside a change.
- Run `openspec validate --all --strict` before opening a PR that touches `openspec/`.
- Project context and per-artifact rules live in `openspec/config.yaml`.
