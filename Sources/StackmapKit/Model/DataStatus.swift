/// The lifecycle state of a data item.
package enum DataStatus: String, Equatable, Sendable, CaseIterable {
    /// In use today.
    case live
    /// Not built yet.
    case planned
    /// Moving to another store.
    case migrating
}
