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

    @Test("a longer data label makes the shared store card taller", arguments: variants)
    func sharedStoreCardGrows(variant: Variant) throws {
        let short = try #require(layout.layout(TextFixtures.shared(label: variant.short)).frame(of: TextFixtures.sharedCard))
        let long = try #require(layout.layout(TextFixtures.shared(label: variant.long)).frame(of: TextFixtures.sharedCard))

        // Catches shared store cards keeping a fixed height while their text overflows.
        #expect(long.height > short.height)
    }
}
