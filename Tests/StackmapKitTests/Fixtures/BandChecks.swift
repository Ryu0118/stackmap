import StackmapKit

extension DiagramGeometry {
    /// Each provider's single band contains its services, their own-data cards, and its shared stores.
    func providerBandContentProblems(_ expected: ExpectedDiagram) -> [String] {
        let document = expected.document
        var found: [String] = []
        for provider in expected.bandedProviders {
            let members = document.services.filter { $0.provider == provider }
            var ids = members.map { NodeID(kind: .service, id: $0.id) }
            ids += members.filter { expected.serviceStoresOwners.contains($0.id) }.map { NodeID(kind: .serviceStores, id: $0.id) }
            ids += document.stores.filter { $0.provider == provider && expected.sharedStores.contains($0.id) }.map { NodeID(kind: .sharedStore, id: $0.id) }
            let frames = ids.compactMap { frame(of: $0) }
            if !providerBands.contains(where: { $0.id == provider && frames.allSatisfy($0.frame.contains) }) {
                found.append("no band for \(provider) contains all of its cards")
            }
        }
        return found
    }

    /// Provider bands run top to bottom in provider order, each starting at or below the previous one's bottom.
    func providerBandStackingProblems(_ expected: ExpectedDiagram) -> [String] {
        let ordered = expected.bandedProviders.compactMap { id in providerBands.first { $0.id == id } }
        return zip(ordered, ordered.dropFirst()).compactMap { upper, lower in
            upper.frame.maxY <= lower.frame.y ? nil : "band \(lower.id) does not start below band \(upper.id)"
        }
    }

    /// Each shared store sits in its own provider's band, below every service and own-data card of that provider.
    func sharedStorePlacementProblems(_ expected: ExpectedDiagram) -> [String] {
        let document = expected.document
        var found: [String] = []
        for store in document.stores where expected.sharedStores.contains(store.id) {
            guard let card = frame(of: NodeID(kind: .sharedStore, id: store.id)) else {
                found.append("shared store \(store.id) is missing")
                continue
            }
            if !providerBands.contains(where: { $0.id == store.provider && $0.frame.contains(card) }) {
                found.append("shared store \(store.id) is outside the band of \(store.provider)")
            }
            let services = document.services.filter { $0.provider == store.provider }.map(\.id)
            let above = nodes.filter { [.service, .serviceStores].contains($0.nodeID.kind) && services.contains($0.nodeID.id) }
            found += above.filter { $0.frame.maxY > card.y }.map { "shared store \(store.id) is not below \($0.nodeID)" }
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

    /// Each scoped row segment has a band of its scope around exactly its services, inside its provider's band.
    func scopeRunProblems(_ expected: ExpectedDiagram) -> [String] {
        let serviceFrames = Dictionary(uniqueKeysWithValues: nodes.filter { $0.nodeID.kind == .service }.map { ($0.nodeID.id, $0.frame) })
        var found: [String] = []
        for row in expected.serviceRows {
            guard let scope = row.scope else { continue }
            let ids = Set(row.services.map(\.id))
            let frames = row.services.compactMap { serviceFrames[$0.id] }
            guard let band = scopeBands.first(where: { $0.id == scope && frames.allSatisfy($0.frame.contains) }) else {
                found.append("no \(scope) band contains \(ids.sorted())")
                continue
            }
            found += serviceFrames.filter { !ids.contains($0.key) && band.frame.intersects($0.value) }
                .map { "band \(scope) overlaps \($0.key)" }
            if !providerBands.contains(where: { $0.id == row.provider && $0.frame.contains(band.frame) }) {
                found.append("band \(scope) around \(ids.sorted()) is outside the band of \(row.provider)")
            }
        }
        return found
    }
}
