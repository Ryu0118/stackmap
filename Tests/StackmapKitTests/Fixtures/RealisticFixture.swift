import StackmapKit

extension LayoutFixture {
    /// A system shaped like a real one: two providers, three scopes, nine services, four clients,
    /// service calls in every direction, shared stores, and long Japanese labels.
    static let realistic = LayoutFixture(name: "a realistic system", document: ScopedDocument(keeping: realisticDocument))

    static let realisticDocument = StackmapDocument(
        title: "レシピ共有サービス",
        scopes: [Scope(id: "app", label: "アプリ"), Scope(id: "partner", label: "提携店"), Scope(id: "ops", label: "運用")],
        providers: [Provider(id: "cf", label: "Cloudflare"), Provider(id: "fb", label: "Firebase")],
        stores: [
            Store(id: "d1", label: "D1", provider: "cf"),
            Store(id: "kv", label: "KV", provider: "cf"),
            Store(id: "r2", label: "R2", provider: "cf"),
            Store(id: "firestore", label: "Firestore", provider: "fb"),
            Store(id: "storage", label: "Cloud Storage", provider: "fb"),
        ],
        clients: [
            Client(id: "ios", label: "iOS アプリ", scopes: ["app"], calls: ["api", "auth", "media", "api"]),
            Client(id: "partner-app", label: "提携店アプリ", scopes: ["partner"], calls: ["partner-api", "auth"]),
            Client(id: "web", label: "Web サイト", calls: ["site", "api"]),
            Client(id: "slack", label: "Slack", scopes: ["ops"], calls: ["bot"]),
        ],
        services: realisticServices,
        data: realisticData
    )

    private static let realisticServices = [
        Service(id: "api", label: "api", description: "公開 API とアプリ向けのエンドポイント", provider: "cf", scopes: ["app"], calls: ["auth", "push"]),
        Service(id: "auth", label: "auth", description: "認証とトークンの発行", provider: "cf", scopes: ["app", "partner"]),
        Service(id: "media", label: "media", provider: "cf", scopes: ["app"], calls: ["api"]),
        Service(id: "site", label: "site", description: "ランディングページ", provider: "cf"),
        Service(id: "partner-api", label: "partner-api", provider: "cf", scopes: ["partner"], calls: ["api", "auth"]),
        Service(id: "bot", label: "bot", description: "運用通知と問い合わせの自動応答", provider: "cf", scopes: ["ops"], calls: ["api", "aggregator"]),
        Service(id: "push", label: "push", provider: "fb", scopes: ["app"]),
        Service(id: "aggregator", label: "aggregator", description: "閲覧数と保存数の集計", provider: "fb", scopes: ["app"], calls: ["api", "push"]),
        Service(id: "triggers", label: "triggers", provider: "fb", scopes: ["ops"], calls: ["bot", "aggregator"]),
    ]

    private static let longJapanese = String(repeating: "投稿されたレシピと材料と手順の写真", count: 4)

    private static let realisticData = [
        DataItem(id: "users", label: "ユーザー", store: "d1", owner: "api", identifiers: ["users"]),
        DataItem(id: "recipes", label: longJapanese, store: "d1", owner: "api", identifiers: ["recipes", "recipe_likes"]),
        DataItem(id: "sessions", label: "セッション", store: "kv", owner: "auth"),
        DataItem(id: "images", label: "画像", store: "r2", owner: "media"),
        DataItem(id: "shops", label: "提携店の一覧とおすすめの食材", store: "d1", owner: "partner-api"),
        DataItem(id: "tickets", label: "問い合わせ", store: "kv", owner: "bot", status: .planned),
        DataItem(id: "legacy-recipes", label: longJapanese, store: "firestore", owner: "api", identifiers: ["recipes"]),
        DataItem(id: "tokens", label: "プッシュ通知のトークン", store: "firestore", owner: "push"),
        DataItem(id: "stats", label: "集計結果", store: "firestore", owner: "aggregator"),
        DataItem(id: "exports", label: "書き出したレポート", store: "storage", owner: "bot"),
        DataItem(id: "rollups", label: "日次のロールアップ", store: "d1", owner: "aggregator"),
    ]
}
