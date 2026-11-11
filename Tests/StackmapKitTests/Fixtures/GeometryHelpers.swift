import StackmapKit

extension DiagramGeometry {
    func frame(of node: NodeID) -> Rect? {
        nodes.first { $0.nodeID == node }?.frame
    }

    func frames(of kind: NodeKind) -> [Rect] {
        nodes.filter { $0.nodeID.kind == kind }.map(\.frame)
    }

    var canvas: Rect {
        Rect(x: 0, y: 0, width: width, height: height)
    }

    var providerBands: [DiagramBand] {
        bands.filter { $0.kind == .provider }
    }

    var scopeBands: [DiagramBand] {
        bands.filter { $0.kind == .scope }
    }
}

extension Rect {
    /// Whether `point` is on or inside the rectangle.
    func covers(_ point: Point) -> Bool {
        x <= point.x && point.x <= maxX && y <= point.y && point.y <= maxY
    }

    /// Whether `point` is on the outline of the rectangle.
    func outlineContains(_ point: Point) -> Bool {
        covers(point) && (point.x == x || point.x == maxX || point.y == y || point.y == maxY)
    }

    /// Whether the rectangle grown by one pixel on every side covers `point`.
    func grownByOneCovers(_ point: Point) -> Bool {
        x - 1 <= point.x && point.x <= maxX + 1 && y - 1 <= point.y && point.y <= maxY + 1
    }

    /// Whether the open interior of the rectangle is crossed by the axis-aligned segment.
    func interiorIsCrossed(by segment: Segment) -> Bool {
        let lowX = min(segment.start.x, segment.end.x)
        let highX = max(segment.start.x, segment.end.x)
        let lowY = min(segment.start.y, segment.end.y)
        let highY = max(segment.start.y, segment.end.y)
        if segment.start.x == segment.end.x {
            return x < segment.start.x && segment.start.x < maxX && lowY < maxY && highY > y
        }
        return y < segment.start.y && segment.start.y < maxY && lowX < maxX && highX > x
    }

    /// Whether the horizontal extents share more than a single edge.
    func overlapsHorizontally(_ other: Rect) -> Bool {
        x < other.maxX && other.x < maxX
    }
}

extension Segment {
    var isAxisAligned: Bool {
        start.x == end.x || start.y == end.y
    }
}

extension DiagramGeometry {
    /// The cards of `kind` grouped into rows: cards whose vertical extents overlap share a row.
    /// Rows run top to bottom and each row lists its cards left to right.
    func rows(of kind: NodeKind) -> [[DiagramNode]] {
        let cards = nodes.filter { $0.nodeID.kind == kind }.sorted { ($0.frame.y, $0.frame.x) < ($1.frame.y, $1.frame.x) }
        var rows: [[DiagramNode]] = []
        var bottom = Int.min
        for card in cards {
            if rows.isEmpty || card.frame.y >= bottom {
                rows.append([card])
                bottom = card.frame.maxY
            } else {
                rows[rows.count - 1].append(card)
                bottom = max(bottom, card.frame.maxY)
            }
        }
        return rows.map { $0.sorted { $0.frame.x < $1.frame.x } }
    }

    func rowIDs(of kind: NodeKind) -> [[String]] {
        rows(of: kind).map { $0.map(\.nodeID.id) }
    }

    func edges(from source: NodeID) -> [DiagramEdge] {
        edges.filter { $0.source == source }
    }
}

extension Rect {
    var midX: Int {
        x + width / 2
    }

    /// Whether the vertical extents share more than a single edge.
    func overlapsVertically(_ other: Rect) -> Bool {
        y < other.maxY && other.y < maxY
    }
}

extension Segment {
    var hasLength: Bool {
        start != end
    }

    /// Whether the two axis-aligned segments lie on one line and share a stretch of positive length.
    func overlapsCollinearly(_ other: Segment) -> Bool {
        guard hasLength, other.hasLength else { return false }
        let vertical = start.x == end.x
        let otherVertical = other.start.x == other.end.x
        guard vertical == otherVertical else { return false }
        if vertical {
            guard start.x == other.start.x else { return false }
            return Swift.max(Swift.min(start.y, end.y), Swift.min(other.start.y, other.end.y))
                < Swift.min(Swift.max(start.y, end.y), Swift.max(other.start.y, other.end.y))
        }
        guard start.y == other.start.y else { return false }
        return Swift.max(Swift.min(start.x, end.x), Swift.min(other.start.x, other.end.x))
            < Swift.min(Swift.max(start.x, end.x), Swift.max(other.start.x, other.end.x))
    }
}
