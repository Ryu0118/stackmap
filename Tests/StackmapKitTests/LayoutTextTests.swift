import StackmapKit
import Testing

@Suite("Card text is never cut")
struct LayoutTextTests {
    let layout = DiagramLayout()

    struct Variant: Sendable, CustomTestStringConvertible {
        var name: String
        var short: String
        var long: String
        var testDescription: String {
            name
        }
    }

    static let variants = [
        Variant(name: "long Latin label", short: "Orders", long: String(repeating: "Customer orders ", count: 20)),
        Variant(name: "wide characters against the same count of narrow ones", short: String(repeating: "a", count: 200), long: String(repeating: "あ", count: 200)),
    ]

    @Test("a longer data label makes the own-data card taller", arguments: variants)
    func ownDataCardGrows(variant: Variant) throws {
        let short = try #require(layout.layout(TextFixtures.own(label: variant.short)).frame(of: TextFixtures.ownCard))
        let long = try #require(layout.layout(TextFixtures.own(label: variant.long)).frame(of: TextFixtures.ownCard))

        // Catches text clipped to a fixed card height, or wide characters measured as narrow ones.
        #expect(long.height > short.height)
    }

    struct Card: Sendable, CustomTestStringConvertible {
        var name: String
        var node: NodeID
        var document: @Sendable (String) -> ScopedDocument
        var testDescription: String {
            name
        }
    }

    static let cards = [
        Card(name: "own-data card", node: TextFixtures.ownCard, document: TextFixtures.own(label:)),
        Card(name: "shared store card", node: TextFixtures.sharedCard, document: TextFixtures.shared(label:)),
        Card(name: "service card description", node: TextFixtures.serviceCard, document: TextFixtures.described(_:)),
    ]

    @Test("a data line or description just wider than its card wraps to a second line", arguments: cards)
    func barelyTooLongLineWraps(card: Card) throws {
        let oneLine = try #require(layout.layout(card.document("あ")).frame(of: card.node))
        // Wide characters at the page's 13 px card font are each at least 13 px wide, so one more
        // than fits across the whole card cannot fit on one line.
        let count = oneLine.width / 13 + 1
        let wrapped = try #require(layout.layout(card.document(String(repeating: "あ", count: count))).frame(of: card.node))

        // Catches a line count rounded down, which keeps a line that is a little too long at one line and cuts it off.
        #expect(wrapped.height > oneLine.height)
    }

    @Test("a longer data label makes the shared store card taller", arguments: variants)
    func sharedStoreCardGrows(variant: Variant) throws {
        let short = try #require(layout.layout(TextFixtures.shared(label: variant.short)).frame(of: TextFixtures.sharedCard))
        let long = try #require(layout.layout(TextFixtures.shared(label: variant.long)).frame(of: TextFixtures.sharedCard))

        // Catches shared store cards keeping a fixed height while their text overflows.
        #expect(long.height > short.height)
    }
}
