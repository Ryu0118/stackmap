/// What a background band groups.
package enum BandKind: String, Hashable, Sendable {
    /// Cards hosted on one provider; the band id is the provider id.
    case provider
    /// Consecutive services with the same first scope; the band id is the scope id.
    case scope
}
