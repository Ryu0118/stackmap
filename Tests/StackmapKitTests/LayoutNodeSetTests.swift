import StackmapKit
import Testing

@Suite("Which cards the diagram contains")
struct LayoutNodeSetTests {
    let layout = DiagramLayout()

    @Test("the cards are exactly clients, services, own-provider store cards, and shared stores", arguments: LayoutFixture.all)
    func nodeSetMatchesDocument(fixture: LayoutFixture) {
        let nodes = layout.layout(fixture.document).nodes
        let expected = ExpectedDiagram(fixture.document).nodeIDs

        // Catches missing or surplus cards of any kind.
        #expect(Set(nodes.map(\.nodeID)) == expected)
    }

    @Test("a service with no data gets no store card")
    func serviceWithoutDataHasNoStoreCard() {
        let geometry = layout.layout(LayoutFixture.singleService.document)

        // Catches an empty serviceStores card drawn for every service.
        #expect(geometry.nodes.map(\.nodeID) == [NodeID(kind: .service, id: "api")])
    }

    @Test("a store on another provider is one shared card however many services reach it")
    func sharedStoreIsOneCard() {
        let geometry = layout.layout(LayoutFixture.sharedStore.document)
        let shared = geometry.nodes.filter { $0.nodeID.kind == .sharedStore }

        // Catches one card per owning service instead of one per store.
        #expect(shared.map(\.nodeID) == [NodeID(kind: .sharedStore, id: "docs")])
    }

    @Test("a service whose data is only on its own provider gets no shared store")
    func ownProviderDataIsNotShared() {
        let geometry = layout.layout(LayoutFixture.noScopesDeclared.document)

        // Catches stores on the service's own provider being drawn as shared stores.
        #expect(geometry.frames(of: .sharedStore).isEmpty)
        #expect(geometry.frames(of: .serviceStores).count == 1)
    }

    @Test("a store used from its own provider and from another gets both a card under the service and a shared card")
    func storeReachedBothWays() {
        let geometry = layout.layout(LayoutFixture.multiProvider.document)
        let ids = Set(geometry.nodes.map(\.nodeID))

        // Catches the store being classified once, by the first service that uses it.
        #expect(ids.contains(NodeID(kind: .serviceStores, id: "api")))
        #expect(ids.contains(NodeID(kind: .sharedStore, id: "kv")))
        #expect(ids.contains(NodeID(kind: .sharedStore, id: "docs")))
        #expect(ids.contains(NodeID(kind: .serviceStores, id: "worker")))
    }
}
