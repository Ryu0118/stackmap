import StackmapKit
import Testing

@Suite("Column grid of the diagram")
struct LayoutGridTests {
    let layout = DiagramLayout()

    @Test("no row holds more than four cards", arguments: LayoutFixture.all)
    func rowsHoldAtMostFour(fixture: LayoutFixture) {
        // Catches a row that keeps growing sideways instead of wrapping.
        #expect(layout.layout(fixture.document).overfullRows() == [])
    }

    @Test("client, service, and shared store cards start on one of four shared column positions", arguments: LayoutFixture.all)
    func cardsShareOneColumnGrid(fixture: LayoutFixture) {
        // Catches rows laid out independently, for example centered clients or shared stores offset from the services.
        #expect(layout.layout(fixture.document).columnGridProblems() == [])
    }

    @Test("nine services on one provider wrap into rows of four, four, and one")
    func nineServicesWrap() {
        let rows = layout.layout(LayoutFixture.nineServices.document).rowIDs(of: .service)

        // Pins wrapping by hand. Catches an off-by-one in the row capacity.
        #expect(rows == [["s1", "s2", "s3", "s4"], ["s5", "s6", "s7", "s8"], ["s9"]])
    }

    @Test("six clients wrap into rows of four and two")
    func sixClientsWrap() {
        let rows = layout.layout(LayoutFixture.sixClients.document).rowIDs(of: .client)

        // Pins wrapping by hand. Catches clients kept on one row.
        #expect(rows == [["c1", "c2", "c3", "c4"], ["c5", "c6"]])
    }

    @Test("a wrapped row starts in the first column of the rows above it")
    func wrappedRowsAlignLeft() throws {
        let rows = layout.layout(LayoutFixture.nineServices.document).rows(of: .service)
        let first = try #require(rows.first?.first)
        let last = try #require(rows.last?.first)

        // Catches a wrapped row being centered or shifted instead of reusing the column grid.
        #expect(first.frame.x == last.frame.x)
    }
}
