import Yams

extension DocumentDecoder {
    mutating func decodeScope(_ fields: [String: Node], path: String) -> Scope? {
        let id = reader.requiredString(fields, key: "id", path: path)
        let label = reader.requiredString(fields, key: "label", path: path)
        guard let id, let label else { return nil }

        return Scope(id: id, label: label)
    }

    mutating func decodeProvider(_ fields: [String: Node], path: String) -> Provider? {
        let id = reader.requiredString(fields, key: "id", path: path)
        let label = reader.requiredString(fields, key: "label", path: path)
        guard let id, let label else { return nil }

        return Provider(id: id, label: label)
    }

    mutating func decodeStore(_ fields: [String: Node], path: String) -> Store? {
        let id = reader.requiredString(fields, key: "id", path: path)
        let label = reader.requiredString(fields, key: "label", path: path)
        let provider = reader.requiredString(fields, key: "provider", path: path)
        guard let id, let label, let provider else { return nil }

        return Store(id: id, label: label, provider: provider)
    }

    mutating func decodeClient(_ fields: [String: Node], path: String) -> Client? {
        let id = reader.requiredString(fields, key: "id", path: path)
        let label = reader.requiredString(fields, key: "label", path: path)
        let description = reader.optionalString(fields, key: "description", path: path)
        let scopes = reader.stringList(fields, key: "scopes", path: path)
        let calls = reader.stringList(fields, key: "calls", path: path)
        guard let id, let label else { return nil }

        return Client(id: id, label: label, description: description, scopes: scopes, calls: calls)
    }

    mutating func decodeService(_ fields: [String: Node], path: String) -> Service? {
        let id = reader.requiredString(fields, key: "id", path: path)
        let label = reader.requiredString(fields, key: "label", path: path)
        let description = reader.optionalString(fields, key: "description", path: path)
        let provider = reader.requiredString(fields, key: "provider", path: path)
        let scopes = reader.stringList(fields, key: "scopes", path: path)
        guard let id, let label, let provider else { return nil }

        return Service(id: id, label: label, description: description, provider: provider, scopes: scopes)
    }
}
