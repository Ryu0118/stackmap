/// Identifies one card in a diagram.
package struct NodeID: Hashable, Sendable {
    /// What the card represents.
    package var kind: NodeKind
    /// The id of the entry the card represents; see ``NodeKind``.
    package var id: String

    /// Creates a node id.
    package init(kind: NodeKind, id: String) {
        self.kind = kind
        self.id = id
    }
}
