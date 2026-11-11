/// What a diagram card represents.
package enum NodeKind: String, Hashable, Sendable {
    /// A client; its id is the client id.
    case client
    /// A service; its id is the service id.
    case service
    /// The card under a service listing its data on its own provider; its id is the service id.
    case serviceStores
    /// A store holding data owned by a service on another provider, drawn in its own provider's band; its id is the store id.
    case sharedStore
}
