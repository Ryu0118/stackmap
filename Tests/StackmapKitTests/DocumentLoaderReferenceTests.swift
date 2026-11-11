import StackmapKit
import Testing

@Suite("Resolving references in stack map files")
struct DocumentLoaderReferenceTests {
    struct Case: Sendable, CustomTestStringConvertible {
        var path: String
        var change: @Sendable (inout YAMLBuilder) -> Void
        var testDescription: String {
            path
        }
    }

    static let cases = [
        Case(path: "stores[0].provider") { $0.storeProvider = "ghost" },
        Case(path: "services[0].provider") { $0.serviceProvider = "ghost" },
        Case(path: "clients[0].calls[1]") { $0.clientCalls = "[api, ghost]" },
        Case(path: "clients[0].scopes[0]") { $0.clientScopes = "[ghost]" },
        Case(path: "services[0].scopes[1]") { $0.serviceScopes = "[shop, ghost]" },
        Case(path: "data[0].store") { $0.dataStore = "ghost" },
        Case(path: "data[0].owner") { $0.dataOwner = "ghost" },
        Case(path: "data[0].scopes[1]") { $0.dataScopes = "[shop, ghost]" },
        Case(path: "data[0].migration.to") {
            $0.dataExtra = "status: migrating\n    migration:\n      to: ghost"
        },
    ]

    let loader = DocumentLoader()

    @Test("the unmodified builder file is valid")
    func baselineLoads() throws {
        // Guards the fixture: every reference case below relies on it loading cleanly.
        _ = try loader.load(yaml: YAMLBuilder().yaml)
    }

    @Test("an unknown id is reported at the reference", arguments: cases)
    func unresolvedReference(testCase: Case) {
        let yaml = YAMLBuilder().with(testCase.change).yaml
        let issues = loader.issues(in: yaml)

        // Catches a reference kind that is never resolved, or one reported with the wrong path.
        #expect(issues == [.unresolvedReference(path: testCase.path, id: "ghost")])
    }

    @Test("a reference must name an id in the matching list, not any list")
    func referenceChecksTheRightList() {
        let yaml = YAMLBuilder().with { $0.clientCalls = "[sql]" }.yaml
        let issues = loader.issues(in: yaml)

        // Catches ids being looked up across all lists: sql is a store, not a service.
        #expect(issues == [.unresolvedReference(path: "clients[0].calls[0]", id: "sql")])
    }

    @Test("a service provider must be a provider, not a store or scope")
    func providerMustBeProvider() {
        let yaml = YAMLBuilder().with { $0.serviceProvider = "shop" }.yaml
        let issues = loader.issues(in: yaml)

        // Catches provider lookups that accept a scope id.
        #expect(issues == [.unresolvedReference(path: "services[0].provider", id: "shop")])
    }

    @Test("each unresolved reference in a list is reported separately")
    func everyBadReferenceIsReported() {
        let yaml = YAMLBuilder().with { $0.clientCalls = "[ghost, api, phantom]" }.yaml
        let issues = loader.issues(in: yaml)

        // Catches validation stopping at the first bad entry of one list.
        #expect(issues.sortedMessages == [
            DocumentIssue.unresolvedReference(path: "clients[0].calls[0]", id: "ghost"),
            .unresolvedReference(path: "clients[0].calls[2]", id: "phantom"),
        ].sortedMessages)
    }
}
