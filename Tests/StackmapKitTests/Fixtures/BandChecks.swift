import StackmapKit

extension DiagramGeometry {
    func serviceBandProblems(_ document: ScopedDocument, owners: Set<String>) -> [String] {
        var found: [String] = []
        for provider in Set(document.services.map(\.provider)).sorted() {
            let members = document.services.filter { $0.provider == provider }
            var ids = members.map { NodeID(kind: .service, id: $0.id) }
            ids += members.filter { owners.contains($0.id) }.map { NodeID(kind: .serviceStores, id: $0.id) }
            let frames = ids.compactMap { frame(of: $0) }
            if !providerBands.contains(where: { $0.id == provider && frames.allSatisfy($0.frame.contains) }) {
                found.append("no band for \(provider) contains all of its cards")
            }
        }
        return found
    }

    func bottomBandProblems(_ document: ScopedDocument, sharedStores: Set<String>) -> [String] {
        var found: [String] = []
        let upper = nodes.filter { $0.nodeID.kind == .service || $0.nodeID.kind == .serviceStores }.map(\.frame)
        for store in document.stores where sharedStores.contains(store.id) {
            guard let card = frame(of: NodeID(kind: .sharedStore, id: store.id)) else { continue }
            let band = providerBands.first { $0.id == store.provider && $0.frame.contains(card) }
            guard let band else {
                found.append("no band for \(store.provider) contains shared store \(store.id)")
                continue
            }
            if upper.contains(where: { $0.maxY > band.frame.y }) {
                found.append("bottom band of \(store.provider) starts above the service rows")
            }
        }
        return found
    }

    func overlappingProviderBands() -> [String] {
        var found: [String] = []
        for (index, band) in providerBands.enumerated() {
            for other in providerBands[(index + 1)...] where band.frame.intersects(other.frame) {
                found.append("band \(band.id) overlaps band \(other.id)")
            }
        }
        return found
    }

    func cardsInForeignBands(_ document: ScopedDocument) -> [String] {
        let providerOfService = Dictionary(uniqueKeysWithValues: document.services.map { ($0.id, $0.provider) })
        let providerOfStore = Dictionary(uniqueKeysWithValues: document.stores.map { ($0.id, $0.provider) })
        var found: [String] = []
        for band in providerBands {
            for node in nodes {
                let owner: String? = switch node.nodeID.kind {
                case .client: nil
                case .service, .serviceStores: providerOfService[node.nodeID.id]
                case .sharedStore: providerOfStore[node.nodeID.id]
                }
                if owner != band.id, band.frame.intersects(node.frame) {
                    found.append("\(node.nodeID) intrudes on band \(band.id)")
                }
            }
        }
        return found
    }

    func scopeRunProblems(_ expected: ExpectedDiagram) -> [String] {
        let serviceFrames = Dictionary(uniqueKeysWithValues: nodes.filter { $0.nodeID.kind == .service }.map { ($0.nodeID.id, $0.frame) })
        var found: [String] = []
        for run in expected.scopeRuns {
            let ids = Set(run.services.map(\.id))
            let frames = run.services.compactMap { serviceFrames[$0.id] }
            guard let band = scopeBands.first(where: { $0.id == run.scope && frames.allSatisfy($0.frame.contains) }) else {
                found.append("no \(run.scope) band contains \(ids.sorted())")
                continue
            }
            found += serviceFrames.filter { !ids.contains($0.key) && band.frame.intersects($0.value) }
                .map { "band \(run.scope) overlaps \($0.key)" }
        }
        return found
    }
}
