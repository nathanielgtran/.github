## 1. Tests first
- [x] 1.1 Add cases to tests/test-check-pr-body.sh: skeleton-only Proof and Risk + rollback fail, filled details block passes, labels with text pass, old-style plain bodies pass

## 2. Checker
- [x] 2.1 Ignore skeleton-only lines in section content in scripts/check-pr-body.sh (bash 3.2 and BSD awk safe)

## 3. Template
- [x] 3.1 Rewrite PULL_REQUEST_TEMPLATE.md with the skeleton and one-line hints

## 4. Wrap-up
- [x] 4.1 CHANGELOG entry
- [x] 4.2 `openspec validate --all --strict` and `bash tests/test-check-pr-body.sh` print all passed
