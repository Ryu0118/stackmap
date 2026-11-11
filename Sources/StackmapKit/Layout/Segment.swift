/// A straight, horizontal or vertical piece of a connector.
package struct Segment: Hashable, Sendable {
    /// Where the segment starts.
    package var start: Point
    /// Where the segment ends.
    package var end: Point

    /// Creates a segment.
    package init(start: Point, end: Point) {
        self.start = start
        self.end = end
    }
}
