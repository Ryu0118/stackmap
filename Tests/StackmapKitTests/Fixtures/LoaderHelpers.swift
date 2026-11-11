import StackmapKit
import Testing

extension DocumentLoader {
    /// The issues `yaml` is rejected with; records a failure when it loads.
    func issues(in yaml: String, sourceLocation: SourceLocation = #_sourceLocation) -> [DocumentIssue] {
        do {
            _ = try load(yaml: yaml)
            Issue.record("Expected the file to be rejected", sourceLocation: sourceLocation)
            return []
        } catch {
            return error.issues
        }
    }
}

extension [DocumentIssue] {
    /// The issues as sorted one-line messages, for comparing without order.
    var sortedMessages: [String] {
        map(\.description).sorted()
    }

    /// The paths of the `invalidType` issues.
    var invalidTypePaths: [String] {
        compactMap { issue in
            if case let .invalidType(path, _) = issue {
                path
            } else {
                nil
            }
        }
    }
}

extension [DocumentIssue] {
    /// Whether the only issue is a `malformedYAML`.
    var isSingleMalformedYAML: Bool {
        guard count == 1, case .malformedYAML = self[0] else { return false }
        return true
    }
}
