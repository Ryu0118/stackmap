import StackmapKit
import Testing

@Suite("Provider bands in the diagram")
struct LayoutProviderBandTests {
    let layout = DiagramLayout()

    @Test("each provider with a service or a shared store has exactly one band", arguments: LayoutFixture.all)
    func oneBandPerProvider(fixture: LayoutFixture) {
        let ids = layout.layout(fixture.document).providerBands.map(\.id)

        // Catches a separate bottom band for shared stores, or a band missing for a provider.
        #expect(ids.count == Set(ids).count)
        #expect(Set(ids) == Set(ExpectedDiagram(fixture.document).bandedProviders))
    }

    @Test("a provider band contains its services, their store cards, and its shared stores", arguments: LayoutFixture.all)
    func bandContainsItsCards(fixture: LayoutFixture) {
        // Catches cards drawn outside the band of their provider.
        #expect(layout.layout(fixture.document).providerBandContentProblems(ExpectedDiagram(fixture.document)) == [])
    }

    @Test("provider bands are stacked top to bottom in provider order", arguments: LayoutFixture.all)
    func bandsAreStacked(fixture: LayoutFixture) {
        // Catches providers placed side by side, or in an order other than the declaration order.
        #expect(layout.layout(fixture.document).providerBandStackingProblems(ExpectedDiagram(fixture.document)) == [])
    }

    @Test("a shared store sits in its own provider's band below that provider's services", arguments: LayoutFixture.all)
    func sharedStoresInTheirBand(fixture: LayoutFixture) {
        // Catches shared stores collected at the bottom of the page, or drawn above or beside the services.
        #expect(layout.layout(fixture.document).sharedStorePlacementProblems(ExpectedDiagram(fixture.document)) == [])
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
