/// Renders the HTML of one diagram card.
struct CardRenderer {
    let context: RenderContext
    private let clients: [String: Client]
    private let services: [String: Service]
    private let placement: DataPlacement

    init(context: RenderContext, view: ScopedDocument) {
        self.context = context
        clients = Dictionary(view.clients.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        services = Dictionary(view.services.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        placement = DataPlacement(view)
    }

    func render(_ node: DiagramNode) -> String {
        let id = node.nodeID
        let body = switch id.kind {
        case .client: titled(clients[id.id]?.label, clients[id.id]?.description)
        case .service: titled(services[id.id]?.label, services[id.id]?.description)
        case .serviceStores: placement.localData[id.id, default: []].map { line($0, showsStore: true) }.joined()
        case .sharedStore: sharedBody(id.id)
        }
        let frame = node.frame
        let style = "left:\(frame.x)px;top:\(frame.y)px;width:\(frame.width)px;height:\(frame.height)px"
        return "<div class=\"card card-\(id.kind.rawValue)\" data-node=\"\(id.kind.rawValue):\(id.id.htmlEscaped)\" style=\"\(style)\">\(body)</div>"
    }

    private func titled(_ label: String?, _ description: String?) -> String {
        let title = "<strong>\((label ?? "").htmlEscaped)</strong>"
        guard let description else { return "<div class=\"text\">\(title)</div>" }

        return "<div class=\"text\">\(title)<span>\(description.htmlEscaped)</span></div>"
    }

    private func sharedBody(_ storeID: String) -> String {
        let header = "<div class=\"card-title\">\(chip(storeID))</div>"
        return header + placement.sharedData[storeID, default: []].map { line($0, showsStore: false) }.joined()
    }

    private func line(_ item: DataItem, showsStore: Bool) -> String {
        let tooltip = ([item.label] + item.identifiers).joined(separator: " · ")
        let target = item.migration.map { " → \(context.storeLabel($0.to))" } ?? ""
        let prefix = showsStore ? chip(item.store) : ""
        return "<div class=\"line status-\(item.status.rawValue)\" title=\"\(tooltip.htmlEscaped)\">\(prefix)<span class=\"text\">\((item.label + target).htmlEscaped)</span></div>"
    }

    private func chip(_ storeID: String) -> String {
        "<span class=\"chip c\(context.storeColor(storeID))\">\(context.storeLabel(storeID).htmlEscaped)</span>"
    }
}
