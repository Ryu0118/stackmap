/// A labeled background rectangle that groups cards.
///
/// A provider can have two bands: one around its services and one at the
/// bottom around stores reached from other providers.
package struct DiagramBand: Hashable, Sendable {
    /// What the band groups.
    package var kind: BandKind
    /// The provider or scope id.
    package var id: String
    /// Where the band is drawn.
    package var frame: Rect

    /// Creates a band.
    package init(kind: BandKind, id: String, frame: Rect) {
        self.kind = kind
        self.id = id
        self.frame = frame
    }
}
