import StackmapKit
import Testing

@Suite("Scope bands in the diagram")
struct LayoutScopeBandTests {
    let layout = DiagramLayout()

    @Test("there is one scope band per scoped row segment, and none without grouping", arguments: LayoutFixture.all)
    func scopeBandPresence(fixture: LayoutFixture) {
        let geometry = layout.layout(fixture.document)
        let expected = ExpectedDiagram(fixture.document)

        // Catches scope bands drawn for a single-scope page or a file without scopes, or one band for a wrapped group.
        #expect(geometry.scopeBands.count == expected.scopeRuns.count)
        if !expected.expectsScopeBands {
            #expect(geometry.scopeBands.isEmpty)
        }
    }

    @Test("each scoped row segment sits in a band of its scope inside its provider band", arguments: LayoutFixture.all)
    func bandPerRowSegment(fixture: LayoutFixture) {
        // Catches bands spanning several rows, swallowing neighbouring services, or poking out of the provider band.
        #expect(layout.layout(fixture.document).scopeRunProblems(ExpectedDiagram(fixture.document)) == [])
    }

    @Test("scopes that no service uses draw no bands")
    func unusedScopesDrawNoBands() {
        // Catches an empty band per declared scope.
        #expect(layout.layout(LayoutFixture.scopesDeclaredButUnused.document).scopeBands.isEmpty)
    }

    @Test("scope bands follow scope order top to bottom and leave unscoped services out")
    func scopeBandsFollowOrder() {
        let geometry = layout.layout(LayoutFixture.scopeOrdering.document)
        let bands = geometry.scopeBands.sorted { $0.frame.y < $1.frame.y }
        let unscoped = geometry.frame(of: NodeID(kind: .service, id: "free-a"))

        // Pins band identity by hand. Catches bands labeled with the wrong scope, or unscoped services inside a band.
        #expect(bands.map(\.id) == ["shop", "ops"])
        #expect(unscoped.map { frame in bands.allSatisfy { !$0.frame.intersects(frame) } } == true)
    }

    @Test("a group of six services wraps into two bands of its scope on two rows")
    func wideGroupSplits() {
        let bands = layout.layout(LayoutFixture.wideScopeGroup.document).scopeBands.sorted { $0.frame.y < $1.frame.y }

        // Catches one tall band stretched over both rows, or the wrapped row left without a band.
        #expect(bands.map(\.id) == ["shop", "shop", "ops"])
        #expect(Set(bands.map(\.frame.y)).count == 3)
    }

    @Test("the same scope in two providers gets a band in each")
    func sameScopeTwice() {
        let bands = layout.layout(LayoutFixture.scopedAcrossProviders.document).scopeBands.sorted { $0.frame.y < $1.frame.y }

        // Catches one band stretched across a provider boundary.
        #expect(bands.map(\.id) == ["shop", "ops", "shop", "ops"])
    }
}
