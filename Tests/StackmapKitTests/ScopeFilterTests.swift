import StackmapKit
import Testing

@Suite("Filtering a document by scope")
struct ScopeFilterTests {
    let filter = ScopeFilter()
    let document = SpecExample.documentWithoutMigration

    @Test("selecting everything keeps the whole document in declaration order")
    func allKeepsEverything() throws {
        let scoped = try filter.filter(document, selection: .all)

        // Catches entries lost or reordered when no scope is selected.
        #expect(scoped == ScopedDocument(
            selection: .all,
            title: document.title,
            scopes: document.scopes,
            providers: document.providers,
            stores: document.stores,
            clients: document.clients,
            services: document.services,
            data: document.data
        ))
    }

    @Test("selecting everything keeps stores that hold no data and providers that host nothing used")
    func allKeepsUnusedEntries() throws {
        var unused = document
        unused.stores.append(Store(id: "empty", label: "Empty", provider: "cloud"))
        unused.providers.append(Provider(id: "idle", label: "Idle"))
        let scoped = try filter.filter(unused, selection: .all)

        // Catches the usage-based dropping applied to the whole-system view.
        #expect(scoped.stores.map(\.id) == ["sql", "cache", "docs", "empty"])
        #expect(scoped.providers.map(\.id) == ["edge", "cloud", "idle"])
    }

    @Test("one scope keeps its clients, services, data, stores, and providers")
    func shopScope() throws {
        let scoped = try filter.filter(document, selection: .scope("shop"))

        // Catches wrong membership for each entity kind when filtering a scope.
        #expect(scoped.selection == .scope("shop"))
        #expect(scoped.clients.map(\.id) == ["mobile"])
        #expect(scoped.services.map(\.id) == ["api"])
        #expect(scoped.data.map(\.id) == ["orders", "sessions"])
        #expect(scoped.stores.map(\.id) == ["cache", "docs"])
        #expect(scoped.providers.map(\.id) == ["edge", "cloud"])
    }

    @Test("a scope drops providers and stores that nothing kept uses")
    func opsScopeDropsUnusedInfrastructure() throws {
        let scoped = try filter.filter(document, selection: .scope("ops"))

        // Catches stores and providers kept just because they are declared.
        #expect(scoped.clients.isEmpty)
        #expect(scoped.services.map(\.id) == ["bot"])
        #expect(scoped.data.map(\.id) == ["jobs"])
        #expect(scoped.stores.map(\.id) == ["sql"])
        #expect(scoped.providers.map(\.id) == ["edge"])
    }

    @Test("scopes list every declared scope for all and only the selected one otherwise")
    func scopesListing() throws {
        let all = try filter.filter(document, selection: .all)
        let ops = try filter.filter(document, selection: .scope("ops"))

        // Catches the scope list not narrowing, or narrowing for the whole-system view.
        #expect(all.scopes.map(\.id) == ["shop", "ops"])
        #expect(ops.scopes == [Scope(id: "ops", label: "Operations")])
    }

    @Test("the title carries over")
    func titleIsKept() throws {
        let scoped = try filter.filter(document, selection: .scope("shop"))

        // Catches the title being reset to the default when scoping.
        #expect(scoped.title == "Example Platform")
    }

    @Test("an unknown scope is an error", arguments: ["missing", "api", "Shop", ""])
    func unknownScope(id: String) {
        // Catches an unknown (or non-scope) id silently producing an empty view.
        #expect(throws: ScopeFilterError.unknownScope(id)) {
            try filter.filter(document, selection: .scope(id))
        }
    }

    @Test("a document without scopes rejects any scope selection")
    func noScopesDeclared() {
        // Catches a scope selection succeeding when nothing is declared.
        #expect(throws: ScopeFilterError.unknownScope("shop")) {
            try filter.filter(StackmapDocument(), selection: .scope("shop"))
        }
    }

    @Test("an empty document filters to an empty view")
    func emptyDocument() throws {
        let scoped = try filter.filter(StackmapDocument(), selection: .all)

        // Catches a crash on empty lists.
        #expect(scoped.services.isEmpty)
        #expect(scoped.providers.isEmpty)
        #expect(scoped.scopes.isEmpty)
    }
}
