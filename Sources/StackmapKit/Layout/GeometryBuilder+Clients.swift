extension GeometryBuilder {
    /// Places each client above the mean of the services it calls, left to right without overlap.
    mutating func placeClients() {
        let desired = document.clients.enumerated().map { offset, client in
            let centers = client.calls.compactMap(serviceCenterX)
            let center = centers.isEmpty ? nil : centers.reduce(0, +) / centers.count
            return (client: client, center: center, offset: offset)
        }
        let ordered = desired.sorted { lhs, rhs in
            (lhs.center ?? .max, lhs.offset) < (rhs.center ?? .max, rhs.offset)
        }

        var nextX = Metrics.margin
        for entry in ordered {
            let x = max(nextX, (entry.center ?? 0) - Metrics.cardWidth / 2)
            let frame = Rect(x: x, y: Metrics.margin, width: Metrics.cardWidth, height: Metrics.clientHeight)
            nodes.append(DiagramNode(nodeID: NodeID(kind: .client, id: entry.client.id), frame: frame))
            nextX = frame.maxX + Metrics.cardGap
            connect(entry.client, from: Point(x: x + Metrics.cardWidth / 2, y: frame.maxY))
        }
    }

    private mutating func connect(_ client: Client, from start: Point) {
        guard let busIndex = callingClients.firstIndex(where: { $0.id == client.id }) else { return }

        let source = NodeID(kind: .client, id: client.id)
        for call in client.calls {
            guard let targetX = serviceCenterX(call) else { continue }

            let segments = Self.elbow(from: start, busY: clientBusY(busIndex), toX: targetX, targetY: serviceY)
            edges.append(DiagramEdge(kind: .call, source: source, target: NodeID(kind: .service, id: call), segments: segments))
        }
    }
}
