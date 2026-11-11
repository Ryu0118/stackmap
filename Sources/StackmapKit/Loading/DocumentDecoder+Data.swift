import Yams

extension DocumentDecoder {
    mutating func decodeData(_ fields: [String: Node], path: String) -> DataItem? {
        let id = reader.requiredString(fields, key: "id", path: path)
        let label = reader.requiredString(fields, key: "label", path: path)
        let store = reader.requiredString(fields, key: "store", path: path)
        let owner = reader.requiredString(fields, key: "owner", path: path)
        let scopes = reader.stringList(fields, key: "scopes", path: path)
        let identifiers = reader.stringList(fields, key: "identifiers", path: path)
        let status = decodeStatus(fields, path: path)
        let migration = decodeMigration(fields, path: path)
        checkMigrationPresence(fields, status: status, path: path)
        guard let id, let label, let store, let owner, let status else { return nil }

        return DataItem(
            id: id,
            label: label,
            store: store,
            owner: owner,
            scopes: scopes,
            identifiers: identifiers,
            status: status,
            migration: migration
        )
    }

    private mutating func checkMigrationPresence(_ fields: [String: Node], status: DataStatus?, path: String) {
        guard let status else { return }

        let hasMigration = fields["migration"].map { $0.tag != Tag(.null) } ?? false
        if status == .migrating, !hasMigration {
            reader.record(.migrationRequired(path: path))
        } else if status != .migrating, hasMigration {
            reader.record(.migrationNotAllowed(path: path))
        }
    }

    private mutating func decodeStatus(_ fields: [String: Node], path: String) -> DataStatus? {
        guard let text = reader.optionalString(fields, key: "status", path: path) else { return .live }
        guard let status = DataStatus(rawValue: text) else {
            reader.record(.invalidStatus(path: NodeReader.join(path, "status"), value: text))
            return nil
        }
        return status
    }

    private mutating func decodeMigration(_ fields: [String: Node], path: String) -> Migration? {
        guard let node = fields["migration"], node.tag != Tag(.null) else { return nil }

        let migrationPath = NodeReader.join(path, "migration")
        guard let migration = reader.mapping(node, path: migrationPath, allowedKeys: ["to", "note"]) else { return nil }
        let target = reader.requiredString(migration, key: "to", path: migrationPath)
        let note = reader.optionalString(migration, key: "note", path: migrationPath)
        return target.map { Migration(to: $0, note: note) }
    }
}
