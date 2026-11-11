import StackmapKit
import Testing

@Suite("Left-to-right order of services")
struct LayoutOrderTests {
    let layout = DiagramLayout()

    @Test("services follow provider order, then first scope with unscoped last, then declaration order", arguments: LayoutFixture.all)
    func serviceOrder(fixture: LayoutFixture) {
        let geometry = layout.layout(fixture.document)
        let actual = geometry.servicesOrderedLeftToRight()
        let expected = ExpectedDiagram(fixture.document).serviceOrder.map(\.id)

        // Catches services left in declaration order, or sorted by label or id.
        #expect(actual == expected)
    }

    @Test("the scope ordering fixture puts scoped services first and unscoped last")
    func scopeOrderingIsExplicit() {
        let geometry = layout.layout(LayoutFixture.scopeOrdering.document)
        let actual = geometry.servicesOrderedLeftToRight()

        // Pins the rule by hand so it does not depend on the expectation helper.
        // Catches unscoped services being sorted first, or scope order following declaration order of services.
        #expect(actual == ["shop-a", "shop-b", "ops-a", "free-a", "free-b"])
    }

    @Test("provider order wins over scope order")
    func providerBeforeScope() {
        let geometry = layout.layout(LayoutFixture.scopedAcrossProviders.document)
        let actual = geometry.servicesOrderedLeftToRight()

        // Catches scope being the primary key, which would interleave providers.
        #expect(actual == ["edge-shop", "edge-ops", "cloud-shop", "cloud-ops"])
    }

    @Test("services of one provider are contiguous", arguments: LayoutFixture.all)
    func providersAreContiguous(fixture: LayoutFixture) {
        let providerOf = Dictionary(uniqueKeysWithValues: fixture.document.services.map { ($0.id, $0.provider) })
        let ordered = layout.layout(fixture.document).nodes
            .filter { $0.nodeID.kind == .service }
            .sorted { $0.frame.x < $1.frame.x }
            .compactMap { providerOf[$0.nodeID.id] }
        var seen: [String] = []
        for provider in ordered where seen.last != provider {
            seen.append(provider)
        }

        // Catches a provider split into several groups by another provider's services.
        #expect(Set(seen).count == seen.count)
    }
}
