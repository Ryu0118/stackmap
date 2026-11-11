/// Assigns every client, service, and shared-store card a row and a column.
///
/// Rows follow the configuration guide: clients first, then one band per
/// provider with its service rows and then its shared-store rows. No row
/// holds more than ``LayoutMetrics/maxColumns`` cards.
struct GridPlan {
    let rows: [GridRow]
    let cells: [NodeID: GridCell]

    init(_ document: ScopedDocument, placement: DataPlacement, ordering: ServiceOrdering) {
        var rows = Self.chunk(document.clients.map { NodeID(kind: .client, id: $0.id) }) { GridRow(kind: .clients, nodes: $0) }
        let grouped = document.selection == .all && !document.scopes.isEmpty
        let placed = Set(placement.services.map(\.id))
        for provider in document.providers {
            // Ungrouped rows keep declaration order; grouped rows follow the first-scope ordering.
            let ordered = grouped ? placement.services : document.services.filter { placed.contains($0.id) }
            let services = ordered.filter { $0.provider == provider.id }
            for group in Self.groups(services, grouped: grouped, ordering: ordering) {
                let ids = group.services.map { NodeID(kind: .service, id: $0.id) }
                rows += Self.chunk(ids) { GridRow(kind: .services(provider: provider.id, scope: group.scope), nodes: $0) }
            }
            let shared = placement.sharedStores.filter { $0.provider == provider.id }.map { NodeID(kind: .sharedStore, id: $0.id) }
            rows += Self.chunk(shared) { GridRow(kind: .shared(provider: provider.id), nodes: $0) }
        }

        var cells: [NodeID: GridCell] = [:]
        for (rowIndex, row) in rows.enumerated() {
            for (column, node) in row.nodes.enumerated() {
                cells[node] = GridCell(row: rowIndex, column: column)
            }
        }
        self.rows = rows
        self.cells = cells
    }

    /// The number of columns the widest row uses.
    var columnCount: Int {
        rows.map(\.nodes.count).max() ?? 0
    }
}
