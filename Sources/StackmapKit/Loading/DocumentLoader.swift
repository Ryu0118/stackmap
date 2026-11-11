/// Reads stack map YAML into a validated ``StackmapDocument``.
package struct DocumentLoader: Sendable {
    /// Creates a loader.
    package init() {}

    /// Parses and validates `yaml`, reporting every problem at once.
    package func load(yaml _: String) throws(DocumentLoadingError) -> StackmapDocument {
        fatalError("Not implemented")
    }
}
