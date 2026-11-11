/// A failure to select a scope.
package enum ScopeFilterError: Error, Equatable, Sendable {
    /// The document declares no scope with this id.
    case unknownScope(String)
}
