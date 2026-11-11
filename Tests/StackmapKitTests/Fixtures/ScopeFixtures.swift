import StackmapKit

enum ScopeFixtures {
    private static let scopes = [Scope(id: "shop", label: "Shop"), Scope(id: "ops", label: "Ops")]
    private static let edge = Provider(id: "edge", label: "Edge")
    private static let sqlStore = Store(id: "sql", label: "SQL", provider: "edge")

    static let unscoped = StackmapDocument(
        scopes: scopes,
        providers: [edge],
        stores: [sqlStore],
        clients: [Client(id: "web", label: "Web", calls: ["api"])],
        services: [Service(id: "api", label: "API", provider: "edge")],
        data: [DataItem(id: "orders", label: "Orders", store: "sql", owner: "api")]
    )

    static let inheritance = StackmapDocument(
        scopes: scopes,
        providers: [edge],
        stores: [sqlStore],
        services: [Service(id: "api", label: "API", provider: "edge", scopes: ["shop"])],
        data: [DataItem(id: "inherited", label: "Inherited", store: "sql", owner: "api")]
    )

    static let override = StackmapDocument(
        scopes: scopes,
        providers: [edge],
        stores: [sqlStore],
        services: [Service(id: "api", label: "API", provider: "edge", scopes: ["shop", "ops"])],
        data: [DataItem(id: "narrowed", label: "Narrowed", store: "sql", owner: "api", scopes: ["ops"])]
    )

    static let orphanedByOwner = StackmapDocument(
        scopes: scopes,
        providers: [edge],
        stores: [sqlStore],
        services: [Service(id: "api", label: "API", provider: "edge", scopes: ["shop"])],
        data: [DataItem(id: "stray", label: "Stray", store: "sql", owner: "api", scopes: ["ops"])]
    )

    static let crossScopeCalls = StackmapDocument(
        scopes: scopes,
        providers: [edge],
        clients: [
            Client(id: "web", label: "Web", calls: ["shop-api", "ops-api"]),
            Client(id: "shop-only", label: "Shop only", scopes: ["shop"], calls: ["shop-api"]),
            Client(id: "lonely", label: "Lonely", calls: ["shop-api"]),
        ],
        services: [
            Service(id: "shop-api", label: "Shop API", provider: "edge", scopes: ["shop"]),
            Service(id: "ops-api", label: "Ops API", provider: "edge", scopes: ["ops"]),
        ]
    )

    static let storeOnOtherProvider = StackmapDocument(
        scopes: scopes,
        providers: [edge, Provider(id: "cloud", label: "Cloud")],
        stores: [Store(id: "docs", label: "Docs", provider: "cloud")],
        services: [
            Service(id: "api", label: "API", provider: "edge", scopes: ["shop"]),
            Service(id: "bot", label: "Bot", provider: "edge", scopes: ["ops"]),
        ],
        data: [DataItem(id: "orders", label: "Orders", store: "docs", owner: "api")]
    )

    static let sharedAcrossScopes = StackmapDocument(
        scopes: scopes,
        providers: [edge],
        stores: [Store(id: "pool", label: "Pool", provider: "edge")],
        services: [
            Service(id: "a", label: "A", provider: "edge", scopes: ["shop"]),
            Service(id: "b", label: "B", provider: "edge", scopes: ["ops"]),
        ],
        data: [
            DataItem(id: "da", label: "DA", store: "pool", owner: "a"),
            DataItem(id: "db", label: "DB", store: "pool", owner: "b"),
        ]
    )

    static let manyServices = StackmapDocument(
        scopes: scopes,
        providers: [edge],
        services: [
            Service(id: "z", label: "Z", provider: "edge", scopes: ["shop"]),
            Service(id: "skip", label: "Skip", provider: "edge", scopes: ["ops"]),
            Service(id: "m", label: "M", provider: "edge", scopes: ["shop"]),
            Service(id: "a", label: "A", provider: "edge", scopes: ["shop"]),
        ]
    )
}
