extension GridPlan {
    /// Consecutive services that share a scope band, or one group when bands are off.
    static func groups(_ services: [Service], grouped: Bool, ordering: ServiceOrdering) -> [(scope: String?, services: [Service])] {
        guard grouped else { return services.isEmpty ? [] : [(nil, services)] }

        var result: [(scope: String?, services: [Service])] = []
        for service in services {
            let scope = ordering.bandScope(of: service)
            if let last = result.last, last.scope == scope {
                result[result.count - 1].services.append(service)
            } else {
                result.append((scope, [service]))
            }
        }
        return result
    }

    static func chunk(_ nodes: [NodeID], into row: ([NodeID]) -> GridRow) -> [GridRow] {
        stride(from: 0, to: nodes.count, by: LayoutMetrics.maxColumns).map { start in
            row(Array(nodes[start ..< min(start + LayoutMetrics.maxColumns, nodes.count)]))
        }
    }
}
