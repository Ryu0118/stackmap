/// The CLI's release version.
///
/// Bumped only by the release workflow, which rewrites this literal and
/// commits the change as part of tagging a release.
enum StackmapVersion {
    static let current = "0.2.0"
}
