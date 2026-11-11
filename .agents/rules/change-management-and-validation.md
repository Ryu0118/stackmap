# Change Management and Validation

This rule covers repository changes, commit hygiene, and validation. Runtime
design and source documentation belong in the other two rules.

## Commits and communication

- Keep each commit focused on one concern and write commit messages in English.
- Write pull-request titles/bodies, issue comments, and review comments in English.
- For a pure directory or file move, use `git mv` in a behavior-neutral commit before editing contents.
- Never add `Codex-Session:` or `Claude-Session:` URLs, or other agent session links, to commits or pull requests.
- Write tests for a logic change from the specification before the
  implementation, and commit them separately.

## Validation and safety

- After every content-changing commit, run the narrowest relevant validation: `swift build`, `swift test`, `mise exec -- swiftformat --lint .`, `mise exec -- swiftlint lint --strict`, and `mise exec -- my-swift-linter lint`.
- If `docsync.yml` tracks a changed file, run `mise exec -- docsync check` and update its checksum before committing.
- Use `rg`, `rg --files`, and scoped `ls`; never use a broad `find` over a home directory or workspace parent.
- Do not perform destructive Git operations (`checkout`, `reset --hard`, `clean -f`, or broad deletion) without explicit user approval.

## Reporting results

Do not present partial progress as completion. Separate what was verified
from what is assumed, and state what would be needed to finish.
