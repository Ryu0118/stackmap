import StackmapKit
import Testing

struct LayoutFixture: Sendable, CustomTestStringConvertible {
    var name: String
    var document: ScopedDocument
    var testDescription: String {
        name
    }
}

extension ScopedDocument {
    /// A view that keeps every entry of `document`, as the whole-system selection would.
    init(keeping document: StackmapDocument, selection: ScopeSelection = .all, scopes: [Scope]? = nil) {
        self.init(
            selection: selection,
            title: document.title,
            scopes: scopes ?? document.scopes,
            providers: document.providers,
            stores: document.stores,
            clients: document.clients,
            services: document.services,
            data: document.data
        )
    }
}
