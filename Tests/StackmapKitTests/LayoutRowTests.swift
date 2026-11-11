import StackmapKit
import Testing

@Suite("Row structure of the diagram")
struct LayoutRowTests {
    let layout = DiagramLayout()

    @Test("every client is above every service", arguments: LayoutFixture.all)
    func clientsAboveServices(fixture: LayoutFixture) {
        // Catches the client row being placed beside or below the services.
        #expect(layout.layout(fixture.document).clientsNotAboveServices() == [])
    }

    @Test("a service's store card sits below it and under its horizontal extent", arguments: LayoutFixture.all)
    func storeCardsUnderTheirService(fixture: LayoutFixture) {
        let owners = ExpectedDiagram(fixture.document).serviceStoresOwners

        // Catches a store card placed above, or under a different service.
        #expect(layout.layout(fixture.document).misplacedStoreCards(owners: owners) == [])
    }

    @Test("services sit in one row", arguments: LayoutFixture.all.filter { $0.document.services.count > 1 })
    func servicesShareARow(fixture: LayoutFixture) {
        let services = layout.layout(fixture.document).frames(of: .service)

        // Catches services wrapping onto several rows, which would break the left-to-right order rule.
        #expect(Set(services.map(\.y)).count == 1)
    }

    @Test("shared stores are below every service and store card", arguments: LayoutFixture.all)
    func sharedStoresAtTheBottom(fixture: LayoutFixture) {
        // Catches the bottom row being drawn beside or above the service rows.
        #expect(layout.layout(fixture.document).sharedStoresNotAtBottom() == [])
    }
}
