import StackmapKit
import Testing

@Suite("HTML page output contract")
struct HTMLRendererContractTests {
    struct Payload: Sendable, CustomTestStringConvertible {
        var raw: String
        var escapedForms: [String]
        var testDescription: String {
            raw
        }
    }

    static let payloads = [
        Payload(raw: "<script>alert(1)</script>", escapedForms: ["&lt;script&gt;alert(1)&lt;/script&gt;"]),
        Payload(raw: "a & b", escapedForms: ["a &amp; b"]),
        Payload(raw: "\"quoted\"", escapedForms: ["&quot;quoted&quot;", "&#34;quoted&#34;", "&#x22;quoted&#x22;"]),
        Payload(raw: "it's", escapedForms: ["it&#39;s", "it&#x27;s", "it&apos;s"]),
    ]

    static let selections: [ScopeSelection] = [.all, .scope("s1")]

    static let externalReferences = ["<link", "src=\"http", "src='http", "@import", "url(http", "url(//", "<iframe", "<script src"]

    let renderer = HTMLRenderer()

    @Test("every user string is escaped in every field", arguments: payloads, selections)
    func userStringsAreEscaped(payload: Payload, selection: ScopeSelection) throws {
        let html = try renderer.render(RenderFixtures.document(allStringsAre: payload.raw), selection: selection)

        // Catches any field (title, label, description, identifier, note) written to HTML unescaped.
        #expect(!html.contains(payload.raw))
        #expect(payload.escapedForms.contains { html.contains($0) })
    }

    @Test("markup in user strings does not add script elements")
    func noInjectedScript() throws {
        let benign = try renderer.render(RenderFixtures.document(allStringsAre: "plain"), selection: .all)
        let hostile = try renderer.render(RenderFixtures.document(allStringsAre: "<script>alert(1)</script>"), selection: .all)

        // Catches injected elements by comparing against a page with harmless strings.
        #expect(hostile.occurrences(of: "<script") == benign.occurrences(of: "<script"))
    }

    @Test("the page references nothing external", arguments: externalReferences)
    func noExternalResources(needle: String) throws {
        let html = try renderer.render(SpecExample.document, selection: .all)

        // Catches a font, stylesheet, script, or image loaded over the network.
        #expect(!html.contains(needle))
    }

    @Test("the same input renders byte-identical output")
    func outputIsDeterministic() throws {
        let first = try renderer.render(SpecExample.document, selection: .all)
        let second = try HTMLRenderer().render(SpecExample.document, selection: .all)

        // Catches timestamps, random ids, or unordered iteration in the output.
        #expect(Array(first.utf8) == Array(second.utf8))
    }

    @Test("rendering another document in between does not change the output")
    func noStateBetweenRenders() throws {
        let first = try renderer.render(SpecExample.document, selection: .all)
        _ = try renderer.render(RenderFixtures.withoutScopes, selection: .all)
        let second = try renderer.render(SpecExample.document, selection: .all)

        // Catches state kept between renders, such as counters used for element ids.
        #expect(Array(first.utf8) == Array(second.utf8))
    }

    @Test("a single scope renders deterministically too")
    func scopedOutputIsDeterministic() throws {
        let first = try renderer.render(SpecExample.document, selection: .scope("ops"))
        let second = try renderer.render(SpecExample.document, selection: .scope("ops"))

        // Catches nondeterminism that only shows in the filtered path.
        #expect(Array(first.utf8) == Array(second.utf8))
    }
}
