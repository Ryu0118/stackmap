/// Draws a diagram as an SVG layer of bands and connectors under positioned HTML cards.
struct DiagramRenderer {
    let context: RenderContext
    let view: ScopedDocument
    /// The id of this section's arrowhead marker; unique per page.
    let anchor: String

    func render() -> String {
        let geometry = DiagramLayout().layout(view)
        guard !geometry.nodes.isEmpty else {
            return "<p class=\"empty\">Nothing to draw.</p>"
        }

        let cards = CardRenderer(context: context, view: view)
        let bands = geometry.bands.map(bandRect).joined()
        let edges = geometry.edges.map(edgePath).joined()
        let labels = geometry.bands.map(bandLabel).joined()
        let nodes = geometry.nodes.map(cards.render).joined()
        return """
        <div class="diagram-scroll"><div class="diagram" style="width:\(geometry.width)px;height:\(geometry.height)px">\
        <svg class="wires" width="\(geometry.width)" height="\(geometry.height)" viewBox="0 0 \(geometry.width) \(geometry.height)" aria-hidden="true">\
        <defs>\(marker("plain"))\(marker("shared"))</defs>\(bands)\(edges)</svg>\(labels)\(nodes)</div></div>
        <ul class="legend"><li><span class="swatch swatch-call"></span>Calls and owns</li>\
        <li><span class="swatch swatch-shared"></span>Owns data on another provider</li>\
        <li><span class="swatch swatch-planned"></span>Planned or migrating</li></ul>
        """
    }

    private func marker(_ style: String) -> String {
        "<marker id=\"\(anchor.htmlEscaped)-\(style)\" viewBox=\"0 0 8 8\" refX=\"7\" refY=\"4\" markerWidth=\"7\" markerHeight=\"7\" orient=\"auto\">"
            + "<path class=\"arrowhead arrowhead-\(style)\" d=\"M0 0 L8 4 L0 8 Z\"/></marker>"
    }

    private func bandRect(_ band: DiagramBand) -> String {
        let frame = band.frame
        return "<rect class=\"band band-\(band.kind.rawValue)\" x=\"\(frame.x)\" y=\"\(frame.y)\" width=\"\(frame.width)\" height=\"\(frame.height)\" rx=\"14\"/>"
    }

    private func bandLabel(_ band: DiagramBand) -> String {
        let label = switch band.kind {
        case .provider: context.providerLabel(band.id)
        case .scope: context.scopeLabel(band.id)
        }
        let offset = band.kind == .provider ? 14 : 10
        return "<div class=\"band-label band-label-\(band.kind.rawValue)\" style=\"left:\(band.frame.x + 16)px;top:\(band.frame.y + offset)px\">\(label.htmlEscaped)</div>"
    }

    private func edgePath(_ edge: DiagramEdge) -> String {
        guard let first = edge.segments.first else { return "" }

        let points = edge.segments.map { " L\($0.end.x) \($0.end.y)" }.joined()
        let path = "M\(first.start.x) \(first.start.y)\(points)"
        return "<path class=\"edge edge-\(edge.kind.rawValue)\" d=\"\(path)\" marker-end=\"url(#\(anchor.htmlEscaped)-\(edge.kind == .sharedStore ? "shared" : "plain"))\"/>"
    }
}
