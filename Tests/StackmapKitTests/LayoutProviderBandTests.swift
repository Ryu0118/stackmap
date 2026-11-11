import StackmapKit
import Testing

@Suite("Provider bands in the diagram")
struct LayoutProviderBandTests {
    let layout = DiagramLayout()

    @Test("there is one band per provider with services and one per provider with shared stores", arguments: LayoutFixture.all)
    func bandCount(fixture: LayoutFixture) {
        let geometry = layout.layout(fixture.document)
        let expected = ExpectedDiagram(fixture.document)
        let withServices = Set(fixture.document.services.map(\.provider))
        let sharedProviders = Set(fixture.document.stores.filter { expected.sharedStores.contains($0.id) }.map(\.provider))

        // Catches a band missing for a provider, or one band reused for both rows.
        #expect(geometry.providerBands.count == withServices.count + sharedProviders.count)
        #expect(Set(geometry.providerBands.map(\.id)) == withServices.union(sharedProviders))
    }

    @Test("a provider band contains its services and their store cards", arguments: LayoutFixture.all)
    func serviceBandContainsItsCards(fixture: LayoutFixture) {
        let owners = ExpectedDiagram(fixture.document).serviceStoresOwners

        // Catches cards drawn outside the band of their provider.
        #expect(layout.layout(fixture.document).serviceBandProblems(fixture.document, owners: owners) == [])
    }

    @Test("a bottom provider band contains the shared stores of that provider", arguments: LayoutFixture.all)
    func bottomBandContainsSharedStores(fixture: LayoutFixture) {
        let shared = ExpectedDiagram(fixture.document).sharedStores

        // Catches shared stores placed outside any band, or a bottom band that overlaps the service rows.
        #expect(layout.layout(fixture.document).bottomBandProblems(fixture.document, sharedStores: shared) == [])
    }

    @Test("provider bands do not overlap each other", arguments: LayoutFixture.all)
    func providerBandsAreDisjoint(fixture: LayoutFixture) {
        // Catches neighbouring providers sharing space, which makes cards look like they belong to both.
        #expect(layout.layout(fixture.document).overlappingProviderBands() == [])
    }

    @Test("a provider band holds no card of another provider or any client", arguments: LayoutFixture.all)
    func bandsHoldOnlyTheirOwnCards(fixture: LayoutFixture) {
        // Catches a card straying into a band of another provider, or a client drawn inside a provider.
        #expect(layout.layout(fixture.document).cardsInForeignBands(fixture.document) == [])
    }
}
