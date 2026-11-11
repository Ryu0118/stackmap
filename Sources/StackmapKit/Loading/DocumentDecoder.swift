import Yams

/// Turns the root YAML node into document entries, recording shape problems.
struct DocumentDecoder {
    var reader = NodeReader()

    mutating func decode(_ root: Node) -> DecodedDocument? {
        let topKeys = ["version", "title", "scopes", "providers", "stores", "clients", "services", "data"]
        guard let entries = reader.mapping(root, path: "", allowedKeys: topKeys) else { return nil }

        checkVersion(entries["version"])
        return DecodedDocument(
            title: reader.optionalString(entries, key: "title", path: "") ?? "Stack Map",
            scopes: decodeList(entries, key: "scopes", keys: ["id", "label"]) { $0.decodeScope($1, path: $2) },
            providers: decodeList(entries, key: "providers", keys: ["id", "label"]) { $0.decodeProvider($1, path: $2) },
            stores: decodeList(entries, key: "stores", keys: ["id", "label", "provider"]) { $0.decodeStore($1, path: $2) },
            clients: decodeList(entries, key: "clients", keys: ["id", "label", "description", "scopes", "calls"]) { $0.decodeClient($1, path: $2) },
            services: decodeList(entries, key: "services", keys: ["id", "label", "description", "provider", "scopes"]) { $0.decodeService($1, path: $2) },
            data: decodeList(
                entries,
                key: "data",
                keys: ["id", "label", "store", "owner", "scopes", "identifiers", "status", "migration"]
            ) { $0.decodeData($1, path: $2) }
        )
    }

    private mutating func checkVersion(_ node: Node?) {
        guard let node, node.tag != Tag(.null) else {
            reader.record(.unsupportedVersion(nil))
            return
        }
        guard case let .scalar(scalar) = node, let version = Int(scalar.string) else {
            reader.record(.invalidType(path: "version", expected: "an integer"))
            return
        }
        if version != 1 {
            reader.record(.unsupportedVersion(version))
        }
    }

    private mutating func decodeList<Value>(
        _ entries: [String: Node],
        key: String,
        keys: [String],
        _ decodeEntry: (inout Self, [String: Node], String) -> Value?
    ) -> [IndexedEntry<Value>] {
        var result: [IndexedEntry<Value>] = []
        for (index, node) in reader.list(entries, key: key, path: "").enumerated() {
            let path = "\(key)[\(index)]"
            guard let fields = reader.mapping(node, path: path, allowedKeys: keys) else { continue }
            if let value = decodeEntry(&self, fields, path) {
                result.append(IndexedEntry(index: index, value: value))
            }
        }
        return result
    }
}
