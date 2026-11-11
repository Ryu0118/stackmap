import StackmapKit

extension LayoutFixture {
    private static let scopes = [Scope(id: "shop", label: "Shop"), Scope(id: "ops", label: "Ops")]

    static let scopeOrdering = LayoutFixture(
        name: "services ordered by first scope with unscoped last",
        document: ScopedDocument(keeping: StackmapDocument(
            scopes: scopes,
            providers: [Provider(id: "edge", label: "Edge")],
            stores: [Store(id: "sql", label: "SQL", provider: "edge")],
            services: [
                Service(id: "free-a", label: "free-a", provider: "edge"),
                Service(id: "ops-a", label: "ops-a", provider: "edge", scopes: ["ops"]),
                Service(id: "shop-a", label: "shop-a", provider: "edge", scopes: ["shop"]),
                Service(id: "shop-b", label: "shop-b", provider: "edge", scopes: ["shop"]),
                Service(id: "free-b", label: "free-b", provider: "edge"),
            ],
            data: [DataItem(id: "rows", label: "Rows", store: "sql", owner: "shop-b")]
        ))
    )

    static let scopedAcrossProviders = LayoutFixture(
        name: "scoped services in two providers",
        document: ScopedDocument(keeping: StackmapDocument(
            scopes: scopes,
            providers: [Provider(id: "edge", label: "Edge"), Provider(id: "cloud", label: "Cloud")],
            stores: [Store(id: "docs", label: "Docs", provider: "cloud")],
            services: [
                Service(id: "cloud-ops", label: "cloud-ops", provider: "cloud", scopes: ["ops"]),
                Service(id: "cloud-shop", label: "cloud-shop", provider: "cloud", scopes: ["shop"]),
                Service(id: "edge-ops", label: "edge-ops", provider: "edge", scopes: ["ops"]),
                Service(id: "edge-shop", label: "edge-shop", provider: "edge", scopes: ["shop"]),
            ],
            data: [DataItem(id: "orders", label: "Orders", store: "docs", owner: "edge-shop")]
        ))
    )

    static let scopesDeclaredButUnused = LayoutFixture(
        name: "scopes declared but no service uses one",
        document: ScopedDocument(keeping: StackmapDocument(
            scopes: scopes,
            providers: [Provider(id: "edge", label: "Edge")],
            services: [
                Service(id: "api", label: "api", provider: "edge"),
                Service(id: "bot", label: "bot", provider: "edge"),
            ]
        ))
    )

    static let selectedScope = LayoutFixture(
        name: "a single selected scope",
        document: ScopedDocument(
            selection: .scope("shop"),
            title: "Shop only",
            scopes: [Scope(id: "shop", label: "Shop")],
            providers: [Provider(id: "edge", label: "Edge")],
            stores: [Store(id: "sql", label: "SQL", provider: "edge")],
            clients: [Client(id: "web", label: "Web", calls: ["api"])],
            services: [
                Service(id: "api", label: "api", provider: "edge", scopes: ["shop"]),
                Service(id: "gateway", label: "gateway", provider: "edge"),
            ],
            data: [DataItem(id: "orders", label: "Orders", store: "sql", owner: "api")]
        )
    )

    static let noScopesDeclared = LayoutFixture(
        name: "whole system without declared scopes",
        document: ScopedDocument(keeping: StackmapDocument(
            providers: [Provider(id: "edge", label: "Edge")],
            stores: [Store(id: "sql", label: "SQL", provider: "edge")],
            services: [Service(id: "api", label: "api", provider: "edge")],
            data: [DataItem(id: "orders", label: "Orders", store: "sql", owner: "api")]
        ))
    )
}
