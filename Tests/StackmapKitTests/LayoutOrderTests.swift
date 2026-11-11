import StackmapKit
import Testing

@Suite("Reading order of services")
struct LayoutOrderTests {
    let layout = DiagramLayout()

    @Test("the scope ordering fixture puts each first-scope group on its own row with unscoped last")
    func scopeOrderingIsExplicit() {
        let rows = layout.layout(LayoutFixture.scopeOrdering.document).rowIDs(of: .service)

        // Pins the rule by hand so it does not depend on the expectation helper.
        // Catches unscoped services sorted first, scope order following service declaration, or groups sharing a row.
        #expect(rows == [["shop-a", "shop-b"], ["ops-a"], ["free-a", "free-b"]])
    }

    @Test("provider order wins over scope order, with each provider's rows together")
    func providerBeforeScope() {
        let rows = layout.layout(LayoutFixture.scopedAcrossProviders.document).rowIDs(of: .service)

        // Catches scope being the primary key, which would interleave providers.
        #expect(rows == [["edge-shop"], ["edge-ops"], ["cloud-shop"], ["cloud-ops"]])
    }

    @Test("a single rendered scope keeps declaration order and only wraps after four")
    func selectedScopeIsNotGrouped() {
        let rows = layout.layout(LayoutFixture.ungroupedSelectedScope.document).rowIDs(of: .service)

        // Catches services still grouped by first scope, which would move the unscoped gateway to the end.
        #expect(rows == [["gateway", "cart", "pay", "ship"], ["track"]])
    }
}
