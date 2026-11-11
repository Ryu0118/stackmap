/// A labeled background rectangle that groups cards.
///
/// Each provider has one band around its services and its shared stores.
/// A scope band wraps one row segment of services with the same first scope.
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
