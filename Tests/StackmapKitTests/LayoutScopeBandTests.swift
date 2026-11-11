import StackmapKit
import Testing

@Suite("Scope bands in the diagram")
struct LayoutScopeBandTests {
    let layout = DiagramLayout()

    @Test("scope bands appear only for the whole system with declared scopes", arguments: LayoutFixture.all)
    func scopeBandPresence(fixture: LayoutFixture) {
        let geometry = layout.layout(fixture.document)
        let expected = ExpectedDiagram(fixture.document)

        // Catches scope bands drawn for a single-scope page or for a file with no scopes.
        #expect(geometry.scopeBands.count == expected.scopeRuns.count)
        if !expected.expectsScopeBands {
            #expect(geometry.scopeBands.isEmpty)
        }
    }

    @Test("each run of consecutive services with the same first scope has one band", arguments: LayoutFixture.all.filter { $0.document.selection == .all })
    func bandPerRun(fixture: LayoutFixture) {
        let expected = ExpectedDiagram(fixture.document)

        // Catches bands that merge non-consecutive runs, split a run, or swallow neighbouring services.
        #expect(layout.layout(fixture.document).scopeRunProblems(expected) == [])
    }

    @Test("a selected scope has no scope bands")
    func selectedScopeHasNoBands() {
        let geometry = layout.layout(LayoutFixture.selectedScope.document)

        // Catches scope bands drawn when a single scope is rendered.
        #expect(geometry.scopeBands.isEmpty)
    }

    @Test("scopes that no service uses draw no bands")
    func unusedScopesDrawNoBands() {
        let geometry = layout.layout(LayoutFixture.scopesDeclaredButUnused.document)

        // Catches an empty band per declared scope.
        #expect(geometry.scopeBands.isEmpty)
    }

    @Test("scope order puts shop before ops before unscoped services")
    func scopeBandsFollowOrder() {
        let geometry = layout.layout(LayoutFixture.scopeOrdering.document)
        let bands = geometry.scopeBands.sorted { $0.frame.x < $1.frame.x }
        let unscoped = geometry.frame(of: NodeID(kind: .service, id: "free-a"))

        // Pins band identity by hand. Catches bands labeled with the wrong scope, or unscoped services inside a band.
        #expect(bands.map(\.id) == ["shop", "ops"])
        #expect(unscoped.map { frame in bands.allSatisfy { !$0.frame.intersects(frame) } } == true)
    }

    @Test("the same scope in two providers gets two bands")
    func sameScopeTwice() {
        let geometry = layout.layout(LayoutFixture.scopedAcrossProviders.document)
        let bands = geometry.scopeBands.sorted { $0.frame.x < $1.frame.x }

        // Catches one band stretched across a provider boundary and the services between.
        #expect(bands.map(\.id) == ["shop", "ops", "shop", "ops"])
    }
}
