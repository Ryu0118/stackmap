/// Where a migrating data item is moving.
package struct Migration: Equatable, Sendable {
    /// The id of the destination store.
    package var to: String
    /// An optional note, such as an issue number.
    package var note: String?

    /// Creates a migration.
    package init(to: String, note: String? = nil) {
        self.to = to
        self.note = note
    }
}
