import StackmapKit
import Testing

@Suite("Entries on the rendered page")
struct HTMLRendererMembershipTests {
    struct Entry: Sendable, CustomTestStringConvertible {
        var attribute: String
        var inShop: Bool
        var inOps: Bool
        var testDescription: String {
            attribute
        }
    }

    static let entries = [
        Entry(attribute: "data-node=\"client:mobile\"", inShop: true, inOps: false),
        Entry(attribute: "data-node=\"service:api\"", inShop: true, inOps: false),
        Entry(attribute: "data-node=\"serviceStores:api\"", inShop: true, inOps: false),
        Entry(attribute: "data-node=\"sharedStore:docs\"", inShop: true, inOps: false),
        Entry(attribute: "data-node=\"service:bot\"", inShop: false, inOps: true),
        Entry(attribute: "data-node=\"serviceStores:bot\"", inShop: false, inOps: true),
        Entry(attribute: "data-row=\"orders\"", inShop: true, inOps: false),
        Entry(attribute: "data-row=\"sessions\"", inShop: true, inOps: false),
        Entry(attribute: "data-row=\"jobs\"", inShop: false, inOps: true),
    ]

    let renderer = HTMLRenderer()
    let document = SpecExample.documentWithoutMigration

    @Test("the whole system carries each entry once in the all section and once per scope that keeps it", arguments: entries)
    func occurrencesInAll(entry: Entry) throws {
        let html = try renderer.render(document, selection: .all)
        let expected = 1 + (entry.inShop ? 1 : 0) + (entry.inOps ? 1 : 0)

        // Catches entries duplicated within a section, left out of the all view, or leaking into other scope sections.
        #expect(html.occurrences(of: entry.attribute) == expected)
    }

    @Test("rendering the shop scope keeps only its entries", arguments: entries)
    func occurrencesInShop(entry: Entry) throws {
        let html = try renderer.render(document, selection: .scope("shop"))

        // Catches dropped entries still being rendered.
        #expect(html.occurrences(of: entry.attribute) == (entry.inShop ? 1 : 0))
    }

    @Test("rendering the ops scope keeps only its entries", arguments: entries)
    func occurrencesInOps(entry: Entry) throws {
        let html = try renderer.render(document, selection: .scope("ops"))

        // Catches the scope filter not being applied to the page.
        #expect(html.occurrences(of: entry.attribute) == (entry.inOps ? 1 : 0))
    }
}
