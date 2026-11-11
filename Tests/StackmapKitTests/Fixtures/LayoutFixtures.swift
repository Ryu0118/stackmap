import StackmapKit

extension LayoutFixture {
    static let all: [LayoutFixture] = [
        LayoutFixture(name: "spec example", document: ScopedDocument(keeping: SpecExample.documentWithoutMigration)),
        LayoutFixture(name: "empty document", document: ScopedDocument(keeping: StackmapDocument())),
        singleService,
        multiProvider,
        clientCallingTwoProviders,
        sharedStore,
        manyOtherProviderStores,
        longLabels,
        scopeOrdering,
        scopedAcrossProviders,
        scopesDeclaredButUnused,
        selectedScope,
        noScopesDeclared,
    ]

    static let singleService = LayoutFixture(
        name: "one service without data",
        document: ScopedDocument(keeping: StackmapDocument(
            providers: [Provider(id: "edge", label: "Edge")],
            services: [Service(id: "api", label: "api", provider: "edge")]
        ))
    )

    static let multiProvider = LayoutFixture(
        name: "many services across providers",
        document: ScopedDocument(keeping: StackmapDocument(
            providers: [
                Provider(id: "edge", label: "Edge"),
                Provider(id: "cloud", label: "Cloud"),
                Provider(id: "onprem", label: "On premises"),
            ],
            stores: [
                Store(id: "kv", label: "KV", provider: "edge"),
                Store(id: "docs", label: "Docs", provider: "cloud"),
                Store(id: "ledger", label: "Ledger", provider: "onprem"),
            ],
            clients: [Client(id: "web", label: "Web", calls: ["site", "api"])],
            services: [
                Service(id: "worker", label: "worker", provider: "cloud"),
                Service(id: "site", label: "site", provider: "edge"),
                Service(id: "batch", label: "batch", provider: "cloud"),
                Service(id: "api", label: "api", provider: "edge"),
                Service(id: "legacy", label: "legacy", provider: "onprem"),
            ],
            data: [
                DataItem(id: "sessions", label: "Sessions", store: "kv", owner: "site"),
                DataItem(id: "flags", label: "Flags", store: "kv", owner: "api"),
                DataItem(id: "orders", label: "Orders", store: "docs", owner: "worker"),
                DataItem(id: "jobs", label: "Jobs", store: "docs", owner: "batch"),
                DataItem(id: "audit", label: "Audit", store: "docs", owner: "api"),
                DataItem(id: "cache", label: "Cache", store: "kv", owner: "worker"),
                DataItem(id: "books", label: "Books", store: "ledger", owner: "legacy"),
            ]
        ))
    )

    static let clientCallingTwoProviders = LayoutFixture(
        name: "a client calling services in two providers",
        document: ScopedDocument(keeping: StackmapDocument(
            providers: [Provider(id: "edge", label: "Edge"), Provider(id: "cloud", label: "Cloud")],
            clients: [
                Client(id: "mobile", label: "Mobile", calls: ["api", "worker"]),
                Client(id: "cron", label: "Cron", calls: ["worker"]),
                Client(id: "idle", label: "Idle"),
            ],
            services: [
                Service(id: "api", label: "api", provider: "edge"),
                Service(id: "worker", label: "worker", provider: "cloud"),
            ]
        ))
    )

    static let sharedStore = LayoutFixture(
        name: "a store on another provider shared by several services",
        document: ScopedDocument(keeping: StackmapDocument(
            providers: [Provider(id: "edge", label: "Edge"), Provider(id: "cloud", label: "Cloud")],
            stores: [Store(id: "docs", label: "Docs", provider: "cloud")],
            services: [
                Service(id: "api", label: "api", provider: "edge"),
                Service(id: "bot", label: "bot", provider: "edge"),
                Service(id: "cms", label: "cms", provider: "edge"),
                Service(id: "worker", label: "worker", provider: "cloud"),
            ],
            data: [
                DataItem(id: "orders", label: "Orders", store: "docs", owner: "api"),
                DataItem(id: "chats", label: "Chats", store: "docs", owner: "bot"),
                DataItem(id: "pages", label: "Pages", store: "docs", owner: "cms"),
                DataItem(id: "jobs", label: "Jobs", store: "docs", owner: "worker"),
            ]
        ))
    )

    static let manyOtherProviderStores = LayoutFixture(
        name: "a service owning data in several other-provider stores",
        document: ScopedDocument(keeping: StackmapDocument(
            providers: [Provider(id: "edge", label: "Edge"), Provider(id: "cloud", label: "Cloud")],
            stores: [
                Store(id: "sql", label: "SQL", provider: "edge"),
                Store(id: "docs", label: "Docs", provider: "cloud"),
                Store(id: "blobs", label: "Blobs", provider: "cloud"),
                Store(id: "queue", label: "Queue", provider: "cloud"),
            ],
            services: [
                Service(id: "api", label: "api", provider: "edge"),
                Service(id: "bot", label: "bot", provider: "edge"),
            ],
            data: [
                DataItem(id: "users", label: "Users", store: "sql", owner: "api"),
                DataItem(id: "orders", label: "Orders", store: "docs", owner: "api"),
                DataItem(id: "files", label: "Files", store: "blobs", owner: "api"),
                DataItem(id: "tasks", label: "Tasks", store: "queue", owner: "api"),
                DataItem(id: "chats", label: "Chats", store: "docs", owner: "bot"),
            ]
        ))
    )

    static let longLabels = LayoutFixture(
        name: "long labels and descriptions",
        document: ScopedDocument(keeping: StackmapDocument(
            providers: [
                Provider(id: "edge", label: String(repeating: "A very long provider label ", count: 6)),
                Provider(id: "cloud", label: "Cloud"),
            ],
            stores: [
                Store(id: "sql", label: String(repeating: "Relational store ", count: 8), provider: "edge"),
                Store(id: "docs", label: String(repeating: "Document store ", count: 8), provider: "cloud"),
            ],
            clients: [Client(
                id: "mobile",
                label: String(repeating: "Mobile application ", count: 8),
                description: String(repeating: "Used by every customer ", count: 8),
                calls: ["api"]
            )],
            services: [
                Service(
                    id: "api",
                    label: String(repeating: "public-api-", count: 12),
                    description: String(repeating: "Handles every public request ", count: 10),
                    provider: "edge"
                ),
                Service(id: "tiny", label: "t", provider: "edge"),
            ],
            data: [
                DataItem(
                    id: "orders",
                    label: String(repeating: "Customer orders and invoices ", count: 6),
                    store: "sql",
                    owner: "api",
                    identifiers: ["orders", String(repeating: "very_long_table_name_", count: 6)]
                ),
                DataItem(id: "events", label: String(repeating: "Event stream ", count: 9), store: "docs", owner: "api"),
                DataItem(id: "x", label: "x", store: "docs", owner: "tiny"),
            ]
        ))
    )
}
