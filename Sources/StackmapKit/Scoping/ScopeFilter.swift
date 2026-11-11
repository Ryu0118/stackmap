/// Narrows a document to one ``ScopeSelection``.
package struct ScopeFilter: Sendable {
    /// Creates a filter.
    package init() {}

    /// Returns the entries kept for `selection`.
    package func filter(_: StackmapDocument, selection _: ScopeSelection) throws(ScopeFilterError) -> ScopedDocument {
        fatalError("Not implemented")
    }
}
