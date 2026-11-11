/// Lookups shared by every section of one page.
struct RenderContext {
    let document: StackmapDocument
    private let scopeLabels: [String: String]
    private let storeLabels: [String: String]
    private let serviceLabels: [String: String]
    private let providerLabels: [String: String]
    private let ownerScopes: [String: [String]]
    private let storeColors: [String: Int]

    init(_ document: StackmapDocument) {
        self.document = document
        scopeLabels = Self.index(document.scopes.map { ($0.id, $0.label) })
        storeLabels = Self.index(document.stores.map { ($0.id, $0.label) })
        serviceLabels = Self.index(document.services.map { ($0.id, $0.label) })
        providerLabels = Self.index(document.providers.map { ($0.id, $0.label) })
        ownerScopes = Self.index(document.services.map { ($0.id, $0.scopes) })
        storeColors = Self.index(document.stores.enumerated().map { ($1.id, $0 % 8) })
    }

    func scopeLabel(_ id: String) -> String {
        scopeLabels[id] ?? id
    }

    func storeLabel(_ id: String) -> String {
        storeLabels[id] ?? id
    }

    func serviceLabel(_ id: String) -> String {
        serviceLabels[id] ?? id
    }

    func providerLabel(_ id: String) -> String {
        providerLabels[id] ?? id
    }

    func storeColor(_ id: String) -> Int {
        storeColors[id] ?? 0
    }

    /// The data's scopes, or its owner's when it declares none.
    func effectiveScopes(of item: DataItem) -> [String] {
        item.scopes.isEmpty ? ownerScopes[item.owner] ?? [] : item.scopes
    }

    private static func index<Value>(_ pairs: [(String, Value)]) -> [String: Value] {
        Dictionary(pairs, uniquingKeysWith: { first, _ in first })
    }
}
