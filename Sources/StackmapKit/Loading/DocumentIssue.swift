/// One problem found while loading a stack map file.
///
/// `path` names the offending key, such as `services[1].provider`,
/// `clients[0].calls[2]`, or `data[0].migration.to`. Top-level keys use
/// their bare name, such as `version`.
package enum DocumentIssue: Equatable, Sendable, CustomStringConvertible {
    /// The text is not valid YAML, or its root is not a mapping.
    case malformedYAML(String)
    /// `version` is missing (`nil`) or is not `1`.
    case unsupportedVersion(Int?)
    /// A key the schema does not define.
    case unknownKey(path: String)
    /// A required key is absent.
    case missingKey(path: String)
    /// A value has the wrong type, such as a list where a string belongs.
    case invalidType(path: String, expected: String)
    /// An unknown `status` value.
    case invalidStatus(path: String, value: String)
    /// An id that does not match `[A-Za-z0-9][A-Za-z0-9_-]*`.
    case invalidID(path: String, id: String)
    /// An id used twice within one list; `path` points at the second use.
    case duplicateID(path: String, id: String)
    /// A reference to an id that does not exist in the matching list.
    case unresolvedReference(path: String, id: String)
    /// `status` is `migrating` but `migration` is absent; `path` is the data entry.
    case migrationRequired(path: String)
    /// `migration` is present but `status` is not `migrating`; `path` is the data entry.
    case migrationNotAllowed(path: String)
    /// `migration.to` names the data's own store; `path` is `data[n].migration.to`.
    case migrationTargetIsSource(path: String)

    /// A one-line message that starts with the key path when there is one.
    package var description: String {
        switch self {
        case let .malformedYAML(reason): "malformed YAML: \(reason)"
        case let .unsupportedVersion(version): "version: expected 1, found \(version.map(String.init) ?? "nothing")"
        case let .unknownKey(path): "\(path): unknown key"
        case let .missingKey(path): "\(path): required key is missing"
        case let .invalidType(path, expected): "\(path): expected \(expected)"
        case let .invalidStatus(path, value): "\(path): '\(value)' is not one of live, planned, migrating"
        case let .invalidID(path, id): "\(path): '\(id)' is not a valid id"
        case let .duplicateID(path, id): "\(path): id '\(id)' is already used"
        case let .unresolvedReference(path, id): "\(path): no entry with id '\(id)'"
        case let .migrationRequired(path): "\(path): status 'migrating' needs a migration"
        case let .migrationNotAllowed(path): "\(path): migration is only allowed when status is 'migrating'"
        case let .migrationTargetIsSource(path): "\(path): the migration target is the data's own store"
        }
    }
}
