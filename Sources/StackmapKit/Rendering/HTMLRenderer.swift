/// Renders a document as one self-contained HTML page.
///
/// The page contract, which tests and downstream tooling rely on:
///
/// - The page needs no network: no external scripts, stylesheets, fonts, or
///   images. Styles and the small tab script are inline.
/// - The same input always produces byte-identical output.
/// - Every string from the document is HTML-escaped.
/// - For ``ScopeSelection/all``, the page has a `<section data-scope="all">`
///   and one `<section data-scope="ID">` per declared scope, with a
///   `<button data-tab="ID">` (and `data-tab="all"`) to switch between them.
///   A document without scopes has only the `all` section and no tab buttons.
/// - For ``ScopeSelection/scope(_:)``, the page has exactly one section for
///   that scope and no tab buttons.
/// - Inside a section, each diagram card carries `data-node="KIND:ID"`
///   (``NodeKind`` raw value and node id) and each list row carries
///   `data-row="DATA_ID"`.
package struct HTMLRenderer: Sendable {
    /// Creates a renderer.
    package init() {}

    /// Renders `selection` of `document`.
    package func render(_: StackmapDocument, selection _: ScopeSelection) throws(ScopeFilterError) -> String {
        fatalError("Not implemented")
    }
}
