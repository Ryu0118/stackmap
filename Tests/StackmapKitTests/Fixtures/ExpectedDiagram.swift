import StackmapKit

/// What a correct layout must contain, derived from the scoped document alone.
struct ExpectedDiagram {
    struct Link: Hashable {
        var kind: EdgeKind
        var source: NodeID
        var target: NodeID
    }

    let document: ScopedDocument
    let serviceOrder: [Service]
    let serviceStoresOwners: Set<String>
    let sharedStores: Set<String>
    let links: Set<Link>

    var nodeIDs: Set<NodeID> {
        var ids = Set(document.clients.map { NodeID(kind: .client, id: $0.id) })
        ids.formUnion(document.services.map { NodeID(kind: .service, id: $0.id) })
        ids.formUnion(serviceStoresOwners.map { NodeID(kind: .serviceStores, id: $0) })
        ids.formUnion(sharedStores.map { NodeID(kind: .sharedStore, id: $0) })
        return ids
    }

    /// Whether scope bands are expected: only for the whole system when scopes are declared.
    var expectsScopeBands: Bool {
        document.selection == .all && !document.scopes.isEmpty
    }

    /// Runs of consecutive services in layout order that share a first scope; unscoped services start no run.
    var scopeRuns: [(scope: String, services: [Service])] {
        guard expectsScopeBands else { return [] }
        var runs: [(scope: String, services: [Service])] = []
        var previous: String?
        for service in serviceOrder {
            let scope = service.scopes.first
            if let scope, scope == previous, !runs.isEmpty {
                runs[runs.count - 1].services.append(service)
            } else if let scope {
                runs.append((scope, [service]))
            }
            previous = scope
        }
        return runs
    }

    init(_ document: ScopedDocument) {
        self.document = document
        let providerOfStore = Dictionary(uniqueKeysWithValues: document.stores.map { ($0.id, $0.provider) })
        let providerOfService = Dictionary(uniqueKeysWithValues: document.services.map { ($0.id, $0.provider) })
        let providerRank = Dictionary(uniqueKeysWithValues: document.providers.enumerated().map { ($1.id, $0) })
        let scopeRank = Dictionary(uniqueKeysWithValues: document.scopes.enumerated().map { ($1.id, $0) })

        serviceOrder = document.services.enumerated().sorted { lhs, rhs in
            let left = [providerRank[lhs.element.provider] ?? .max, lhs.element.scopes.first.flatMap { scopeRank[$0] } ?? .max, lhs.offset]
            let right = [providerRank[rhs.element.provider] ?? .max, rhs.element.scopes.first.flatMap { scopeRank[$0] } ?? .max, rhs.offset]
            return left.lexicographicallyPrecedes(right)
        }.map(\.element)

        var own: Set<String> = []
        var shared: Set<String> = []
        var links: Set<Link> = []
        for item in document.data {
            guard let ownerProvider = providerOfService[item.owner], let storeProvider = providerOfStore[item.store] else { continue }
            let service = NodeID(kind: .service, id: item.owner)
            if ownerProvider == storeProvider {
                own.insert(item.owner)
                links.insert(Link(kind: .ownStores, source: service, target: NodeID(kind: .serviceStores, id: item.owner)))
            } else {
                shared.insert(item.store)
                links.insert(Link(kind: .sharedStore, source: service, target: NodeID(kind: .sharedStore, id: item.store)))
            }
        }
        for client in document.clients {
            for call in client.calls {
                links.insert(Link(kind: .call, source: NodeID(kind: .client, id: client.id), target: NodeID(kind: .service, id: call)))
            }
        }
        serviceStoresOwners = own
        sharedStores = shared
        self.links = links
    }
}
