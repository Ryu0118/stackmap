/// A piece of data, the store it lives in, and the service that owns it.
package struct DataItem: Equatable, Sendable {
    /// The data id.
    package var id: String
    /// The label shown in cards and the list.
    package var label: String
    /// The id of the store that holds the data.
    package var store: String
    /// The id of the owning service.
    package var owner: String
    /// Scope ids as written; empty means the owner's scopes.
    package var scopes: [String]
    /// Table, collection, binding, or key names.
    package var identifiers: [String]
    /// Whether the data is live, planned, or moving.
    package var status: DataStatus
    /// Where the data is moving; set only when ``status`` is ``DataStatus/migrating``.
    package var migration: Migration?

    /// Creates a data item.
    package init(
        id: String,
        label: String,
        store: String,
        owner: String,
        scopes: [String] = [],
        identifiers: [String] = [],
        status: DataStatus = .live,
        migration: Migration? = nil
    ) {
        self.id = id
        self.label = label
        self.store = store
        self.owner = owner
        self.scopes = scopes
        self.identifiers = identifiers
        self.status = status
        self.migration = migration
    }
}
