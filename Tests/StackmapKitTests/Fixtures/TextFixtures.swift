import StackmapKit

enum TextFixtures {
    static let ownCard = NodeID(kind: .serviceStores, id: "api")
    static let sharedCard = NodeID(kind: .sharedStore, id: "docs")
    static let serviceCard = NodeID(kind: .service, id: "api")

    /// One service without data whose card carries `description`.
    static func described(_ description: String) -> ScopedDocument {
        ScopedDocument(keeping: StackmapDocument(
            providers: [Provider(id: "edge", label: "Edge")],
            services: [Service(id: "api", label: "api", description: description, provider: "edge")]
        ))
    }

    /// One service with one data item on its own provider, labeled `label`.
    static func own(label: String) -> ScopedDocument {
        ScopedDocument(keeping: StackmapDocument(
            providers: [Provider(id: "edge", label: "Edge")],
            stores: [Store(id: "sql", label: "SQL", provider: "edge")],
            services: [Service(id: "api", label: "api", provider: "edge")],
            data: [DataItem(id: "item", label: label, store: "sql", owner: "api", identifiers: ["items"])]
        ))
    }

    /// One service with one data item in a store on another provider, labeled `label`.
    static func shared(label: String) -> ScopedDocument {
        ScopedDocument(keeping: StackmapDocument(
            providers: [Provider(id: "edge", label: "Edge"), Provider(id: "cloud", label: "Cloud")],
            stores: [Store(id: "docs", label: "Docs", provider: "cloud")],
            services: [Service(id: "api", label: "api", provider: "edge")],
            data: [DataItem(id: "item", label: label, store: "docs", owner: "api", identifiers: ["items"])]
        ))
    }
}
