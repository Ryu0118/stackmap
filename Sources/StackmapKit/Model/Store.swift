/// A storage product on a provider.
package struct Store: Equatable, Sendable {
    /// The store id.
    package var id: String
    /// The label shown on cards and tags.
    package var label: String
    /// The id of the provider that hosts the store.
    package var provider: String

    /// Creates a store.
    package init(id: String, label: String, provider: String) {
        self.id = id
        self.label = label
        self.provider = provider
    }
}
