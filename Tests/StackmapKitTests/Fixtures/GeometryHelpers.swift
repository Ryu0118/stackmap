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
