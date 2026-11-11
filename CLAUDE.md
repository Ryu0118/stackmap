# stackmap

Swift package for `stackmap`, a CLI that renders a tech stack map from a YAML
file into one self-contained HTML page: a diagram of clients, services, and
stores grouped by provider, plus a list of where each piece of data lives.
Scopes let one file render the whole system or a single part of it.

## Commands

| Command | Purpose |
| --- | --- |
| `swift build` | Build the package. |
| `swift test` | Run the tests. |
| `swift run stackmap render Examples/stackmap.yml -o /tmp/stackmap.html` | Render the example. |
| `mise exec -- swiftformat --lint .` | Check formatting. |
| `mise exec -- swiftlint lint --strict` | Run SwiftLint. |
| `mise exec -- my-swift-linter lint` | Run the Swift AST lint rules. |
| `mise exec -- docsync check` | Check that docs match their sources. |

## Architecture

```text
Sources/stackmap/      executable entry point
Sources/StackmapCLI/   argument parsing and file I/O
Sources/StackmapKit/   model, loading, scope filtering, layout, HTML rendering
```

`AGENTS.md` is a symlink to this file. Update `CLAUDE.md`, never the symlink.

## Detailed coding rules

- [Architecture and testability](.agents/rules/architecture-and-testability.md) — module boundaries, output contract, tests.
- [Swift and documentation](.agents/rules/swift-and-documentation.md) — Swift access, source organization, comments.
- [Change management and validation](.agents/rules/change-management-and-validation.md) — commits, validation, Git safety.

## Releasing

Run the `Publish Release` workflow with a semver `version` input. It builds a
universal macOS binary, publishes the tarball and an artifact bundle to a
GitHub Release, and commits the bumped `Version.swift`.

When documentation and the existing code disagree, follow the conventions used
in the existing code, and in your final reply list every inconsistency you
found between the documentation and the code.
