import Foundation
import StackmapKit
import Testing

@Suite("HTML page structure")
struct HTMLRendererStructureTests {
    let renderer = HTMLRenderer()
    let document = SpecExample.documentWithoutMigration

    @Test("the whole system renders an all section and one section per scope")
    func sectionsForAll() throws {
        let html = try renderer.render(document, selection: .all)

        // Catches a missing all view or a missing per-scope view.
        #expect(html.attributeValues(of: "data-scope", onTag: "section").sorted() == ["all", "ops", "shop"])
    }

    @Test("the whole system renders a tab button for the all view and for each scope")
    func tabButtonsForAll() throws {
        let html = try renderer.render(document, selection: .all)

        // Catches missing tab buttons, which would leave scope sections unreachable.
        #expect(Set(html.attributeValues(of: "data-tab", onTag: "button")) == ["all", "shop", "ops"])
        #expect(html.attributeValues(of: "data-tab", onTag: "button").count == 3)
    }

    @Test("a document without scopes has only the all section and no tab buttons")
    func noScopesNoTabs() throws {
        let html = try renderer.render(RenderFixtures.withoutScopes, selection: .all)

        // Catches empty tab bars, or scope sections invented for an unscoped file.
        #expect(html.attributeValues(of: "data-scope", onTag: "section") == ["all"])
        #expect(!html.containsStartTag("button"))
    }

    @Test("a declared scope without any content still gets its section and button")
    func emptyScopeStillRendered() throws {
        let empty = StackmapDocument(scopes: [Scope(id: "a", label: "A"), Scope(id: "b", label: "B")])
        let html = try renderer.render(empty, selection: .all)

        // Catches scopes with nothing in them being silently skipped.
        #expect(html.attributeValues(of: "data-scope", onTag: "section").sorted() == ["a", "all", "b"])
        #expect(html.attributeValues(of: "data-tab", onTag: "button").count == 3)
    }

    @Test("one scope renders exactly one section for it and no tab buttons")
    func singleScope() throws {
        let html = try renderer.render(document, selection: .scope("shop"))

        // Catches the all view or tab bar leaking into a single-scope page.
        #expect(html.attributeValues(of: "data-scope", onTag: "section") == ["shop"])
        #expect(!html.containsStartTag("button"))
    }

    @Test("an empty document still renders the all section")
    func emptyDocument() throws {
        let html = try renderer.render(StackmapDocument(), selection: .all)

        // Catches a crash or an empty page when nothing is declared.
        #expect(html.attributeValues(of: "data-scope", onTag: "section") == ["all"])
    }

    @Test("an unknown scope is an error", arguments: ["missing", "api", ""])
    func unknownScope(id: String) {
        // Catches an unknown scope rendering an empty page instead of failing.
        #expect(throws: ScopeFilterError.unknownScope(id)) {
            try renderer.render(document, selection: .scope(id))
        }
    }

    @Test("the title is on the page")
    func titleIsRendered() throws {
        let html = try renderer.render(document, selection: .all)

        // Catches the title being dropped.
        #expect(html.contains("Example Platform"))
    }
}
