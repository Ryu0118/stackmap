/// A part of the system that can be rendered on its own.
package struct Scope: Equatable, Sendable {
    /// The scope id.
    package var id: String
    /// The label shown on tabs and bands.
    package var label: String

    /// Creates a scope.
    package init(id: String, label: String) {
        self.id = id
        self.label = label
    }
}
