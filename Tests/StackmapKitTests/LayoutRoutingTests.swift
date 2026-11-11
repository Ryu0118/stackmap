import StackmapKit
import Testing

@Suite("Connector routing rules")
struct LayoutRoutingTests {
    let layout = DiagramLayout()

    @Test("calls, service calls, and shared store links leave the bottom of their source", arguments: LayoutFixture.all)
    func leaveFromTheBottom(fixture: LayoutFixture) {
        // Catches connectors leaving from a side or the top of a card.
        #expect(layout.layout(fixture.document).connectorsNotLeavingSourceBottom() == [])
    }

    @Test("every connector ends one pixel above the top of its target", arguments: LayoutFixture.all)
    func endAboveTheTop(fixture: LayoutFixture) {
        // Catches arrowheads that reach a card from the side or below, for example for a target in a row above.
        #expect(layout.layout(fixture.document).connectorsNotEndingAboveTargetTop() == [])
    }

    @Test("a service is joined to its own data card by one straight segment", arguments: LayoutFixture.all)
    func ownStoresAreStraight(fixture: LayoutFixture) {
        // Catches the own-data connector being routed around like the other kinds.
        #expect(layout.layout(fixture.document).crookedOwnStoreConnectors() == [])
    }

    @Test("different connectors never run along the same line unless they come from one client", arguments: LayoutFixture.all)
    func noSharedLines(fixture: LayoutFixture) {
        // Catches connectors stacked on one channel or row gap so that a reader cannot tell them apart.
        #expect(layout.layout(fixture.document).collinearConnectorOverlaps() == [])
    }

    @Test("connectors from one client leave from one point", arguments: LayoutFixture.all)
    func clientConnectorsShareAStart(fixture: LayoutFixture) {
        // Catches a client's bus split into separate starting points.
        #expect(layout.layout(fixture.document).clientConnectorsWithSplitStarts() == [])
    }

    @Test("connectors from one client share their first horizontal run", arguments: LayoutFixture.all)
    func clientConnectorsShareABus(fixture: LayoutFixture) {
        // Catches each client connector getting its own lane in the gap below the client, which splits the bus.
        #expect(layout.layout(fixture.document).clientBusesSplitAcrossLines() == [])
    }

    @Test("a client calling services in different columns runs its connectors along one line")
    func clientBusIsOneLine() {
        let geometry = layout.layout(ScopedDocument(keeping: ConnectorHTMLFixtures.document))
        let runs = geometry.firstHorizontalRuns(from: NodeID(kind: .client, id: "mobile"))

        // Catches the bus split into one lane per connector; the count guards against a fixture with nothing to compare.
        #expect(runs.count >= 2)
        #expect(Set(runs).count == 1)
    }

    @Test("a service's connectors leave from separate points on the left half of its bottom", arguments: LayoutFixture.all)
    func serviceExitPoints(fixture: LayoutFixture) {
        // Catches several connectors leaving one point, or leaving from the right where the own-data link runs.
        #expect(layout.layout(fixture.document).serviceExitPointProblems() == [])
    }

    @Test("connectors into one card arrive at separate points", arguments: LayoutFixture.all)
    func separateEntryPoints(fixture: LayoutFixture) {
        // Catches arrowheads drawn on top of each other at the middle of the target.
        #expect(layout.layout(fixture.document).sharedEntryPoints() == [])
    }
}
