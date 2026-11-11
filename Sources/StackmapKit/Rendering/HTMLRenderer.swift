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
    package func render(_ document: StackmapDocument, selection: ScopeSelection) throws(ScopeFilterError) -> String {
        let filter = ScopeFilter()
        let selections: [ScopeSelection] = switch selection {
        case .all: [.all] + document.scopes.map { .scope($0.id) }
        case .scope: [selection]
        }
        let views = try selections.map { selection throws(ScopeFilterError) in
            try filter.filter(document, selection: selection)
        }

        let context = RenderContext(document)
        let showsTabs = selection == .all && !document.scopes.isEmpty
        let sections = views.enumerated().map { index, view in
            SectionRenderer(context: context, view: view).render(hidden: showsTabs && index > 0)
        }
        return PageTemplate.page(
            title: document.title.htmlEscaped,
            subtitle: subtitle(for: selection, context: context),
            tabs: showsTabs ? tabs(views, context: context) : "",
            sections: sections.joined(separator: "\n"),
            script: showsTabs ? PageTemplate.tabScript : ""
        )
    }

    private func subtitle(for selection: ScopeSelection, context: RenderContext) -> String {
        switch selection {
        case .all: ""
        case let .scope(id): "<p class=\"subtitle\">Scope: \(context.scopeLabel(id).htmlEscaped)</p>"
        }
    }

    private func tabs(_ views: [ScopedDocument], context: RenderContext) -> String {
        let buttons = views.enumerated().map { index, view in
            let (id, label) = switch view.selection {
            case .all: ("all", "All")
            case let .scope(scope): (scope, context.scopeLabel(scope))
            }
            return "<button type=\"button\" role=\"tab\" data-tab=\"\(id.htmlEscaped)\" aria-selected=\"\(index == 0)\">\(label.htmlEscaped)</button>"
        }
        return "<nav class=\"tabs\" role=\"tablist\" aria-label=\"Scope\">\(buttons.joined())</nav>"
    }
}
