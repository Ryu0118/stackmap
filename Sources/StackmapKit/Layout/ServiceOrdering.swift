/// Orders services left to right: by provider, then by first scope (unscoped
/// last), then by declaration order.
struct ServiceOrdering {
    let ordered: [Service]
    private let scopeRank: [String: Int]

    init(_ document: ScopedDocument) {
        let providerRank = Self.rank(document.providers.map(\.id))
        let scopeRank = Self.rank(document.scopes.map(\.id))
        let unscoped = document.scopes.count

        ordered = document.services.enumerated()
            .sorted { lhs, rhs in
                let left = (providerRank[lhs.element.provider] ?? 0, Self.firstScopeRank(lhs.element, scopeRank, unscoped), lhs.offset)
                let right = (providerRank[rhs.element.provider] ?? 0, Self.firstScopeRank(rhs.element, scopeRank, unscoped), rhs.offset)
                return left < right
            }
            .map(\.element)
        self.scopeRank = scopeRank
    }

    /// The scope a service's band is drawn for, if its first scope is shown.
    func bandScope(of service: Service) -> String? {
        guard let first = service.scopes.first, scopeRank[first] != nil else { return nil }

        return first
    }

    private static func firstScopeRank(_ service: Service, _ ranks: [String: Int], _ unscoped: Int) -> Int {
        service.scopes.first.flatMap { ranks[$0] } ?? unscoped
    }

    private static func rank(_ ids: [String]) -> [String: Int] {
        Dictionary(ids.enumerated().map { ($1, $0) }, uniquingKeysWith: { first, _ in first })
    }
}
