/// A point in diagram pixels; y grows downward.
package struct Point: Hashable, Sendable {
    /// The horizontal position.
    package var x: Int
    /// The vertical position.
    package var y: Int

    /// Creates a point.
    package init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
}
