import StackmapKit
import Testing

@Suite("Connector markup on the rendered page")
struct HTMLRendererConnectorTests {
    let renderer = HTMLRenderer()

    @Test("every connector names its source and target cards as kind and id")
    func connectorsNameTheirCards() throws {
        let paths = try renderer.render(ConnectorHTMLFixtures.document, selection: .all).connectorPaths()
        let pairs = Set(paths.compactMap { path in path.source.flatMap { source in path.target.map { [source, $0] } } })

        // Catches a connector without data-source or data-target, a wrong kind prefix, or a missing connector kind.
        #expect(paths.allSatisfy { $0.source != nil && $0.target != nil })
        #expect(pairs == ConnectorHTMLFixtures.expectedPairs)
    }

    @Test("connector endpoints name cards that exist on the page")
    func endpointsMatchCards() throws {
        let html = try renderer.render(ConnectorHTMLFixtures.document, selection: .all)
        let cards = Set(html.attributeValues(of: "data-node", onTag: "[a-z]+"))
        let endpoints = Set(html.connectorPaths().flatMap { [$0.source, $0.target].compactMap(\.self) })

        // Catches data-source or data-target written in a format other than the cards' data-node.
        #expect(endpoints.isSubset(of: cards))
        #expect(!endpoints.isEmpty)
    }

    @Test("connectors from one client share one color", arguments: ["client:mobile", "client:web"])
    func clientConnectorsShareAColor(client: String) throws {
        let paths = try renderer.render(ConnectorHTMLFixtures.document, selection: .all).connectorPaths().filter { $0.source == client }

        // Catches each connector of a client picking its own color, for example by target.
        #expect(paths.count >= 2)
        #expect(Set(paths.map(\.colorAttributes)).count == 1)
    }
}
