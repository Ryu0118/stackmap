/// What a connector means.
package enum EdgeKind: String, Hashable, Sendable {
    /// A client calls a service.
    case call
    /// A service owns the data in its ``NodeKind/serviceStores`` card.
    case ownStores
    /// A service owns data in a ``NodeKind/sharedStore``.
    case sharedStore
}
