/// Renders one scope's diagram and data list as a `<section>`.
struct SectionRenderer {
    let context: RenderContext
    let view: ScopedDocument

    func render(hidden: Bool) -> String {
        let id = switch view.selection {
        case .all: "all"
        case let .scope(scope): scope
        }
        let diagram = DiagramRenderer(context: context, view: view, anchor: "arrow-\(id)").render()
        let list = ListRenderer(context: context, view: view).render()
        return """
        <section data-scope="\(id.htmlEscaped)"\(hidden ? " hidden" : "")>
        <h2>Diagram</h2>
        \(diagram)
        <h2>Data</h2>
        \(list)
        </section>
        """
    }
}
