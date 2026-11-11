import StackmapKit

extension String {
    /// How many times `needle` occurs, without overlaps.
    func occurrences(of needle: String) -> Int {
        components(separatedBy: needle).count - 1
    }

    /// The values of `attribute` on every `<tag ...>` start tag, in page order.
    func attributeValues(of attribute: String, onTag tag: String) -> [String] {
        guard let regex = try? Regex("<\(tag)\\b[^>]*?\\b\(attribute)=\"([^\"]*)\"") else { return [] }
        return matches(of: regex).compactMap { match in
            match.output[1].substring.map(String.init)
        }
    }

    func containsStartTag(_ tag: String) -> Bool {
        range(of: "<\(tag)\\b", options: .regularExpression) != nil
    }
}

enum RenderFixtures {
    /// A document in which every user-visible string is `text`.
    static func document(allStringsAre text: String) -> StackmapDocument {
        StackmapDocument(
            title: text,
            scopes: [Scope(id: "s1", label: text)],
            providers: [Provider(id: "p1", label: text)],
            stores: [Store(id: "a", label: text, provider: "p1"), Store(id: "b", label: text, provider: "p1")],
            clients: [Client(id: "c", label: text, description: text, scopes: ["s1"], calls: ["svc"])],
            services: [Service(id: "svc", label: text, description: text, provider: "p1", scopes: ["s1"])],
            data: [DataItem(
                id: "d",
                label: text,
                store: "a",
                owner: "svc",
                identifiers: [text],
                status: .migrating,
                migration: Migration(to: "b", note: text)
            )]
        )
    }

    static let withoutScopes = StackmapDocument(
        providers: [Provider(id: "edge", label: "Edge")],
        stores: [Store(id: "sql", label: "SQL", provider: "edge")],
        services: [Service(id: "api", label: "api", provider: "edge")],
        data: [DataItem(id: "orders", label: "Orders", store: "sql", owner: "api")]
    )
}
