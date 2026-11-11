import StackmapKit
import Testing

@Suite("Diagram geometry invariants")
struct LayoutGeometryTests {
    let layout = DiagramLayout()

    @Test("no two cards overlap", arguments: LayoutFixture.all)
    func cardsDoNotOverlap(fixture: LayoutFixture) {
        // Catches cards drawn on top of each other, for example two services in the same column.
        #expect(layout.layout(fixture.document).overlappingNodes() == [])
    }

    @Test("every card and band lies inside the canvas", arguments: LayoutFixture.all)
    func everythingIsInsideTheCanvas(fixture: LayoutFixture) {
        let geometry = layout.layout(fixture.document)

        // Catches cards or band labels clipped by a canvas that is too small, such as with long labels.
        #expect(geometry.width >= 0 && geometry.height >= 0)
        #expect(geometry.framesOutsideCanvas() == [])
    }

    @Test("every card and band has a positive size", arguments: LayoutFixture.all)
    func framesAreNotEmpty(fixture: LayoutFixture) {
        // Catches zero-sized frames, which would make containment and overlap checks pass vacuously.
        #expect(layout.layout(fixture.document).framesWithoutArea() == [])
    }

    @Test("a document with content gets a non-empty canvas", arguments: LayoutFixture.all.filter { !$0.document.services.isEmpty })
    func canvasHasArea(fixture: LayoutFixture) {
        let geometry = layout.layout(fixture.document)

        // Catches a degenerate 0x0 canvas returned regardless of content.
        #expect(geometry.width > 0 && geometry.height > 0)
    }

    @Test("an empty document has no cards, bands, or connectors")
    func emptyDocument() {
        let geometry = layout.layout(ScopedDocument(keeping: StackmapDocument()))

        // Catches placeholder cards or bands appearing for nothing.
        #expect(geometry.nodes.isEmpty)
        #expect(geometry.bands.isEmpty)
        #expect(geometry.edges.isEmpty)
    }

    @Test("laying out the same input twice gives identical geometry", arguments: LayoutFixture.all)
    func layoutIsDeterministic(fixture: LayoutFixture) {
        let first = layout.layout(fixture.document)
        let second = DiagramLayout().layout(fixture.document)

        // Catches iteration over unordered collections, which makes the page differ between runs.
        #expect(first == second)
    }

    @Test("each card appears once", arguments: LayoutFixture.all)
    func nodeIDsAreUnique(fixture: LayoutFixture) {
        let ids = layout.layout(fixture.document).nodes.map(\.nodeID)

        // Catches one card emitted twice, for example a shared store once per service.
        #expect(Set(ids).count == ids.count)
    }
}
