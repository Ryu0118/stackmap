/// A validated stack map file.
package struct StackmapDocument: Equatable, Sendable {
    /// The page title.
    package var title: String
    /// Scopes in declaration order.
    package var scopes: [Scope]
    /// Providers in declaration order.
    package var providers: [Provider]
    /// Stores in declaration order.
    package var stores: [Store]
    /// Clients in declaration order.
    package var clients: [Client]
    /// Services in declaration order.
    package var services: [Service]
    /// Data in declaration order.
    package var data: [DataItem]

    /// Creates a document from already validated parts.
    package init(
        title: String = "Stack Map",
        scopes: [Scope] = [],
        providers: [Provider] = [],
        stores: [Store] = [],
        clients: [Client] = [],
        services: [Service] = [],
        data: [DataItem] = []
    ) {
        self.title = title
        self.scopes = scopes
        self.providers = providers
        self.stores = stores
        self.clients = clients
        self.services = services
        self.data = data
    }
}
