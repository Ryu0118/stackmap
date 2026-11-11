import StackmapKit

enum SpecExample {
    static let yaml = """
    version: 1
    title: Example Platform

    scopes:
      - id: shop
        label: Shop
      - id: ops
        label: Operations

    providers:
      - id: edge
        label: Cloudflare
      - id: cloud
        label: Firebase

    stores:
      - id: sql
        label: D1
        provider: edge
      - id: cache
        label: KV
        provider: edge
      - id: docs
        label: Firestore
        provider: cloud

    clients:
      - id: mobile
        label: Mobile app
        scopes: [shop]
        calls: [api]

    services:
      - id: api
        label: api
        description: Public API
        provider: edge
        scopes: [shop]
      - id: bot
        label: bot
        description: Chat bot
        provider: edge
        scopes: [ops]

    data:
      - id: orders
        label: Orders
        store: docs
        owner: api
        identifiers: [orders]
        status: migrating
        migration:
          to: sql
          note: "#42"
      - id: sessions
        label: Sessions
        store: cache
        owner: api
      - id: jobs
        label: Scheduled jobs
        store: sql
        owner: bot
        status: planned
    """

    static let document = StackmapDocument(
        title: "Example Platform",
        scopes: [Scope(id: "shop", label: "Shop"), Scope(id: "ops", label: "Operations")],
        providers: [Provider(id: "edge", label: "Cloudflare"), Provider(id: "cloud", label: "Firebase")],
        stores: [
            Store(id: "sql", label: "D1", provider: "edge"),
            Store(id: "cache", label: "KV", provider: "edge"),
            Store(id: "docs", label: "Firestore", provider: "cloud"),
        ],
        clients: [Client(id: "mobile", label: "Mobile app", scopes: ["shop"], calls: ["api"])],
        services: [
            Service(id: "api", label: "api", description: "Public API", provider: "edge", scopes: ["shop"]),
            Service(id: "bot", label: "bot", description: "Chat bot", provider: "edge", scopes: ["ops"]),
        ],
        data: [
            DataItem(
                id: "orders",
                label: "Orders",
                store: "docs",
                owner: "api",
                identifiers: ["orders"],
                status: .migrating,
                migration: Migration(to: "sql", note: "#42")
            ),
            DataItem(id: "sessions", label: "Sessions", store: "cache", owner: "api"),
            DataItem(id: "jobs", label: "Scheduled jobs", store: "sql", owner: "bot", status: .planned),
        ]
    )

    /// The same system without the migration, so derived stores are unambiguous.
    static let documentWithoutMigration: StackmapDocument = {
        var copy = document
        copy.data[0].status = .live
        copy.data[0].migration = nil
        return copy
    }()
}
