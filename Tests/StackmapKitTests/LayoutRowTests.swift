import StackmapKit
import Testing

@Suite("Row structure of the diagram")
struct LayoutRowTests {
    let layout = DiagramLayout()

    @Test("clients sit above every other card and band", arguments: LayoutFixture.all)
    func clientsAtTheTop(fixture: LayoutFixture) {
        // Catches the client row being placed beside or below the services or the provider bands.
        #expect(layout.layout(fixture.document).clientsNotAtTheTop() == [])
    }

    @Test("clients wrap four to a row in declaration order", arguments: LayoutFixture.all)
    func clientRows(fixture: LayoutFixture) {
        // Catches clients kept on one long row, reordered, or wrapped at a width other than four.
        #expect(layout.layout(fixture.document).rowIDs(of: .client) == ExpectedDiagram(fixture.document).clientRows)
    }

    @Test("service rows follow provider order, then first-scope groups that each start a row and wrap after four", arguments: LayoutFixture.all)
    func serviceRows(fixture: LayoutFixture) {
        let expected = ExpectedDiagram(fixture.document).serviceRows.map { $0.services.map(\.id) }

        // Catches services kept on one row, groups sharing a row, providers interleaved, or the wrong order within a row.
        #expect(layout.layout(fixture.document).rowIDs(of: .service) == expected)
    }

    @Test("a service's store card sits directly under it in the same column", arguments: LayoutFixture.all)
    func storeCardsUnderTheirService(fixture: LayoutFixture) {
        let owners = ExpectedDiagram(fixture.document).serviceStoresOwners

        // Catches a store card placed above, in another column, or below a later row of services.
        #expect(layout.layout(fixture.document).misplacedStoreCards(owners: owners) == [])
    }

    @Test("shared stores wrap four to a row, provider by provider, in store declaration order", arguments: LayoutFixture.all)
    func sharedStoreRows(fixture: LayoutFixture) {
        // Catches shared stores of several providers merged into one row, or more than four on a row.
        #expect(layout.layout(fixture.document).rowIDs(of: .sharedStore) == ExpectedDiagram(fixture.document).sharedStoreRows)
    }
}
