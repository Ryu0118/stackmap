/// Pixel positions of the grid: column and channel edges, gap and row tops, and bands.
struct GridCoordinates {
    typealias Metrics = LayoutMetrics
    var gapTop: [Int] = []
    var rowY: [Int] = []
    var providerBands: [DiagramBand] = []
    var scopeBands: [DiagramBand] = []
    var height = 0

    private(set) var columnX: [Int] = []
    private(set) var channelLeft: [Int] = []
    private(set) var width = 0

    init(plan: GridPlan, lanes: LaneTable, rowHeights: [Int]) {
        placeColumns(count: max(plan.columnCount, 1), lanes: lanes)
        placeRows(plan, lanes: lanes, rowHeights: rowHeights)
    }

    private mutating func placeColumns(count: Int, lanes: LaneTable) {
        var x = Metrics.margin
        for column in 0 ..< count {
            channelLeft.append(x)
            x += max(Metrics.minChannelWidth, (lanes.channelLaneCounts[column] + 1) * Metrics.channelLaneStep)
            columnX.append(x)
            x += Metrics.columnWidth
        }
        width = x + Metrics.bandPadding + Metrics.margin
    }

    func gapHeight(_ gap: Int, lanes: LaneTable, rows: Int) -> Int {
        let count = lanes.gapLaneCounts[gap]
        let needed = count == 0 ? 0 : (count + 1) * Metrics.laneStep
        return gap == 0 || gap == rows ? needed : max(Metrics.cardGap, needed)
    }

    /// Provider bands first, so scope bands draw on top of them.
    var bands: [DiagramBand] {
        providerBands + scopeBands
    }

    /// The left and right edges of a band around columns `0 ..< columns`, grown by `padding`.
    func span(columns: Int, padding: Int) -> (left: Int, right: Int) {
        (columnX[0] - padding, columnX[max(columns, 1) - 1] + Metrics.columnWidth + padding)
    }
}
