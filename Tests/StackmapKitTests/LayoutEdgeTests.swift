import StackmapKit
import Testing

@Suite("Connectors in the diagram")
struct LayoutEdgeTests {
    let layout = DiagramLayout()

    @Test("connectors are exactly the calls, own store links, and shared store links", arguments: LayoutFixture.all)
    func edgeSet(fixture: LayoutFixture) {
        let edges = layout.layout(fixture.document).edges
        let actual = edges.map { ExpectedDiagram.Link(kind: $0.kind, source: $0.source, target: $0.target) }

        // Catches a missing connector, a duplicate, or one with the wrong kind or endpoints.
        #expect(Set(actual) == ExpectedDiagram(fixture.document).links)
        #expect(actual.count == Set(actual).count)
    }

    @Test("a service owning data in several other-provider stores has one shared connector per store")
    func oneConnectorPerSharedStore() {
        let edges = layout.layout(LayoutFixture.manyOtherProviderStores.document).edges
        let fromApi = edges.filter { $0.kind == .sharedStore && $0.source == NodeID(kind: .service, id: "api") }

        // Catches several data items in one store drawing several connectors, or a store being skipped.
        #expect(Set(fromApi.map(\.target.id)) == ["docs", "blobs", "queue"])
        #expect(fromApi.count == 3)
    }

    @Test("every connector has contiguous axis-aligned segments", arguments: LayoutFixture.all)
    func segmentsAreWellFormed(fixture: LayoutFixture) {
        // Catches diagonal segments, gaps between segments, or an edge with nothing to draw.
        #expect(layout.layout(fixture.document).malformedSegments() == [])
    }

    @Test("a connector starts on the edge of its source card", arguments: LayoutFixture.all)
    func connectorsStartOnTheSourceOutline(fixture: LayoutFixture) {
        // Catches connectors that start in the middle of a card or in empty space.
        #expect(layout.layout(fixture.document).connectorsNotStartingOnSource() == [])
    }

    @Test("a connector ends just outside its target card", arguments: LayoutFixture.all)
    func connectorsEndJustOutsideTheTarget(fixture: LayoutFixture) {
        // Catches arrowheads buried inside the card, or stopping several pixels short of it.
        #expect(layout.layout(fixture.document).connectorsNotEndingNextToTarget() == [])
    }

    @Test("no connector passes through the inside of a card", arguments: LayoutFixture.all)
    func connectorsAvoidCardInteriors(fixture: LayoutFixture) {
        // Catches connectors drawn across unrelated cards, which hides text and misleads readers.
        #expect(layout.layout(fixture.document).connectorsCrossingCards() == [])
    }
}
