/// A routed connector before it has coordinates.
struct Connector: Equatable {
    let kind: EdgeKind
    let source: NodeID
    let target: NodeID

    /// Every routed connector in drawing order: client calls, then each
    /// service's calls and shared stores in diagram order. Repeated calls are
    /// dropped, and so are connectors to cards that are not on the grid.
    static func all(_ document: ScopedDocument, placement: DataPlacement, cells: [NodeID: GridCell]) -> [Connector] {
        var result: [Connector] = []
        for client in document.clients {
            let source = NodeID(kind: .client, id: client.id)
            result += unique(client.calls).map { Connector(kind: .call, source: source, target: NodeID(kind: .service, id: $0)) }
        }
        for service in placement.services {
            let source = NodeID(kind: .service, id: service.id)
            let calls = unique(service.calls).filter { $0 != service.id }
            result += calls.map { Connector(kind: .serviceCall, source: source, target: NodeID(kind: .service, id: $0)) }
            let stores = placement.reachedStores[service.id, default: []]
            result += stores.map { Connector(kind: .sharedStore, source: source, target: NodeID(kind: .sharedStore, id: $0)) }
        }
        return result.filter { cells[$0.source] != nil && cells[$0.target] != nil }
    }

    private static func unique(_ ids: [String]) -> [String] {
        var seen: Set<String> = []
        return ids.filter { seen.insert($0).inserted }
    }
}
