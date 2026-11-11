import StackmapKit

extension LayoutFixture {
    static let grid: [LayoutFixture] = [
        nineServices,
        sixClients,
        wideScopeGroup,
        ungroupedSelectedScope,
        sharedStoresWrapping,
    ]

    private static let edge = Provider(id: "edge", label: "Edge")
    private static let cloud = Provider(id: "cloud", label: "Cloud")

    static func services(_ ids: [String], on provider: String, scopes: [String] = []) -> [Service] {
        ids.map { Service(id: $0, label: $0, provider: provider, scopes: scopes) }
    }

    static let nineServices = LayoutFixture(
        name: "nine services on one provider",
        document: ScopedDocument(keeping: StackmapDocument(
            providers: [edge],
            stores: [Store(id: "sql", label: "SQL", provider: "edge")],
            services: services((1 ... 9).map { "s\($0)" }, on: "edge"),
            data: (1 ... 9).map { DataItem(id: "d\($0)", label: "Data \($0)", store: "sql", owner: "s\($0)") }
        ))
    )

    static let sixClients = LayoutFixture(
        name: "six clients",
        document: ScopedDocument(keeping: StackmapDocument(
            providers: [edge],
            clients: (1 ... 6).map { Client(id: "c\($0)", label: "Client \($0)", calls: $0.isMultiple(of: 2) ? ["api"] : ["api", "bot"]) },
            services: services(["api", "bot"], on: "edge")
        ))
    )

    static let wideScopeGroup = LayoutFixture(
        name: "a scope group of six services next to smaller groups",
        document: ScopedDocument(keeping: StackmapDocument(
            scopes: [Scope(id: "shop", label: "Shop"), Scope(id: "ops", label: "Ops")],
            providers: [edge],
            services: services(["free"], on: "edge")
                + services(["shop1", "shop2", "shop3"], on: "edge", scopes: ["shop"])
                + services(["ops1"], on: "edge", scopes: ["ops"])
                + services(["shop4", "shop5", "shop6"], on: "edge", scopes: ["shop", "ops"])
        ))
    )

    static let ungroupedSelectedScope = LayoutFixture(
        name: "a selected scope with an unscoped service declared first",
        document: ScopedDocument(
            selection: .scope("shop"),
            title: "Shop only",
            scopes: [Scope(id: "shop", label: "Shop")],
            providers: [edge],
            stores: [],
            clients: [],
            services: services(["gateway"], on: "edge") + services(["cart", "pay", "ship", "track"], on: "edge", scopes: ["shop"]),
            data: []
        )
    )

    static let sharedStoresWrapping = LayoutFixture(
        name: "five shared stores on the second provider",
        document: ScopedDocument(keeping: StackmapDocument(
            providers: [edge, cloud],
            stores: (1 ... 5).map { Store(id: "st\($0)", label: "Store \($0)", provider: "cloud") },
            services: services(["api"], on: "edge") + services(["worker"], on: "cloud"),
            data: (1 ... 5).map { DataItem(id: "d\($0)", label: "Data \($0)", store: "st\($0)", owner: "api") }
                + [DataItem(id: "own", label: "Own", store: "st1", owner: "worker")]
        ))
    )
}
