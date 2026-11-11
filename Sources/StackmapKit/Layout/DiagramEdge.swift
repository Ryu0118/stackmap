/// A connector drawn as connected, axis-aligned segments with an arrowhead at the end.
///
/// The first segment starts on the source card's edge; the last ends one
/// pixel outside the target card's edge. Several edges may share leading
/// segments where connectors fan out or merge.
package struct DiagramEdge: Hashable, Sendable {
    /// What the connector means.
    package var kind: EdgeKind
    /// The card the connector leaves.
    package var source: NodeID
    /// The card the arrowhead points at.
    package var target: NodeID
    /// The segments from source to target, each starting where the previous ended.
    package var segments: [Segment]

    /// Creates an edge.
    package init(kind: EdgeKind, source: NodeID, target: NodeID, segments: [Segment]) {
        self.kind = kind
        self.source = source
        self.target = target
        self.segments = segments
    }
}
