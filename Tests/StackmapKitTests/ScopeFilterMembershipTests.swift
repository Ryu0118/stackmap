import StackmapKit
import Testing

@Suite("Scope membership rules")
struct ScopeFilterMembershipTests {
    let filter = ScopeFilter()

    @Test("entries without scopes belong to every scope")
    func unscopedEntriesAreEverywhere() throws {
        let document = ScopeFixtures.unscoped
        let shop = try filter.filter(document, selection: .scope("shop"))
        let ops = try filter.filter(document, selection: .scope("ops"))

        // Catches unscoped entries being treated as belonging to no scope.
        for scoped in [shop, ops] {
            #expect(scoped.clients.map(\.id) == ["web"])
            #expect(scoped.services.map(\.id) == ["api"])
            #expect(scoped.data.map(\.id) == ["orders"])
        }
    }

    @Test("data without scopes uses the owner's scopes")
    func dataInheritsOwnerScopes() throws {
        let document = ScopeFixtures.inheritance
        let shop = try filter.filter(document, selection: .scope("shop"))
        let ops = try filter.filter(document, selection: .scope("ops"))

        // Catches data being kept or dropped independently of its owner's scopes.
        #expect(shop.data.map(\.id) == ["inherited"])
        #expect(ops.data.isEmpty)
    }

    @Test("data scopes override the owner's scopes")
    func dataScopesOverrideOwner() throws {
        let document = ScopeFixtures.override
        let shop = try filter.filter(document, selection: .scope("shop"))
        let ops = try filter.filter(document, selection: .scope("ops"))

        // Catches explicit data scopes being unioned with the owner's scopes instead of replacing them.
        #expect(shop.data.isEmpty)
        #expect(ops.data.map(\.id) == ["narrowed"])
    }

    @Test("data whose owner is dropped is dropped even when the data is in scope")
    func dataFollowsItsOwner() throws {
        let document = ScopeFixtures.orphanedByOwner
        let ops = try filter.filter(document, selection: .scope("ops"))

        // Catches data kept without its owner, which would leave a card with no service.
        #expect(ops.services.isEmpty)
        #expect(ops.data.isEmpty)
        #expect(ops.stores.isEmpty)
    }

    @Test("calls to services that are not kept are removed")
    func callsToDroppedServicesAreRemoved() throws {
        let document = ScopeFixtures.crossScopeCalls
        let shop = try filter.filter(document, selection: .scope("shop"))
        let all = try filter.filter(document, selection: .all)
        let shopWeb = try #require(shop.clients.first { $0.id == "web" })
        let allWeb = try #require(all.clients.first { $0.id == "web" })

        // Catches dangling calls, which would draw connectors to missing cards.
        #expect(shopWeb.calls == ["shop-api"])
        #expect(allWeb.calls == ["shop-api", "ops-api"])
    }

    @Test("a kept client stays when every one of its calls is dropped")
    func clientWithAllCallsDroppedRemains() throws {
        let document = ScopeFixtures.crossScopeCalls
        let ops = try filter.filter(document, selection: .scope("ops"))
        let lonely = try #require(ops.clients.first { $0.id == "lonely" })

        // Catches a client being dropped because its calls were filtered, rather than by its own scopes.
        #expect(lonely.calls.isEmpty)
    }

    @Test("a client scoped elsewhere is dropped along with its calls")
    func scopedClientIsDropped() throws {
        let document = ScopeFixtures.crossScopeCalls
        let ops = try filter.filter(document, selection: .scope("ops"))

        // Catches client scopes being ignored.
        #expect(ops.clients.map(\.id).contains("shop-only") == false)
    }

    @Test("a provider is kept when it only hosts a kept store")
    func providerKeptForItsStore() throws {
        let document = ScopeFixtures.storeOnOtherProvider
        let scoped = try filter.filter(document, selection: .scope("shop"))

        // Catches providers being kept only for services, dropping the band of a shared store.
        #expect(scoped.providers.map(\.id) == ["edge", "cloud"])
        #expect(scoped.stores.map(\.id) == ["docs"])
    }

    @Test("a store holding only dropped data is dropped, as is its provider")
    func storeOfDroppedDataIsDropped() throws {
        let document = ScopeFixtures.storeOnOtherProvider
        let ops = try filter.filter(document, selection: .scope("ops"))

        // Catches stores kept because some other scope uses them.
        #expect(ops.stores.isEmpty)
        #expect(ops.providers.map(\.id) == ["edge"])
    }

    @Test("a store used by data from two scopes is kept in both")
    func sharedStoreInBothScopes() throws {
        let document = ScopeFixtures.sharedAcrossScopes
        let shop = try filter.filter(document, selection: .scope("shop"))
        let ops = try filter.filter(document, selection: .scope("ops"))

        // Catches a store being claimed by the first scope that uses it.
        #expect(shop.stores.map(\.id) == ["pool"])
        #expect(ops.stores.map(\.id) == ["pool"])
    }

    @Test("filtering does not reorder kept entries")
    func keptEntriesKeepDeclarationOrder() throws {
        let document = ScopeFixtures.manyServices
        let scoped = try filter.filter(document, selection: .scope("shop"))

        // Catches output sorted by id or grouped by something other than declaration order.
        #expect(scoped.services.map(\.id) == ["z", "m", "a"])
    }
}
