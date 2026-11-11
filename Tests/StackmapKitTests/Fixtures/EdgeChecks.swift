import StackmapKit

extension DiagramGeometry {
    func malformedSegments() -> [String] {
        var found: [String] = []
        for edge in edges {
            let name = "\(edge.source) to \(edge.target)"
            if edge.segments.isEmpty {
                found.append("\(name): no segments")
            }
            found += edge.segments.filter { !$0.isAxisAligned }.map { "\(name): diagonal segment \($0)" }
            found += zip(edge.segments, edge.segments.dropFirst()).filter { $0.end != $1.start }.map { "\(name): gap after \($0)" }
        }
        return found
    }

    func connectorsNotStartingOnSource() -> [String] {
        edges.compactMap { edge in
            guard let source = frame(of: edge.source), let start = edge.segments.first?.start else {
                return "\(edge.source) to \(edge.target): no source card or segment"
            }
            return source.outlineContains(start) ? nil : "\(edge.source) to \(edge.target): starts at \(start), off the card edge"
        }
    }

    func connectorsNotEndingNextToTarget() -> [String] {
        edges.compactMap { edge in
            guard let target = frame(of: edge.target), let end = edge.segments.last?.end else {
                return "\(edge.source) to \(edge.target): no target card or segment"
            }
            if target.covers(end) {
                return "\(edge.source) to \(edge.target): ends at \(end), inside the card"
            }
            if !target.grownByOneCovers(end) {
                return "\(edge.source) to \(edge.target): ends at \(end), too far from the card"
            }
            return nil
        }
    }

    func connectorsCrossingCards() -> [String] {
        var found: [String] = []
        for edge in edges {
            for node in nodes {
                if edge.segments.contains(where: { node.frame.interiorIsCrossed(by: $0) }) {
                    found.append("\(edge.source) to \(edge.target) crosses \(node.nodeID)")
                }
            }
        }
        return found
    }
}
