import StackmapKit

/// Connector routing rules from the "Connectors" section of the configuration guide.
extension DiagramGeometry {
    /// Calls, service calls, and shared store links leave the bottom edge of the source card.
    func connectorsNotLeavingSourceBottom() -> [String] {
        edges.filter { $0.kind != .ownStores }.compactMap { edge in
            guard let source = frame(of: edge.source), let start = edge.segments.first?.start else {
                return "\(edge.source) to \(edge.target): no source card or segment"
            }
            let onBottom = start.y == source.maxY && source.x <= start.x && start.x <= source.maxX
            return onBottom ? nil : "\(edge.source) to \(edge.target): starts at \(start), not on the bottom of \(source)"
        }
    }

    /// Every connector ends one pixel above the top edge of its target card.
    func connectorsNotEndingAboveTargetTop() -> [String] {
        edges.compactMap { edge in
            guard let target = frame(of: edge.target), let end = edge.segments.last?.end else {
                return "\(edge.source) to \(edge.target): no target card or segment"
            }
            let aboveTop = end.y == target.y - 1 && target.x <= end.x && end.x <= target.maxX
            return aboveTop ? nil : "\(edge.source) to \(edge.target): ends at \(end), not one pixel above the top of \(target)"
        }
    }

    /// A service and its own-data card are joined by one vertical segment.
    func crookedOwnStoreConnectors() -> [String] {
        edges.filter { $0.kind == .ownStores }.compactMap { edge in
            guard edge.segments.count == 1, let only = edge.segments.first, only.start.x == only.end.x,
                  let source = frame(of: edge.source), only.start.y == source.maxY
            else { return "\(edge.source) to \(edge.target): not one straight segment down from the service" }
            return nil
        }
    }

    /// Different connectors never run along the same line, except connectors from the same client.
    func collinearConnectorOverlaps() -> [String] {
        var found: [String] = []
        for (index, edge) in edges.enumerated() {
            for other in edges[(index + 1)...] where !(edge.source == other.source && edge.source.kind == .client) {
                let shared = edge.segments.contains { segment in other.segments.contains { segment.overlapsCollinearly($0) } }
                if shared {
                    found.append("\(edge.source) to \(edge.target) runs along \(other.source) to \(other.target)")
                }
            }
        }
        return found
    }

    /// All connectors from one client leave from one point.
    func clientConnectorsWithSplitStarts() -> [String] {
        nodes.filter { $0.nodeID.kind == .client }.compactMap { client in
            let starts = Set(edges(from: client.nodeID).compactMap { $0.segments.first?.start })
            return starts.count > 1 ? "\(client.nodeID) connectors leave from \(starts.count) points" : nil
        }
    }

    /// The height of the first horizontal run of each connector from `client` that has one.
    func firstHorizontalRuns(from client: NodeID) -> [Int] {
        edges(from: client).compactMap { edge in
            edge.segments.first { $0.start.y == $0.end.y && $0.hasLength }?.start.y
        }
    }

    /// A client's connectors share their first horizontal run, like a bus.
    func clientBusesSplitAcrossLines() -> [String] {
        nodes.filter { $0.nodeID.kind == .client }.compactMap { client in
            let heights = Set(firstHorizontalRuns(from: client.nodeID))
            return heights.count > 1 ? "\(client.nodeID) connectors run along \(heights.count) lines: \(heights.sorted())" : nil
        }
    }

    /// A service's outgoing connectors leave from separate points on the left half of its bottom edge.
    /// Own-data connectors count for separateness; only the other kinds must be on the left half.
    func serviceExitPointProblems() -> [String] {
        var found: [String] = []
        for service in nodes where service.nodeID.kind == .service {
            let outgoing = edges(from: service.nodeID)
            let starts = outgoing.compactMap { $0.segments.first?.start }
            if Set(starts).count != starts.count {
                found.append("\(service.nodeID): \(starts.count) connectors leave from \(Set(starts).count) points")
            }
            found += outgoing.filter { $0.kind != .ownStores }.compactMap { edge in
                guard let start = edge.segments.first?.start, start.x > service.frame.midX else { return nil }
                return "\(service.nodeID) to \(edge.target): leaves at x \(start.x), right of the middle \(service.frame.midX)"
            }
        }
        return found
    }

    /// Connectors into one card arrive at separate points.
    func sharedEntryPoints() -> [String] {
        nodes.compactMap { node in
            let ends = edges.filter { $0.target == node.nodeID }.compactMap { $0.segments.last?.end }
            return Set(ends).count == ends.count ? nil : "\(node.nodeID): \(ends.count) connectors arrive at \(Set(ends).count) points"
        }
    }
}
