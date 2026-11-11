/// An axis-aligned rectangle in diagram pixels; y grows downward.
package struct Rect: Hashable, Sendable {
    /// The left edge.
    package var x: Int
    /// The top edge.
    package var y: Int
    /// The width.
    package var width: Int
    /// The height.
    package var height: Int

    /// The right edge, `x + width`.
    package var maxX: Int {
        x + width
    }

    /// The bottom edge, `y + height`.
    package var maxY: Int {
        y + height
    }

    /// Creates a rectangle.
    package init(x: Int, y: Int, width: Int, height: Int) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }

    /// Whether the interiors overlap; touching edges do not count.
    package func intersects(_ other: Rect) -> Bool {
        x < other.maxX && other.x < maxX && y < other.maxY && other.y < maxY
    }

    /// Whether `other` lies entirely inside this rectangle, edges included.
    package func contains(_ other: Rect) -> Bool {
        x <= other.x && y <= other.y && other.maxX <= maxX && other.maxY <= maxY
    }
}
