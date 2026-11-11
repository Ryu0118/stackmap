/// Every problem found in a stack map file. Never empty.
package struct DocumentLoadingError: Error, Equatable, Sendable {
    /// The problems, in no particular order.
    package var issues: [DocumentIssue]

    /// Creates an error from the collected problems.
    package init(issues: [DocumentIssue]) {
        self.issues = issues
    }
}
