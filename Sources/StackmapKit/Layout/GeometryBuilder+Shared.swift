extension GeometryBuilder {
    /// Places stores reached from other providers in bottom bands, one card per store.
    mutating func placeSharedStores() {
        let stores = placement.sharedStores
        guard !stores.isEmpty else { return }

        let busTop = storesBottom + Metrics.bandPadding + Metrics.busGap
        let bandTop = busTop + Metrics.busStep * (stores.count - 1) + Metrics.cardGap
        let cardY = bandTop + Metrics.providerLabelHeight
        var frames: [String: Rect] = [:]
        var nextX = Metrics.margin + Metrics.bandPadding
        var previousProvider: String?
        for store in stores {
            if let previousProvider, previousProvider != store.provider {
                nextX += 2 * Metrics.bandPadding
            }
            let lanes = laneXs(reaching: store.id)
            let center = lanes.isEmpty ? nextX : lanes.reduce(0, +) / lanes.count
            let lines = placement.sharedData[store.id, default: []].count
            let frame = Rect(x: max(nextX, center - Metrics.sharedWidth / 2), y: cardY, width: Metrics.sharedWidth, height: Metrics.sharedHeight(lines: lines))
            frames[store.id] = frame
            nodes.append(DiagramNode(nodeID: NodeID(kind: .sharedStore, id: store.id), frame: frame))
            nextX = frame.maxX + Metrics.cardGap
            previousProvider = store.provider
        }

        connectSharedStores(frames: frames, busTop: busTop)
        addSharedBands(frames: frames, top: bandTop)
    }

    private mutating func connectSharedStores(frames: [String: Rect], busTop: Int) {
        for service in placement.services {
            let reached = placement.reachedStores[service.id, default: []]
            for (lane, storeID) in reached.enumerated() {
                connect(service.id, lane: lane, of: reached.count, to: storeID, frames: frames, busTop: busTop)
            }
        }
    }

    private mutating func connect(_ serviceID: String, lane: Int, of count: Int, to storeID: String, frames: [String: Rect], busTop: Int) {
        guard let x = laneX(serviceID, lane: lane, of: count), let frame = frames[storeID],
              let storeIndex = placement.sharedStores.firstIndex(where: { $0.id == storeID }) else { return }

        let segments = Self.elbow(
            from: Point(x: x, y: serviceY + Metrics.serviceHeight),
            busY: busTop + Metrics.busStep * storeIndex,
            toX: frame.x + frame.width / 2,
            targetY: frame.y
        )
        let source = NodeID(kind: .service, id: serviceID)
        edges.append(DiagramEdge(kind: .sharedStore, source: source, target: NodeID(kind: .sharedStore, id: storeID), segments: segments))
    }

    private mutating func addSharedBands(frames: [String: Rect], top: Int) {
        var groups: [(provider: String, frames: [Rect])] = []
        for store in placement.sharedStores {
            guard let frame = frames[store.id] else { continue }

            if groups.last?.provider == store.provider {
                groups[groups.count - 1].frames.append(frame)
            } else {
                groups.append((store.provider, [frame]))
            }
        }
        for group in groups {
            let left = (group.frames.map(\.x).min() ?? 0) - Metrics.bandPadding
            let right = (group.frames.map(\.maxX).max() ?? 0) + Metrics.bandPadding
            let bottom = (group.frames.map(\.maxY).max() ?? 0) + Metrics.bandPadding
            bands.append(DiagramBand(kind: .provider, id: group.provider, frame: Rect(x: left, y: top, width: right - left, height: bottom - top)))
        }
    }

    private func laneXs(reaching storeID: String) -> [Int] {
        placement.services.compactMap { service in
            let reached = placement.reachedStores[service.id, default: []]
            return reached.firstIndex(of: storeID).flatMap { laneX(service.id, lane: $0, of: reached.count) }
        }
    }

    /// Lanes sit in the gutter left of the service's stores card.
    private func laneX(_ serviceID: String, lane: Int, of count: Int) -> Int? {
        guard let x = columnX[serviceID] else { return nil }

        let step = count > 1 ? min(14, Metrics.laneSpan / (count - 1)) : 0
        return x + Metrics.laneStart + lane * max(step, 1)
    }
}
