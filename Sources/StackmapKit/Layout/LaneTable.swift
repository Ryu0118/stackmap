/// Which gaps and channel each connector runs through, and its lane in each.
///
/// Gap `g` is the space above row `g`; gap `rows.count` is below the last
/// row. Channel `k` is the vertical space left of column `k`. A connector
/// leaves into the gap below its source's row and arrives from the gap above
/// its target's row; when those differ it crosses between them in the
/// channel left of the target's column. Every connector gets its own lane,
/// except that a client's connectors share one lane in the gap below it.
struct LaneTable {
    let gapLanes: [[String: Int]]
    let channelLanes: [[Int: Int]]
    let gapLaneCounts: [Int]
    let channelLaneCounts: [Int]
    /// Indexes of the connectors leaving and entering each card, in order.
    let exits: [NodeID: [Int]]
    let entries: [NodeID: [Int]]

    init(_ connectors: [Connector], plan: GridPlan) {
        var gaps = Array(repeating: LaneOrder<String>(), count: plan.rows.count + 1)
        var channels = Array(repeating: LaneOrder<Int>(), count: max(plan.columnCount, 1))
        var exits: [NodeID: [Int]] = [:]
        var entries: [NodeID: [Int]] = [:]
        for (index, connector) in connectors.enumerated() {
            let route = Route(connector, plan: plan)
            gaps[route.exitGap].add(Self.exitKey(index, connector))
            if let channel = route.channel {
                channels[channel].add(index)
                gaps[route.entryGap].add(Self.entryKey(index))
            }
            exits[connector.source, default: []].append(index)
            entries[connector.target, default: []].append(index)
        }
        gapLanes = gaps.map(\.lanes)
        channelLanes = channels.map(\.lanes)
        gapLaneCounts = gaps.map(\.count)
        channelLaneCounts = channels.map(\.count)
        self.exits = exits
        self.entries = entries
    }

    static func exitKey(_ index: Int, _ connector: Connector) -> String {
        connector.source.kind == .client ? "client:\(connector.source.id)" : "exit:\(index)"
    }

    static func entryKey(_ index: Int) -> String {
        "entry:\(index)"
    }
}
