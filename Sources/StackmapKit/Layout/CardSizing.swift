/// Card heights that fit their text; the page's stylesheet draws cards to match.
///
/// Title and description lines are 20 px; a data line is 24 px plus 20 px
/// for each extra wrapped line.
struct CardSizing {
    typealias Metrics = LayoutMetrics

    let placement: DataPlacement
    private let clients: [String: Client]
    private let services: [String: Service]
    private let storeLabels: [String: String]

    init(_ document: ScopedDocument, placement: DataPlacement) {
        self.placement = placement
        clients = Dictionary(document.clients.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        services = Dictionary(document.services.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        storeLabels = Dictionary(document.stores.map { ($0.id, $0.label) }, uniquingKeysWith: { first, _ in first })
    }

    func height(of node: NodeID) -> Int {
        switch node.kind {
        case .client: titled(clients[node.id]?.label, clients[node.id]?.description, minimum: Metrics.minClientHeight)
        case .service: titled(services[node.id]?.label, services[node.id]?.description, minimum: Metrics.minServiceHeight)
        case .serviceStores: 24 + placement.localData[node.id, default: []].map { itemHeight($0, showsStore: true) }.reduce(0, +)
        case .sharedStore: 56 + placement.sharedData[node.id, default: []].map { itemHeight($0, showsStore: false) }.reduce(0, +)
        }
    }

    func storeLabel(_ id: String) -> String {
        storeLabels[id] ?? id
    }

    private func titled(_ label: String?, _ description: String?, minimum: Int) -> Int {
        let width = Metrics.cardWidth - 30
        let title = TextMeasure.lines(label ?? "", fontSize: 14, width: width)
        let detail = description.map { TextMeasure.lines($0, fontSize: 13, width: width) } ?? 0
        return max(minimum, 22 + 20 * (title + detail))
    }
}
