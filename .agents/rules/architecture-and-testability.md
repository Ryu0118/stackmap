# Architecture and Testability

This rule covers module boundaries and how behavior is made testable.
Repository change procedure belongs in the change-management rule.

## Module boundaries

- `stackmap` is the executable. It only calls `StackmapCommand.main()`.
- `StackmapCLI` owns argument parsing, file reading and writing, and exit
  status. It must not contain loading, scope, layout, or HTML logic.
- `StackmapKit` owns the document model, loading and validation, scope
  filtering, diagram layout, and HTML rendering. It must not parse `argv`,
  print, or touch the file system except through an explicit URL a caller
  passes in.
- Keep dependencies one-directional: `stackmap -> StackmapCLI -> StackmapKit`.
- Keep loading, scope filtering, layout, and rendering as separate types.
  Layout returns pure geometry; the renderer turns geometry into HTML and
  never decides positions.

## Output contract

- The rendered HTML is a single self-contained file: no network requests,
  no external fonts, scripts, or stylesheets.
- The same input must produce byte-identical output. Do not embed
  timestamps, absolute paths, or other environment-dependent values.
- Escape every user-provided string before it reaches HTML.
- Do not use SwiftPM resources. Release archives ship only the binary, so
  templates live in Swift source.

## Testability

- Use Swift Testing.
- Test layout through invariants (no overlapping cards, connectors that end
  at card edges, no connector through a card) rather than snapshot files.
- Unit tests must not require network access.
- Do not extract an abstraction from code that only looks similar; require
  shared behavior, guards, and result semantics.
