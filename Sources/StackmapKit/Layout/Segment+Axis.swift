extension Segment {
    static func vertical(_ x: Int, from startY: Int, to endY: Int) -> Segment {
        Segment(start: Point(x: x, y: startY), end: Point(x: x, y: endY))
    }

    static func horizontal(_ y: Int, from startX: Int, to endX: Int) -> Segment {
        Segment(start: Point(x: startX, y: y), end: Point(x: endX, y: y))
    }
}
