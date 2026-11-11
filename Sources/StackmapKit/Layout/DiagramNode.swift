/// A positioned card.
package struct DiagramNode: Hashable, Sendable {
    /// Which card this is.
    package var nodeID: NodeID
    /// Where the card is drawn.
    package var frame: Rect

    /// Creates a node.
    package init(nodeID: NodeID, frame: Rect) {
        self.nodeID = nodeID
        self.frame = frame
    }
}
