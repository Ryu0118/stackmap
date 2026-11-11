extension GridCoordinates {
    /// Walks the rows top to bottom, leaving room for each gap's lanes and each band's label and padding.
    mutating func placeRows(_ plan: GridPlan, lanes: LaneTable, rowHeights: [Int]) {
        var y = Metrics.margin
        var bandStart: (top: Int, row: Int)?
        for (index, row) in plan.rows.enumerated() {
            gapTop.append(y)
            y += gapHeight(index, lanes: lanes, rows: plan.rows.count)
            if row.provider != nil, index == 0 || plan.rows[index - 1].provider != row.provider {
                bandStart = (y, index)
                y += Metrics.providerLabelHeight
            }
            let scopeTop = y
            y += row.scope == nil ? (row.provider == nil ? 0 : Metrics.scopePadding) : Metrics.scopeLabelHeight
            rowY.append(y)
            y += rowHeights[index]
            if let scope = row.scope {
                y += Metrics.scopePadding
                addBand(.scope, scope, columns: row.nodes.count, top: scopeTop, bottom: y, padding: Metrics.scopePadding)
            }
            if let start = bandStart, let provider = row.provider, index == plan.rows.count - 1 || plan.rows[index + 1].provider != provider {
                y += Metrics.bandPadding
                let columns = plan.rows[start.row ... index].map(\.nodes.count).max() ?? 1
                addBand(.provider, provider, columns: columns, top: start.top, bottom: y, padding: Metrics.bandPadding)
                bandStart = nil
            }
        }
        gapTop.append(y)
        y += gapHeight(plan.rows.count, lanes: lanes, rows: plan.rows.count)
        height = y + Metrics.margin
    }

    private mutating func addBand(_ kind: BandKind, _ id: String, columns: Int, top: Int, bottom: Int, padding: Int) {
        let edges = span(columns: columns, padding: padding)
        let band = DiagramBand(kind: kind, id: id, frame: Rect(x: edges.left, y: top, width: edges.right - edges.left, height: bottom - top))
        switch kind {
        case .provider: providerBands.append(band)
        case .scope: scopeBands.append(band)
        }
    }
}
