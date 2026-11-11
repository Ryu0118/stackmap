/// Positions the cards, bands, and connectors of a scoped document.
package struct DiagramLayout: Sendable {
    /// Creates a layout.
    package init() {}

    /// Lays out `document` following the rows described in the configuration guide.
    package func layout(_ document: ScopedDocument) -> DiagramGeometry {
        var builder = GeometryBuilder(document)
        builder.placeServices()
        builder.placeClients()
        builder.placeSharedStores()
        return builder.geometry
    }
}
