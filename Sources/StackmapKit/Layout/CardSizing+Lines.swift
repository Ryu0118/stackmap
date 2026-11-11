extension CardSizing {
    /// The height of one data line, which wraps beside its store chip when it has one.
    func itemHeight(_ item: DataItem, showsStore: Bool) -> Int {
        let target = item.migration.map { " → \(storeLabel($0.to))" } ?? ""
        let width = showsStore ? textWidthBesideChip(item.store) : Metrics.sharedWidth - 31
        let lines = TextMeasure.lines(item.label + target, fontSize: 13.5, width: width)
        return 24 + 20 * (lines - 1)
    }

    private func textWidthBesideChip(_ storeID: String) -> Int {
        let chip = Int((TextMeasure.ems(storeLabel(storeID)) * 11).rounded(.up)) + 12
        return max(40, Metrics.storesWidth - 30 - chip - 6)
    }
}
