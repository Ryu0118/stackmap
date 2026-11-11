extension CardSizing {
    /// The height of one data line. The store chip sits inline at its start,
    /// so the text flows after it and wraps under it.
    func itemHeight(_ item: DataItem, showsStore: Bool) -> Int {
        let target = item.migration.map { " → \(storeLabel($0.to))" } ?? ""
        let width = showsStore ? Metrics.storesWidth - 30 : Metrics.sharedWidth - 31
        let chip = showsStore ? chipWidth(item.store) + 6 : 0
        let text = TextMeasure.ems(item.label + target) * 13.5
        let lines = max(1, Int(((Double(chip) + text) / Double(width)).rounded(.up)))
        return 24 + 20 * (lines - 1)
    }

    private func chipWidth(_ storeID: String) -> Int {
        Int((TextMeasure.ems(storeLabel(storeID)) * 11).rounded(.up)) + 12
    }
}
