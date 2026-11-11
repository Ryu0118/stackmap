import Yams

/// Reads stack map YAML into a validated ``StackmapDocument``.
package struct DocumentLoader: Sendable {
    /// Creates a loader.
    package init() {}

    /// Parses and validates `yaml`, reporting every problem at once.
    package func load(yaml: String) throws(DocumentLoadingError) -> StackmapDocument {
        let root: Node
        do {
            guard let node = try Yams.compose(yaml: yaml) else {
                throw DocumentLoadingError(issues: [.malformedYAML("the file is empty")])
            }
            root = node
        } catch let error as DocumentLoadingError {
            throw error
        } catch {
            throw DocumentLoadingError(issues: [.malformedYAML(String(describing: error))])
        }
        guard case .mapping = root else {
            throw DocumentLoadingError(issues: [.malformedYAML("the root is not a mapping")])
        }

        var decoder = DocumentDecoder()
        let decoded = decoder.decode(root)
        var validator = ReferenceValidator()
        if let decoded {
            validator.validate(decoded)
        }

        let issues = decoder.reader.issues + validator.issues
        guard issues.isEmpty, let decoded else {
            throw DocumentLoadingError(issues: issues)
        }
        return decoded.document
    }
}
