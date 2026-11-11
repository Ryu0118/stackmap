/// The entries of a document kept for one ``ScopeSelection``, in declaration order.
package struct ScopedDocument: Equatable, Sendable {
    /// The selection this view was built for.
    package var selection: ScopeSelection
    /// The page title.
    package var title: String
    /// Every declared scope for `.all`; only the selected scope otherwise.
    package var scopes: [Scope]
    /// Providers that host a kept service or store.
    package var providers: [Provider]
    /// Stores that hold kept data.
    package var stores: [Store]
    /// Kept clients, with calls to dropped services removed.
    package var clients: [Client]
    /// Kept services.
    package var services: [Service]
    /// Kept data.
    package var data: [DataItem]

    /// Creates a scoped view from already filtered parts.
    package init(
        selection: ScopeSelection,
        title: String,
        scopes: [Scope],
        providers: [Provider],
        stores: [Store],
        clients: [Client],
        services: [Service],
        data: [DataItem]
    ) {
        self.selection = selection
        self.title = title
        self.scopes = scopes
        self.providers = providers
        self.stores = stores
        self.clients = clients
        self.services = services
        self.data = data
    }
}
