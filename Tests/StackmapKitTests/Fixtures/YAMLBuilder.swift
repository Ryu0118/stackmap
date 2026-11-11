/// A small valid stack map file whose individual fields can be broken one at a time.
struct YAMLBuilder: Sendable {
    var topLevelExtra = ""
    var scopeExtra = ""
    var storeProvider = "edge"
    var storeExtra = ""
    var clientCalls = "[api]"
    var clientScopes = "[shop]"
    var serviceProvider = "edge"
    var serviceScopes = "[shop]"
    var serviceExtra = ""
    var dataStore = "docs"
    var dataOwner = "api"
    var dataScopes = "[shop]"
    var dataExtra = ""

    var yaml: String {
        """
        version: 1
        \(topLevelExtra)
        scopes:
          - id: shop
            label: Shop
            \(scopeExtra)
        providers:
          - id: edge
            label: Edge
        stores:
          - id: sql
            label: SQL
            provider: \(storeProvider)
            \(storeExtra)
          - id: docs
            label: Docs
            provider: edge
        clients:
          - id: mobile
            label: Mobile
            scopes: \(clientScopes)
            calls: \(clientCalls)
        services:
          - id: api
            label: API
            provider: \(serviceProvider)
            scopes: \(serviceScopes)
            \(serviceExtra)
        data:
          - id: orders
            label: Orders
            store: \(dataStore)
            owner: \(dataOwner)
            scopes: \(dataScopes)
            \(dataExtra)
        """
    }

    func with(_ change: (inout YAMLBuilder) -> Void) -> YAMLBuilder {
        var copy = self
        change(&copy)
        return copy
    }
}
