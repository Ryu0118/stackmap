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

    func clientsNotAboveServices() -> [String] {
        var found: [String] = []
        for client in nodes where client.nodeID.kind == .client {
            for service in nodes where service.nodeID.kind == .service && client.frame.maxY > service.frame.y {
                found.append("\(client.nodeID) is not above \(service.nodeID)")
            }
        }
        return found
    }

    func misplacedStoreCards(owners: Set<String>) -> [String] {
        owners.sorted().compactMap { owner in
            guard let service = frame(of: NodeID(kind: .service, id: owner)),
                  let card = frame(of: NodeID(kind: .serviceStores, id: owner))
            else { return "\(owner): service or store card is missing" }
            if service.maxY > card.y {
                return "\(owner): store card is not below its service"
            }
            if !service.overlapsHorizontally(card) {
                return "\(owner): store card is not under its service"
            }
            return nil
        }
    }

    func sharedStoresNotAtBottom() -> [String] {
        var found: [String] = []
        let upper = nodes.filter { $0.nodeID.kind == .service || $0.nodeID.kind == .serviceStores }
        for shared in nodes where shared.nodeID.kind == .sharedStore {
            for other in upper where other.frame.maxY > shared.frame.y {
                found.append("\(shared.nodeID) is not below \(other.nodeID)")
            }
        }
        return found
    }

    func servicesOrderedLeftToRight() -> [String] {
        nodes.filter { $0.nodeID.kind == .service }.sorted { $0.frame.x < $1.frame.x }.map(\.nodeID.id)
    }
}
