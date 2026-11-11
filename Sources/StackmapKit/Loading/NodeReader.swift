import Yams

/// Reads untyped YAML nodes into values while recording every problem.
///
/// Values that cannot be read come back as `nil` so decoding can continue
/// and report the rest of the file in the same run.
struct NodeReader {
    private(set) var issues: [DocumentIssue] = []

    mutating func record(_ issue: DocumentIssue) {
        issues.append(issue)
    }

    /// Returns the mapping's entries keyed by name, reporting unknown keys.
    mutating func mapping(_ node: Node, path: String, allowedKeys: [String]) -> [String: Node]? {
        guard case let .mapping(mapping) = node else {
            record(.invalidType(path: path, expected: "a mapping"))
            return nil
        }

        var entries: [String: Node] = [:]
        for (key, value) in mapping {
            guard let name = key.string else { continue }
            if allowedKeys.contains(name) {
                entries[name] = value
            } else {
                record(.unknownKey(path: Self.join(path, name)))
            }
        }
        return entries
    }

    /// Reads a required scalar as its literal text.
    mutating func requiredString(_ entries: [String: Node], key: String, path: String) -> String? {
        let keyPath = Self.join(path, key)
        guard let node = entries[key], !Self.isNull(node) else {
            record(.missingKey(path: keyPath))
            return nil
        }
        return scalarText(node, path: keyPath)
    }

    /// Reads an optional scalar as its literal text.
    mutating func optionalString(_ entries: [String: Node], key: String, path: String) -> String? {
        guard let node = entries[key], !Self.isNull(node) else { return nil }

        return scalarText(node, path: Self.join(path, key))
    }

    /// Reads an optional list of scalars; absent means empty.
    mutating func stringList(_ entries: [String: Node], key: String, path: String) -> [String] {
        let keyPath = Self.join(path, key)
        return list(entries, key: key, path: path).enumerated().compactMap { index, node in
            scalarText(node, path: "\(keyPath)[\(index)]")
        }
    }

    /// Reads an optional list of nodes; absent means empty.
    mutating func list(_ entries: [String: Node], key: String, path: String) -> [Node] {
        guard let node = entries[key], !Self.isNull(node) else { return [] }
        guard case let .sequence(sequence) = node else {
            record(.invalidType(path: Self.join(path, key), expected: "a list"))
            return []
        }
        return Array(sequence)
    }

    static func join(_ path: String, _ key: String) -> String {
        path.isEmpty ? key : "\(path).\(key)"
    }

    private mutating func scalarText(_ node: Node, path: String) -> String? {
        guard case let .scalar(scalar) = node else {
            record(.invalidType(path: path, expected: "a string"))
            return nil
        }
        return scalar.string
    }

    private static func isNull(_ node: Node) -> Bool {
        node.tag == Tag(.null)
    }
}
