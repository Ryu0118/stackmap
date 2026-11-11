/// Fixed sizes and gaps of the diagram, in pixels.
enum LayoutMetrics {
    static let margin = 32
    static let cardWidth = 208
    static let clientHeight = 64
    static let serviceHeight = 72
    static let storesOffset = 56
    static let storesWidth = 200
    static let columnWidth = storesOffset + storesWidth
    static let columnPitch = 304
    static let providerPitch = 352
    static let sharedWidth = 240
    static let lineHeight = 24
    static let bandPadding = 24
    static let providerLabelHeight = 40
    static let scopeLabelHeight = 36
    static let scopePadding = 12
    static let busGap = 24
    static let busStep = 12
    static let cardGap = 48
    static let laneStart = 12
    static let laneSpan = 28

    static func storesHeight(lines: Int) -> Int {
        lineHeight + lineHeight * lines
    }

    static func sharedHeight(lines: Int) -> Int {
        providerLabelHeight + lineHeight * lines + scopePadding
    }
}
