extension GridRouter {
    /// Down from the source, along its lane in the gap below, through the
    /// target's channel when the target is not in the next row, along the
    /// lane in the gap above the target, and down to one pixel above it.
    func segments(_ index: Int) -> [Segment] {
        let connector = connectors[index]
        let route = Route(connector, plan: plan)
        let start = exitPoint(index)
        let end = entryPoint(index)
        let exitY = laneY(route.exitGap, LaneTable.exitKey(index, connector))
        guard let channel = route.channel else {
            let across = start.x == end.x ? [] : [Segment.horizontal(exitY, from: start.x, to: end.x)]
            return [Segment.vertical(start.x, from: start.y, to: exitY)] + across + [Segment.vertical(end.x, from: exitY, to: end.y)]
        }

        let laneX = coordinates.channelLeft[channel] + (lanes.channelLanes[channel][index, default: 0] + 1) * Metrics.channelLaneStep
        let entryY = laneY(route.entryGap, LaneTable.entryKey(index))
        return [
            Segment.vertical(start.x, from: start.y, to: exitY),
            Segment.horizontal(exitY, from: start.x, to: laneX),
            Segment.vertical(laneX, from: exitY, to: entryY),
            Segment.horizontal(entryY, from: laneX, to: end.x),
            Segment.vertical(end.x, from: entryY, to: end.y),
        ]
    }

    private func laneY(_ gap: Int, _ key: String) -> Int {
        coordinates.gapTop[gap] + (lanes.gapLanes[gap][key, default: 0] + 1) * Metrics.laneStep
    }

    /// A client's connectors leave from one point; a service's leave from
    /// separate points on the left of its bottom edge, clear of its stores card.
    private func exitPoint(_ index: Int) -> Point {
        let source = connectors[index].source
        let frame = frame(of: source) ?? Rect(x: 0, y: 0, width: 0, height: 0)
        guard source.kind == .service else { return Point(x: frame.x + Metrics.clientExit, y: frame.maxY) }

        let order = lanes.exits[source, default: []]
        let position = order.firstIndex(of: index) ?? 0
        let step = order.count > 1 ? min(10, Metrics.exitSpan / (order.count - 1)) : 0
        return Point(x: frame.x + Metrics.exitStart + position * max(step, 1), y: frame.maxY)
    }

    /// Connectors into a card arrive at separate points on the right part of its top edge.
    private func entryPoint(_ index: Int) -> Point {
        let target = connectors[index].target
        let frame = frame(of: target) ?? Rect(x: 0, y: 0, width: 0, height: 0)
        let order = lanes.entries[target, default: []]
        let position = order.firstIndex(of: index) ?? 0
        let left = frame.x + Metrics.entryStart
        let span = frame.maxX - Metrics.entryInset - left
        return Point(x: left + (position + 1) * span / (order.count + 1), y: frame.y - 1)
    }
}
