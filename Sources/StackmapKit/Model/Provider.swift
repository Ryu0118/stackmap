/// A platform that hosts services or stores, drawn as a band.
package struct Provider: Equatable, Sendable {
    /// The provider id.
    package var id: String
    /// The label shown on the band.
    package var label: String

    /// Creates a provider.
    package init(id: String, label: String) {
        self.id = id
        self.label = label
    }
}
