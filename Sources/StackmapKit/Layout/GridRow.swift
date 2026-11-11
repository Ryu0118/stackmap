/// One row of the grid and the cards in it, left to right.
struct GridRow: Equatable {
    /// What a row holds.
    enum Kind: Equatable {
        case clients
        /// Services of `provider`; `scope` is the scope band the row sits in, if any.
        case services(provider: String, scope: String?)
        case shared(provider: String)
    }

    let kind: Kind
    /// The client, service, or shared-store cards in the row.
    let nodes: [NodeID]

    /// The provider whose band holds this row, if any.
    var provider: String? {
        switch kind {
        case .clients: nil
        case let .services(provider, _), let .shared(provider): provider
        }
    }

    /// The scope band around this row, if any.
    var scope: String? {
        if case let .services(_, scope) = kind {
            scope
        } else {
            nil
        }
    }
}
