import StackmapKit

extension LayoutFixture {
    static let serviceCalls: [LayoutFixture] = [
        callToNeighbor,
        callToNextRow,
        callUpward,
        mutualCalls,
        repeatedCalls,
    ]

    private static let edge = Provider(id: "edge", label: "Edge")
    private static let cloud = Provider(id: "cloud", label: "Cloud")

    static let callToNeighbor = LayoutFixture(
        name: "a service calling its neighbour in the same row",
        document: ScopedDocument(keeping: StackmapDocument(
            providers: [edge],
            services: [
                Service(id: "a", label: "a", provider: "edge", calls: ["b"]),
                Service(id: "b", label: "b", provider: "edge"),
                Service(id: "c", label: "c", provider: "edge", calls: ["b"]),
                Service(id: "d", label: "d", provider: "edge"),
            ]
        ))
    )

    static let callToNextRow = LayoutFixture(
        name: "services calling into the adjacent column of the next row",
        document: ScopedDocument(keeping: StackmapDocument(
            providers: [edge],
            stores: [Store(id: "sql", label: "SQL", provider: "edge")],
            services: [
                Service(id: "a", label: "a", provider: "edge"),
                Service(id: "b", label: "b", provider: "edge", calls: ["e", "f"]),
                Service(id: "c", label: "c", provider: "edge", calls: ["b"]),
                Service(id: "d", label: "d", provider: "edge", calls: ["e"]),
                Service(id: "e", label: "e", provider: "edge"),
                Service(id: "f", label: "f", provider: "edge"),
            ],
            data: ["a", "b", "c", "d", "e"].map { DataItem(id: "d-\($0)", label: "Data", store: "sql", owner: $0) }
        ))
    )

    static let callUpward = LayoutFixture(
        name: "a service calling a service in an earlier provider band",
        document: ScopedDocument(keeping: StackmapDocument(
            providers: [edge, cloud],
            stores: [Store(id: "kv", label: "KV", provider: "edge"), Store(id: "docs", label: "Docs", provider: "cloud")],
            clients: [Client(id: "web", label: "Web", calls: ["api"])],
            services: [
                Service(id: "api", label: "api", provider: "edge"),
                Service(id: "site", label: "site", provider: "edge"),
                Service(id: "worker", label: "worker", provider: "cloud", calls: ["api", "site"]),
            ],
            data: [
                DataItem(id: "flags", label: "Flags", store: "kv", owner: "api"),
                DataItem(id: "jobs", label: "Jobs", store: "docs", owner: "worker"),
            ]
        ))
    )

    static let mutualCalls = LayoutFixture(
        name: "two services calling each other",
        document: ScopedDocument(keeping: StackmapDocument(
            providers: [edge],
            clients: [Client(id: "web", label: "Web", calls: ["a", "b"])],
            services: [
                Service(id: "a", label: "a", provider: "edge", calls: ["b"]),
                Service(id: "b", label: "b", provider: "edge", calls: ["a"]),
            ]
        ))
    )

    static let repeatedCalls = LayoutFixture(
        name: "calls that repeat an id",
        document: ScopedDocument(keeping: StackmapDocument(
            providers: [edge],
            clients: [Client(id: "web", label: "Web", calls: ["api", "api", "bot"])],
            services: [
                Service(id: "api", label: "api", provider: "edge", calls: ["bot", "bot"]),
                Service(id: "bot", label: "bot", provider: "edge"),
            ]
        ))
    )
}
