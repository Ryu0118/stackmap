/// Positions the cards, bands, and connectors of a scoped document.
package struct DiagramLayout: Sendable {
    /// Creates a layout.
    package init() {}

    /// Lays out `document` on the grid described in the configuration guide.
    package func layout(_ document: ScopedDocument) -> DiagramGeometry {
        let placement = DataPlacement(document)
        let plan = GridPlan(document, placement: placement, ordering: ServiceOrdering(document))
        let connectors = Connector.all(document, placement: placement, cells: plan.cells)
        let lanes = LaneTable(connectors, plan: plan)
        let sizing = CardSizing(document, placement: placement)
        let heights = plan.rows.map { row in row.nodes.map { Self.cellHeight($0, sizing: sizing) }.max() ?? 0 }
        let coordinates = GridCoordinates(plan: plan, lanes: lanes, rowHeights: heights)
        return GridRouter(plan: plan, connectors: connectors, lanes: lanes, sizing: sizing, coordinates: coordinates).geometry
    }

    /// A service's cell also holds the card listing its own data.
    private static func cellHeight(_ node: NodeID, sizing: CardSizing) -> Int {
        let height = sizing.height(of: node)
        guard node.kind == .service, sizing.placement.localData[node.id]?.isEmpty == false else { return height }

        return height + LayoutMetrics.cardGap + sizing.height(of: NodeID(kind: .serviceStores, id: node.id))
    }
}
