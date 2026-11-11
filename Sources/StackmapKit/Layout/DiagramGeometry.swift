/// A fully positioned diagram. Every card and band lies inside `width` × `height`.
package struct DiagramGeometry: Hashable, Sendable {
    /// The canvas width.
    package var width: Int
    /// The canvas height.
    package var height: Int
    /// Every card.
    package var nodes: [DiagramNode]
    /// Every band, drawn behind the cards.
    package var bands: [DiagramBand]
    /// Every connector.
    package var edges: [DiagramEdge]

    /// Creates a geometry.
    package init(width: Int, height: Int, nodes: [DiagramNode], bands: [DiagramBand], edges: [DiagramEdge]) {
        self.width = width
        self.height = height
        self.nodes = nodes
        self.bands = bands
        self.edges = edges
    }
}
