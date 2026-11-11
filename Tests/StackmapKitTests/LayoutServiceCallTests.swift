import StackmapKit
import Testing

@Suite("Service-to-service call connectors")
struct LayoutServiceCallTests {
    let layout = DiagramLayout()

    private func links(_ fixture: LayoutFixture, kind: EdgeKind) -> [String] {
        layout.layout(fixture.document).edges.filter { $0.kind == kind }.map { "\($0.source.id)>\($0.target.id)" }.sorted()
    }

    @Test("each service call becomes one service-call connector")
    func callsBecomeConnectors() {
        // Catches service calls being dropped or drawn as client calls.
        #expect(links(LayoutFixture.callToNextRow, kind: .serviceCall) == ["b>e", "b>f", "c>b", "d>e"])
        #expect(links(LayoutFixture.callToNeighbor, kind: .serviceCall) == ["a>b", "c>b"])
    }

    @Test("two services calling each other get two connectors")
    func mutualCallsAreBothDrawn() {
        // Catches the second direction being merged into the first.
        #expect(links(LayoutFixture.mutualCalls, kind: .serviceCall) == ["a>b", "b>a"])
    }

    @Test("a repeated id in a service's or client's calls is drawn once")
    func repeatedCallsAreDrawnOnce() {
        // Catches one connector per entry of calls, which draws identical connectors on top of each other.
        #expect(links(LayoutFixture.repeatedCalls, kind: .serviceCall) == ["api>bot"])
        #expect(links(LayoutFixture.repeatedCalls, kind: .call) == ["web>api", "web>bot"])
    }

    @Test("a call to a service in an earlier provider band reaches the target above")
    func upwardCallReachesTarget() throws {
        let geometry = layout.layout(LayoutFixture.callUpward.document)
        let edge = try #require(geometry.edges.first { $0.kind == .serviceCall && $0.target.id == "api" })
        let target = try #require(geometry.frame(of: edge.target))
        let source = try #require(geometry.frame(of: edge.source))

        // Catches an upward call routed only downward, ending near the bottom of the target or not at all.
        #expect(target.maxY < source.y)
        #expect(edge.segments.last?.end.y == target.y - 1)
    }
}
