/// Lane numbers handed out in first-come order; a key seen again keeps its lane.
struct LaneOrder<Key: Hashable> {
    private(set) var lanes: [Key: Int] = [:]

    var count: Int {
        lanes.count
    }

    mutating func add(_ key: Key) {
        if lanes[key] == nil {
            lanes[key] = lanes.count
        }
    }
}
