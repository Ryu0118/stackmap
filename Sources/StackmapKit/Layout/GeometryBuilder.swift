/// Accumulates nodes, bands, and edges row by row.
///
/// Rows are placed services first, because client and shared-store positions
/// depend on the service columns; the vertical offsets are computed up front.
struct GeometryBuilder {
    typealias Metrics = LayoutMetrics

    let document: ScopedDocument
    let placement: DataPlacement
    let ordering: ServiceOrdering
    var nodes: [DiagramNode] = []
    var bands: [DiagramBand] = []
    var edges: [DiagramEdge] = []
    /// Left edge of each service column, by service id.
    var columnX: [String: Int] = [:]
    let callingClients: [Client]
    let serviceY: Int
    let storesY: Int
    let storesBottom: Int

    init(_ document: ScopedDocument) {
        let placement = DataPlacement(document)
        let ordering = ServiceOrdering(document)
        self.document = document
        self.placement = placement
        self.ordering = ordering
        callingClients = document.clients.filter { !$0.calls.isEmpty }

        let clientsBottom = document.clients.isEmpty ? 0 : Metrics.margin + Metrics.clientHeight
        let lastClientBus = clientsBottom + Metrics.busGap + Metrics.busStep * max(callingClients.count - 1, 0)
        let bandTop = document.clients.isEmpty ? Metrics.margin : lastClientBus + Metrics.cardGap
        let hasScopeBands = document.selection == .all && placement.services.contains { ordering.bandScope(of: $0) != nil }
        let serviceY = bandTop + Metrics.providerLabelHeight + (hasScopeBands ? Metrics.scopeLabelHeight : Metrics.scopePadding)
        self.serviceY = serviceY
        let maxLines = placement.localData.values.map(\.count).max()
        let storesY = serviceY + Metrics.serviceHeight + Metrics.cardGap
        self.storesY = storesY
        storesBottom = maxLines.map { storesY + Metrics.storesHeight(lines: $0) } ?? serviceY + Metrics.serviceHeight
    }

    var geometry: DiagramGeometry {
        let frames = nodes.map(\.frame) + bands.map(\.frame)
        let width = (frames.map(\.maxX).max() ?? 0) + Metrics.margin
        let height = (frames.map(\.maxY).max() ?? 0) + Metrics.margin
        return DiagramGeometry(width: width, height: height, nodes: nodes, bands: bands, edges: edges)
    }

    func clientBusY(_ index: Int) -> Int {
        Metrics.margin + Metrics.clientHeight + Metrics.busGap + Metrics.busStep * index
    }

    func serviceCenterX(_ id: String) -> Int? {
        columnX[id].map { $0 + Metrics.cardWidth / 2 }
    }

    static func vertical(_ x: Int, from startY: Int, to endY: Int) -> Segment {
        Segment(start: Point(x: x, y: startY), end: Point(x: x, y: endY))
    }

    static func horizontal(_ y: Int, from startX: Int, to endX: Int) -> Segment {
        Segment(start: Point(x: startX, y: y), end: Point(x: endX, y: y))
    }

    /// Down from `start`, across at `busY`, and down into a card whose top is `targetY`.
    static func elbow(from start: Point, busY: Int, toX targetX: Int, targetY: Int) -> [Segment] {
        guard start.x != targetX else {
            return [vertical(start.x, from: start.y, to: targetY - 1)]
        }
        return [
            vertical(start.x, from: start.y, to: busY),
            horizontal(busY, from: start.x, to: targetX),
            vertical(targetX, from: busY, to: targetY - 1),
        ]
    }
}
