/// Positions the cards, bands, and connectors of a scoped document.
package struct DiagramLayout: Sendable {
    /// Creates a layout.
    package init() {}

    /// Lays out `document` following the rows described in the configuration guide.
    package func layout(_: ScopedDocument) -> DiagramGeometry {
        fatalError("Not implemented")
    }
}
