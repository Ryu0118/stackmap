/// Renders the store summary, the migrations, and the data table of one scope.
struct ListRenderer {
    let context: RenderContext
    let view: ScopedDocument

    func render() -> String {
        guard !view.data.isEmpty else {
            return "<p class=\"empty\">No data in this scope.</p>"
        }

        return summary() + migrations() + table()
    }

    private func summary() -> String {
        let items = view.stores.map { store in
            let count = view.data.count(where: { $0.store == store.id })
            let provider = context.providerLabel(store.provider)
            return "<li><span class=\"chip c\(context.storeColor(store.id))\">\(store.label.htmlEscaped)</span>"
                + "<span class=\"count\">\(count)</span><span class=\"muted\">\(provider.htmlEscaped)</span></li>"
        }
        return "<ul class=\"summary\">\(items.joined())</ul>"
    }

    private func migrations() -> String {
        let moving = view.data.filter { $0.migration != nil }
        guard !moving.isEmpty else { return "" }

        let rows = moving.compactMap { item -> String? in
            guard let migration = item.migration else { return nil }

            let note = migration.note.map { "<span class=\"muted\">\($0.htmlEscaped)</span>" } ?? ""
            return "<li><strong>\(item.label.htmlEscaped)</strong>\(chip(item.store))<span class=\"arrow\">→</span>\(chip(migration.to))\(note)</li>"
        }
        return "<h3>Migrations</h3><ul class=\"migrations\">\(rows.joined())</ul>"
    }

    private func table() -> String {
        let rows = view.data.map { item in
            let identifiers = item.identifiers.map { "<code>\($0.htmlEscaped)</code>" }.joined(separator: " ")
            let scopes = context.effectiveScopes(of: item).map(context.scopeLabel).joined(separator: ", ")
            return "<tr data-row=\"\(item.id.htmlEscaped)\"><td>\(item.label.htmlEscaped)</td><td>\(identifiers)</td>"
                + "<td>\(scopes.htmlEscaped)</td><td>\(chip(item.store))</td>"
                + "<td>\(context.serviceLabel(item.owner).htmlEscaped)</td><td>\(status(item))</td></tr>"
        }
        return """
        <div class="table-scroll"><table><thead><tr><th scope="col">Data</th><th scope="col">Identifiers</th>\
        <th scope="col">Scopes</th><th scope="col">Store</th><th scope="col">Owner</th><th scope="col">Status</th></tr></thead>\
        <tbody>\(rows.joined())</tbody></table></div>
        """
    }

    private func status(_ item: DataItem) -> String {
        let target = item.migration.map { " → \(context.storeLabel($0.to))" } ?? ""
        return "<span class=\"status status-\(item.status.rawValue)\">\((item.status.rawValue + target).htmlEscaped)</span>"
    }

    private func chip(_ storeID: String) -> String {
        "<span class=\"chip c\(context.storeColor(storeID))\">\(context.storeLabel(storeID).htmlEscaped)</span>"
    }
}
