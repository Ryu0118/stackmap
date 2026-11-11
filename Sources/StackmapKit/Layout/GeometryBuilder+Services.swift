extension GeometryBuilder {
    mutating func placeServices() {
        var x = Metrics.margin + Metrics.bandPadding
        var previous: Service?
        for service in placement.services {
            if let previous {
                x += previous.provider == service.provider ? Metrics.columnPitch : Metrics.providerPitch
            }
            columnX[service.id] = x
            placeColumn(service, x: x)
            previous = service
        }
        addProviderBands()
        addScopeBands()
    }

    private mutating func placeColumn(_ service: Service, x: Int) {
        let serviceID = NodeID(kind: .service, id: service.id)
        nodes.append(DiagramNode(nodeID: serviceID, frame: Rect(x: x, y: serviceY, width: Metrics.cardWidth, height: Metrics.serviceHeight)))
        guard let local = placement.localData[service.id], !local.isEmpty else { return }

        let storesID = NodeID(kind: .serviceStores, id: service.id)
        let frame = Rect(x: x + Metrics.storesOffset, y: storesY, width: Metrics.storesWidth, height: Metrics.storesHeight(lines: local.count))
        nodes.append(DiagramNode(nodeID: storesID, frame: frame))
        let centerX = frame.x + frame.width / 2
        let segment = Self.vertical(centerX, from: serviceY + Metrics.serviceHeight, to: storesY - 1)
        edges.append(DiagramEdge(kind: .ownStores, source: serviceID, target: storesID, segments: [segment]))
    }

    private mutating func addProviderBands() {
        let top = serviceY - Metrics.providerLabelHeight - (hasScopeBands ? Metrics.scopeLabelHeight : Metrics.scopePadding)
        for run in runs(of: placement.services, by: \.provider) {
            bands.append(DiagramBand(kind: .provider, id: run.key, frame: span(run.services, top: top, padding: Metrics.bandPadding)))
        }
    }

    private mutating func addScopeBands() {
        guard hasScopeBands else { return }

        let top = serviceY - Metrics.scopeLabelHeight
        for run in runs(of: placement.services, by: { "\($0.provider)\u{0}\(ordering.bandScope(of: $0) ?? "")" }) {
            guard let scope = run.services.first.flatMap(ordering.bandScope(of:)) else { continue }

            bands.append(DiagramBand(kind: .scope, id: scope, frame: span(run.services, top: top, padding: Metrics.scopePadding)))
        }
    }

    private var hasScopeBands: Bool {
        document.selection == .all && placement.services.contains { ordering.bandScope(of: $0) != nil }
    }

    private func span(_ services: [Service], top: Int, padding: Int) -> Rect {
        let left = services.compactMap { columnX[$0.id] }.min() ?? 0
        let right = (services.compactMap { columnX[$0.id] }.max() ?? 0) + Metrics.columnWidth
        return Rect(x: left - padding, y: top, width: right - left + 2 * padding, height: storesBottom + padding - top)
    }

    private func runs(of services: [Service], by key: (Service) -> String) -> [(key: String, services: [Service])] {
        var result: [(key: String, services: [Service])] = []
        for service in services {
            let value = key(service)
            if result.last?.key == value {
                result[result.count - 1].services.append(service)
            } else {
                result.append((value, [service]))
            }
        }
        return result
    }
}
