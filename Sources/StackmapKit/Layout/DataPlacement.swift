/// Splits kept data into what each service lists under itself and what sits
/// in stores on other providers.
struct DataPlacement {
    /// Services in diagram order.
    let services: [Service]
    /// Data each service owns in stores on its own provider, by service id.
    let localData: [String: [DataItem]]
    /// Stores reached from another provider, by provider order then declaration order.
    let sharedStores: [Store]
    /// Data in each shared store owned from another provider, by store id.
    let sharedData: [String: [DataItem]]
    /// Shared store ids each service reaches, in ``sharedStores`` order, by service id.
    let reachedStores: [String: [String]]

    init(_ document: ScopedDocument) {
        let services = ServiceOrdering(document).ordered
        let storeByID = Dictionary(document.stores.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        let providerByService = Dictionary(services.map { ($0.id, $0.provider) }, uniquingKeysWith: { first, _ in first })

        var local: [String: [DataItem]] = [:]
        var shared: [String: [DataItem]] = [:]
        for item in document.data {
            guard let store = storeByID[item.store], let provider = providerByService[item.owner] else { continue }
            if store.provider == provider {
                local[item.owner, default: []].append(item)
            } else {
                shared[item.store, default: []].append(item)
            }
        }

        let providerRank = Dictionary(document.providers.enumerated().map { ($1.id, $0) }, uniquingKeysWith: { first, _ in first })
        let sharedStores = document.stores.enumerated()
            .filter { shared[$0.element.id] != nil }
            .sorted { (providerRank[$0.element.provider] ?? 0, $0.offset) < (providerRank[$1.element.provider] ?? 0, $1.offset) }
            .map(\.element)
        var reached: [String: [String]] = [:]
        for store in sharedStores {
            for owner in Self.unique(shared[store.id, default: []].map(\.owner)) {
                reached[owner, default: []].append(store.id)
            }
        }

        self.services = services
        localData = local
        self.sharedStores = sharedStores
        sharedData = shared
        reachedStores = reached
    }

    private static func unique(_ ids: [String]) -> [String] {
        var seen: Set<String> = []
        return ids.filter { seen.insert($0).inserted }
    }
}
