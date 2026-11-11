/// Conservative estimates of how much room text needs on a card.
///
/// A wide or fullwidth character counts as one em and any other character
/// as 0.65 em, which is at least as wide as the system fonts draw them, so
/// an estimate errs toward too many lines.
enum TextMeasure {
    /// How many lines `text` takes at `fontSize` pixels when wrapped to `width` pixels.
    static func lines(_ text: String, fontSize: Double, width: Int) -> Int {
        guard width > 0 else { return 1 }

        let needed = ems(text) * fontSize / Double(width)
        return max(1, Int(needed.rounded(.up)))
    }

    /// The estimated width of `text` in ems.
    static func ems(_ text: String) -> Double {
        text.unicodeScalars.reduce(0) { $0 + (isWide($1) ? 1 : 0.65) }
    }

    private static let wideRanges: [ClosedRange<UInt32>] = [
        0x1100 ... 0x115F, 0x2190 ... 0x21FF, 0x2E80 ... 0xA4CF, 0xAC00 ... 0xD7A3,
        0xF900 ... 0xFAFF, 0xFE30 ... 0xFE4F, 0xFF00 ... 0xFF60, 0xFFE0 ... 0xFFE6,
        0x1F300 ... 0x1FAFF, 0x20000 ... 0x3FFFD,
    ]

    private static func isWide(_ scalar: Unicode.Scalar) -> Bool {
        wideRanges.contains { $0.contains(scalar.value) }
    }
}
