/// Which part of the system to render.
package enum ScopeSelection: Equatable, Sendable {
    /// The whole system.
    case all
    /// One scope, by id.
    case scope(String)
}
