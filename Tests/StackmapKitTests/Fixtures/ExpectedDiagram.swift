import StackmapKit

/// What a correct layout must contain, derived from the scoped document alone.
struct ExpectedDiagram {
    struct Link: Hashable {
        var kind: EdgeKind
        var source: NodeID
        var target: NodeID
    }

    /// One row of services in a provider band, with the scope band it sits in, if any.
    struct ServiceRow {
        var provider: String
        var scope: String?
        var services: [Service]
    }

    static let rowCapacity = 4

    let document: ScopedDocument
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

    /// Whether services are grouped by first scope and scope bands are expected:
    /// only for the whole system when scopes are declared.
    var expectsScopeBands: Bool {
        document.selection == .all && !document.scopes.isEmpty
    }

    /// Providers that get a band: those hosting a service or a shared store, in declaration order.
    var bandedProviders: [String] {
        let storeProviders = Set(document.stores.filter { sharedStores.contains($0.id) }.map(\.provider))
        let serviceProviders = Set(document.services.map(\.provider))
        return document.providers.map(\.id).filter { storeProviders.contains($0) || serviceProviders.contains($0) }
    }

    /// Client ids, four to a row, in declaration order.
    var clientRows: [[String]] {
        document.clients.map(\.id).chunked(by: Self.rowCapacity)
    }

    /// Every service row, top to bottom: providers in order, then groups by first scope, each wrapping after four.
    var serviceRows: [ServiceRow] {
        bandedProviders.flatMap { provider in
            groups(on: provider).flatMap { group in
                group.services.chunked(by: Self.rowCapacity).map { ServiceRow(provider: provider, scope: group.scope, services: $0) }
            }
        }
    }

    /// Services in reading order (row by row, left to right).
    var serviceOrder: [Service] {
        serviceRows.flatMap(\.services)
    }

    /// Row segments that sit in a scope band.
    var scopeRuns: [(scope: String, services: [Service])] {
        serviceRows.compactMap { row in row.scope.map { ($0, row.services) } }
    }

    /// Shared store ids per provider, four to a row, in store declaration order.
    var sharedStoreRows: [[String]] {
        bandedProviders.flatMap { provider in
            document.stores.filter { $0.provider == provider && sharedStores.contains($0.id) }.map(\.id).chunked(by: Self.rowCapacity)
        }
    }

    init(_ document: ScopedDocument) {
        self.document = document
        let providerOfStore = Dictionary(uniqueKeysWithValues: document.stores.map { ($0.id, $0.provider) })
        let providerOfService = Dictionary(uniqueKeysWithValues: document.services.map { ($0.id, $0.provider) })

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
        for service in document.services {
            for call in service.calls {
                links.insert(Link(kind: .serviceCall, source: NodeID(kind: .service, id: service.id), target: NodeID(kind: .service, id: call)))
            }
        }
        serviceStoresOwners = own
        sharedStores = shared
        self.links = links
    }

    /// The service groups of one provider. Without grouping there is one group in declaration order.
    private func groups(on provider: String) -> [(scope: String?, services: [Service])] {
        let services = document.services.filter { $0.provider == provider }
        guard expectsScopeBands else {
            return services.isEmpty ? [] : [(nil, services)]
        }
        let ranked: [String?] = document.scopes.map(\.id) + [nil]
        return ranked.compactMap { scope in
            let members = services.filter { $0.scopes.first == scope }
            return members.isEmpty ? nil : (scope, members)
        }
    }
}

extension Array {
    func chunked(by size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map { Array(self[$0 ..< Swift.min($0 + size, count)]) }
    }
}
