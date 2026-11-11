# Swift and Documentation

This rule covers source organization, API boundaries, and engineering prose.

## Swift boundaries

- Use Swift 6 strict concurrency and mark values crossing async boundaries `Sendable`.
- Use `private` by default and `package` for APIs shared between modules of this package. There is no `public` library surface.
- Keep one concern per file; do not create a directory for a lone file.
- Within a function, separate setup, transformation, side effects, and result handling into readable blocks.
- Treat SwiftFormat, SwiftLint, and my-swift-linter configuration as the source of truth; do not silence warnings.
- Keep `single-large-type-per-file` at 30 lines and `missing-docs` at the `package` boundary.

## Type selection

- Use an `enum` as a namespace only for stateless, pure helpers or constants.
- Use a `struct` when several operations share immutable configuration.
- Keep finite outcomes, kinds, and error classifications as enums.

## Comments and documentation

Comments are optional. Add one only when a future reader could misread the
intent or make the wrong change from the code alone.

- Use `//` for a local, non-obvious reason or invariant.
- Use `///` for a non-obvious package API contract.
- Keep the configuration schema in `Sources/StackmapKit/StackmapKit.docc/ConfigurationFile.md` and the README in sync; `docsync.yml` enforces it.

All source comments, documentation, identifiers, test names, and diagnostic
messages are English.
