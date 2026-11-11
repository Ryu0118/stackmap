import StackmapKit

/// The attributes of one `<path>` start tag in a rendered page.
struct PathTag: Equatable {
    var attributes: [String: String]

    var source: String? {
        attributes["data-source"]
    }

    var target: String? {
        attributes["data-target"]
    }

    /// The attributes that can carry a color.
    var colorAttributes: [String: String] {
        attributes.filter { ["class", "stroke", "style", "color", "data-color"].contains($0.key) }
    }
}

extension String {
    /// Every `<path ...>` start tag on the page, in page order.
    func pathTags() -> [PathTag] {
        guard let tag = try? Regex("<path\\b[^>]*>"), let attribute = try? Regex("([A-Za-z][A-Za-z0-9:-]*)=\"([^\"]*)\"") else { return [] }
        return matches(of: tag).map { match in
            let text = String(self[match.range])
            let pairs = text.matches(of: attribute).compactMap { pair -> (String, String)? in
                guard let name = pair.output[1].substring, let value = pair.output[2].substring else { return nil }
                return (String(name), String(value))
            }
            return PathTag(attributes: Dictionary(pairs, uniquingKeysWith: { first, _ in first }))
        }
    }

    /// The paths that are connectors, that is those naming a source or a target.
    func connectorPaths() -> [PathTag] {
        pathTags().filter { $0.source != nil || $0.target != nil }
    }
}

enum ConnectorHTMLFixtures {
    /// A document without scopes, so the page has one diagram, with every kind of connector.
    static let document = StackmapDocument(
        providers: [Provider(id: "edge", label: "Edge"), Provider(id: "cloud", label: "Cloud")],
        stores: [Store(id: "sql", label: "SQL", provider: "edge"), Store(id: "docs", label: "Docs", provider: "cloud")],
        clients: [
            Client(id: "mobile", label: "Mobile", calls: ["api", "worker"]),
            Client(id: "web", label: "Web", calls: ["api", "site"]),
        ],
        services: [
            Service(id: "api", label: "api", provider: "edge", calls: ["worker"]),
            Service(id: "site", label: "site", provider: "edge"),
            Service(id: "worker", label: "worker", provider: "cloud", calls: ["api"]),
        ],
        data: [
            DataItem(id: "users", label: "Users", store: "sql", owner: "api"),
            DataItem(id: "orders", label: "Orders", store: "docs", owner: "api"),
        ]
    )

    /// The connectors the spec requires, as `kind:id` pairs.
    static var expectedPairs: Set<[String]> {
        Set(ExpectedDiagram(ScopedDocument(keeping: document)).links.map { link in
            ["\(link.source.kind.rawValue):\(link.source.id)", "\(link.target.kind.rawValue):\(link.target.id)"]
        })
    }
}
