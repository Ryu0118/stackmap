/// Turns the grid, the lanes, and the card sizes into the final geometry.
struct GridRouter {
    typealias Metrics = LayoutMetrics

    let plan: GridPlan
    let connectors: [Connector]
    let lanes: LaneTable
    let sizing: CardSizing
    let coordinates: GridCoordinates

    var geometry: DiagramGeometry {
        var nodes: [DiagramNode] = []
        var own: [DiagramEdge] = []
        for node in plan.rows.flatMap(\.nodes) {
            guard let frame = frame(of: node) else { continue }

            nodes.append(DiagramNode(nodeID: node, frame: frame))
            guard node.kind == .service, let stores = storesFrame(below: frame, service: node.id) else { continue }

            let storesID = NodeID(kind: .serviceStores, id: node.id)
            nodes.append(DiagramNode(nodeID: storesID, frame: stores))
            let x = stores.x + stores.width / 2
            own.append(DiagramEdge(kind: .ownStores, source: node, target: storesID, segments: [Segment.vertical(x, from: frame.maxY, to: stores.y - 1)]))
        }
        let routed = connectors.indices.map { index in
            DiagramEdge(kind: connectors[index].kind, source: connectors[index].source, target: connectors[index].target, segments: segments(index))
        }
        return DiagramGeometry(width: coordinates.width, height: coordinates.height, nodes: nodes, bands: coordinates.bands, edges: own + routed)
    }

    func frame(of node: NodeID) -> Rect? {
        guard let cell = plan.cells[node] else { return nil }

        let width = node.kind == .sharedStore ? Metrics.sharedWidth : Metrics.cardWidth
        return Rect(x: coordinates.columnX[cell.column], y: coordinates.rowY[cell.row], width: width, height: sizing.height(of: node))
    }

    func storesFrame(below service: Rect, service id: String) -> Rect? {
        guard let local = sizing.placement.localData[id], !local.isEmpty else { return nil }

        let node = NodeID(kind: .serviceStores, id: id)
        return Rect(x: service.x + Metrics.storesOffset, y: service.maxY + Metrics.cardGap, width: Metrics.storesWidth, height: sizing.height(of: node))
    }
}
