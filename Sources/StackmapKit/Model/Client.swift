/// Something outside the providers that calls services.
package struct Client: Equatable, Sendable {
    /// The client id.
    package var id: String
    /// The label shown on the card.
    package var label: String
    /// An optional second line on the card.
    package var description: String?
    /// Scope ids as written; empty means every scope.
    package var scopes: [String]
    /// Ids of the services the client calls.
    package var calls: [String]

    /// Creates a client.
    package init(id: String, label: String, description: String? = nil, scopes: [String] = [], calls: [String] = []) {
        self.id = id
        self.label = label
        self.description = description
        self.scopes = scopes
        self.calls = calls
    }
}
