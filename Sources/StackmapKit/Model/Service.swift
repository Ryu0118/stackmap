/// A deployable service on a provider.
package struct Service: Equatable, Sendable {
    /// The service id.
    package var id: String
    /// The label shown on the card.
    package var label: String
    /// An optional second line on the card.
    package var description: String?
    /// The id of the provider that hosts the service.
    package var provider: String
    /// Scope ids as written; empty means every scope.
    package var scopes: [String]
    /// Ids of other services this service calls, in the order written.
    package var calls: [String]

    /// Creates a service.
    package init(id: String, label: String, description: String? = nil, provider: String, scopes: [String] = [], calls: [String] = []) {
        self.id = id
        self.label = label
        self.description = description
        self.provider = provider
        self.scopes = scopes
        self.calls = calls
    }
}
