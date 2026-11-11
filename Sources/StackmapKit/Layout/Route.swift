/// The gaps and channel a connector passes through, by index.
struct Route {
    let exitGap: Int
    let entryGap: Int
    /// The channel used to cross rows, or `nil` when the target is in the row right below.
    let channel: Int?

    init(_ connector: Connector, plan: GridPlan) {
        let source = plan.cells[connector.source] ?? GridCell(row: 0, column: 0)
        let target = plan.cells[connector.target] ?? GridCell(row: 0, column: 0)
        exitGap = source.row + 1
        entryGap = target.row
        channel = exitGap == entryGap ? nil : target.column
    }
}
