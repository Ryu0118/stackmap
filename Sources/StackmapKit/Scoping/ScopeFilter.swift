/// Narrows a document to one ``ScopeSelection``.
package struct ScopeFilter: Sendable {
    /// Creates a filter.
    package init() {}

    /// Returns the entries kept for `selection`.
    package func filter(_ document: StackmapDocument, selection: ScopeSelection) throws(ScopeFilterError) -> ScopedDocument {
        let scopes: [Scope]
        switch selection {
        case .all:
            scopes = document.scopes
        case let .scope(id):
            guard let scope = document.scopes.first(where: { $0.id == id }) else {
                throw ScopeFilterError.unknownScope(id)
            }
            scopes = [scope]
        }

        let serviceIDs = Set(document.services.filter { Self.belongs($0.scopes, to: selection) }.map(\.id))
        let services = document.services
            .filter { serviceIDs.contains($0.id) }
            .map { service in
                var kept = service
                kept.calls = service.calls.filter(serviceIDs.contains)
                return kept
            }
        let ownerScopes = Dictionary(document.services.map { ($0.id, $0.scopes) }, uniquingKeysWith: { first, _ in first })
        let data = document.data.filter { item in
            let effective = item.scopes.isEmpty ? ownerScopes[item.owner] ?? [] : item.scopes
            return serviceIDs.contains(item.owner) && Self.belongs(effective, to: selection)
        }
        let clients = document.clients
            .filter { Self.belongs($0.scopes, to: selection) }
            .map { client in
                var kept = client
                kept.calls = client.calls.filter(serviceIDs.contains)
                return kept
            }
        // The whole-system view keeps every declared store and provider, used or not.
        let storeIDs = Set(data.map(\.store))
        let stores = document.stores.filter { selection == .all || storeIDs.contains($0.id) }
        let providerIDs = Set(services.map(\.provider) + stores.map(\.provider))
        let providers = document.providers.filter { selection == .all || providerIDs.contains($0.id) }

        return ScopedDocument(
            selection: selection,
            title: document.title,
            scopes: scopes,
            providers: providers,
            stores: stores,
            clients: clients,
            services: services,
            data: data
        )
    }

    private static func belongs(_ scopes: [String], to selection: ScopeSelection) -> Bool {
        switch selection {
        case .all: true
        case let .scope(id): scopes.isEmpty || scopes.contains(id)
        }
    }
}
