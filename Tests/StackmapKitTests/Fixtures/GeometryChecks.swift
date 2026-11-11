import StackmapKit

/// Invariant checks that return a description of every violation, so tests read as `== []`.
extension DiagramGeometry {
    func overlappingNodes() -> [String] {
        var found: [String] = []
        for (index, node) in nodes.enumerated() {
            for other in nodes[(index + 1)...] where node.frame.intersects(other.frame) {
                found.append("\(node.nodeID) overlaps \(other.nodeID)")
            }
        }
        return found
    }

    func framesOutsideCanvas() -> [String] {
        let cards = nodes.filter { !canvas.contains($0.frame) }.map { "card \($0.nodeID)" }
        let backgrounds = bands.filter { !canvas.contains($0.frame) }.map { "band \($0.kind) \($0.id)" }
        return cards + backgrounds
    }

    func framesWithoutArea() -> [String] {
        let cards = nodes.filter { $0.frame.width <= 0 || $0.frame.height <= 0 }.map { "card \($0.nodeID)" }
        let backgrounds = bands.filter { $0.frame.width <= 0 || $0.frame.height <= 0 }.map { "band \($0.kind) \($0.id)" }
        return cards + backgrounds
    }

    /// Clients sit above every other card and every band.
    func clientsNotAtTheTop() -> [String] {
        var found: [String] = []
        for client in nodes where client.nodeID.kind == .client {
            for other in nodes where other.nodeID.kind != .client && client.frame.maxY > other.frame.y {
                found.append("\(client.nodeID) is not above \(other.nodeID)")
            }
            for band in bands where client.frame.maxY > band.frame.y {
                found.append("\(client.nodeID) is not above band \(band.kind) \(band.id)")
            }
        }
        return found
    }

    /// Left edges of client, service, and shared store cards; own-data cards are indented inside a column.
    var columnPositions: [Int] {
        Set(nodes.filter { $0.nodeID.kind != .serviceStores }.map(\.frame.x)).sorted()
    }

    /// Each own-data card is indented under its service within that service's column, below it, with no other card in between.
    func misplacedStoreCards(owners: Set<String>) -> [String] {
        owners.sorted().compactMap { owner in
            guard let service = frame(of: NodeID(kind: .service, id: owner)),
                  let card = frame(of: NodeID(kind: .serviceStores, id: owner))
            else { return "\(owner): service or store card is missing" }
            if service.maxY > card.y {
                return "\(owner): store card is not below its service"
            }
            if !(service.x < card.x && card.x < service.maxX) {
                return "\(owner): store card at x \(card.x) is not indented under its service at \(service.x)...\(service.maxX)"
            }
            if let next = columnPositions.first(where: { $0 > service.x }), card.maxX > next {
                return "\(owner): store card reaches past its column into the column at \(next)"
            }
            let between = nodes.filter { $0.frame.overlapsHorizontally(service) && $0.frame.y >= service.maxY && $0.frame.maxY <= card.y }
            return between.isEmpty ? nil : "\(owner): \(between.map(\.nodeID)) sit between the service and its store card"
        }
    }

    /// No row of cards, whatever their kinds, holds more than four cards.
    func overfullRows() -> [String] {
        nodes.compactMap { node in
            let row = nodes.filter { $0.frame.overlapsVertically(node.frame) }
            return row.count > ExpectedDiagram.rowCapacity ? "\(node.nodeID) shares a row with \(row.count - 1) other cards" : nil
        }
    }

    /// Client, service, and shared store cards start on at most four column positions shared by every row.
    func columnGridProblems() -> [String] {
        let columns = columnPositions
        return columns.count > ExpectedDiagram.rowCapacity ? ["cards use \(columns.count) column positions: \(columns)"] : []
    }
}
