import StackmapKit
import Testing

@Suite("Rejecting malformed stack map files")
struct DocumentLoaderSyntaxTests {
    let loader = DocumentLoader()

    @Test("a missing version is reported as unsupported with nothing found")
    func versionMissing() {
        let issues = loader.issues(in: "title: Example\n")

        // Catches a missing version being accepted or reported as a missing key.
        #expect(issues == [.unsupportedVersion(nil)])
    }

    @Test("any version other than 1 is unsupported", arguments: [0, 2, 10, -1])
    func versionNotOne(version: Int) {
        let issues = loader.issues(in: "version: \(version)\n")

        // Catches a version check that accepts newer versions or compares loosely.
        #expect(issues == [.unsupportedVersion(version)])
    }

    @Test("invalid YAML is reported as malformed")
    func malformedYAML() {
        let issues = loader.issues(in: "version: 1\nscopes: [unclosed\n  - : :\n")

        // Catches a parser error escaping as a crash or a different error type.
        #expect(issues.isSingleMalformedYAML)
    }

    @Test("a root that is not a mapping is reported as malformed", arguments: ["- a\n- b\n", "just text\n", "42\n"])
    func rootNotMapping(yaml: String) {
        let issues = loader.issues(in: yaml)

        // Catches the root being force-cast to a mapping, or such files reported as a missing version.
        #expect(issues.isSingleMalformedYAML)
    }

    @Test("unknown keys are reported with their path")
    func unknownKeys() {
        let yaml = YAMLBuilder().with {
            $0.topLevelExtra = "colour: red"
            $0.scopeExtra = "icon: star"
            $0.serviceExtra = "lable: typo"
            $0.dataExtra = "status: migrating\n    migration:\n      to: sql\n      too: 1"
        }.yaml
        let issues = loader.issues(in: yaml)

        // Catches typos being ignored, or reported with the wrong path format at any nesting level.
        #expect(issues.sortedMessages == [
            DocumentIssue.unknownKey(path: "colour"),
            .unknownKey(path: "scopes[0].icon"),
            .unknownKey(path: "services[0].lable"),
            .unknownKey(path: "data[0].migration.too"),
        ].sortedMessages)
    }

    @Test("a typo in a required key reports both the unknown key and the missing key")
    func typoedRequiredKey() {
        let yaml = """
        version: 1
        providers:
          - id: edge
            lable: Edge
        """
        let issues = loader.issues(in: yaml)

        // Catches a typo hiding the missing required key (or the reverse).
        #expect(issues.sortedMessages == [
            DocumentIssue.unknownKey(path: "providers[0].lable"),
            .missingKey(path: "providers[0].label"),
        ].sortedMessages)
    }

    @Test("a missing required key is reported with its path", arguments: [
        ("scopes", "scopes[0].label", "  - id: shop\n"),
        ("providers", "providers[0].id", "  - label: Edge\n"),
        ("stores", "stores[0].provider", "  - id: sql\n    label: SQL\n"),
        ("clients", "clients[0].label", "  - id: web\n"),
        ("services", "services[0].provider", "  - id: api\n    label: API\n"),
        ("data", "data[0].owner", "  - id: orders\n    label: Orders\n    store: sql\n"),
    ])
    func missingRequiredKey(list: String, path: String, entry: String) {
        let issues = loader.issues(in: "version: 1\n\(list):\n\(entry)")

        // Catches a required key defaulting to empty instead of being reported.
        #expect(issues.contains(.missingKey(path: path)))
    }

    @Test("a migration without a target is a missing key")
    func missingMigrationTarget() {
        let yaml = YAMLBuilder().with {
            $0.dataExtra = "status: migrating\n    migration:\n      note: later"
        }.yaml
        let issues = loader.issues(in: yaml)

        // Catches migration.to being treated as optional.
        #expect(issues == [.missingKey(path: "data[0].migration.to")])
    }

    @Test("values of the wrong type are reported with their path", arguments: [
        ("title: [a, b]", "title"),
        ("scopes: shop", "scopes"),
        ("providers: {id: edge}", "providers"),
    ])
    func wrongTopLevelType(line: String, path: String) {
        let issues = loader.issues(in: "version: 1\n\(line)\n")

        // Catches a list or string being accepted where another type belongs.
        #expect(issues.invalidTypePaths == [path])
    }

    @Test("nested values of the wrong type are reported with their path", arguments: [
        ("serviceExtra", "description: [a]", "services[0].description"),
        ("dataExtra", "identifiers: orders", "data[0].identifiers"),
        ("dataExtra", "identifiers: [a, [b]]", "data[0].identifiers[1]"),
    ])
    func wrongNestedType(field: String, line: String, path: String) {
        var builder = YAMLBuilder()
        if field == "serviceExtra" {
            builder.serviceExtra = line
        } else {
            builder.dataExtra = line
        }
        let issues = loader.issues(in: builder.yaml)

        // Catches a scalar accepted for a list (or the reverse) at a nested path.
        #expect(issues.invalidTypePaths.contains(path))
    }

    @Test("a list or mapping where a string belongs is a type error at that key")
    func wrongTypeForRequiredKeys() {
        let yaml = """
        version: 1
        scopes:
          - id: [x]
            label: Shop
        providers:
          - id: edge
            label: Edge
        services:
          - id: api
            label: API
            provider: edge
            scopes: shop
        """
        let issues = loader.issues(in: yaml)

        // Catches a scalar accepted for a scope list, or a list accepted as an id.
        #expect(issues.invalidTypePaths.sorted() == ["scopes[0].id", "services[0].scopes"])
    }

    @Test("a list entry that is not a mapping is a type error at the entry")
    func entryNotMapping() {
        let issues = loader.issues(in: "version: 1\nservices:\n  - just text\n")

        // Catches a crash or a different path for a non-mapping entry.
        #expect(issues.invalidTypePaths == ["services[0]"])
    }

    @Test("an empty file is malformed YAML", arguments: ["", "\n", "# only a comment\n"])
    func emptyFile(yaml: String) {
        // Catches an empty file being reported as a missing version instead.
        #expect(loader.issues(in: yaml).isSingleMalformedYAML)
    }

    @Test("string values are read as literal text", arguments: ["123", "yes", "on", "true"])
    func literalIDs(id: String) throws {
        let document = try loader.load(yaml: "version: 1\nscopes:\n  - id: \(id)\n    label: Scope\n")

        // Catches YAML scalar typing leaking through: 123 as an Int or yes as a Bool.
        #expect(document.scopes == [Scope(id: id, label: "Scope")])
    }

    @Test("a null value is a missing key", arguments: ["id:", "id: null", "id: ~"])
    func nullIsMissing(line: String) {
        let issues = loader.issues(in: "version: 1\nscopes:\n  - \(line)\n    label: Scope\n")

        // Catches null being read as the text "null" or an empty id.
        #expect(issues == [.missingKey(path: "scopes[0].id")])
    }

    @Test("Shop and shop are different ids")
    func idsAreCaseSensitive() throws {
        let yaml = "version: 1\nscopes:\n  - id: Shop\n    label: A\n  - id: shop\n    label: B\n"
        let document = try loader.load(yaml: yaml)

        // Catches case folding that would report Shop and shop as duplicates.
        #expect(document.scopes.map(\.id) == ["Shop", "shop"])
    }

    @Test("an unknown status is reported with its value")
    func invalidStatus() {
        let yaml = YAMLBuilder().with { $0.dataExtra = "status: done" }.yaml
        let issues = loader.issues(in: yaml)

        // Catches an unknown status silently becoming live.
        #expect(issues == [.invalidStatus(path: "data[0].status", value: "done")])
    }

    @Test("status values are case sensitive", arguments: ["Live", "PLANNED"])
    func statusCaseSensitive(value: String) {
        let yaml = YAMLBuilder().with { $0.dataExtra = "status: \(value)" }.yaml
        let issues = loader.issues(in: yaml)

        // Catches case-insensitive matching that the schema does not promise.
        #expect(issues == [.invalidStatus(path: "data[0].status", value: value)])
    }

    @Test("every problem in a file is reported at once")
    func multipleProblems() {
        let yaml = """
        version: 1
        bogus: 1
        providers:
          - id: edge
            label: Edge
        stores:
          - id: sql
            label: SQL
            provider: ghost
        services:
          - id: api
            label: API
            provider: edge
          - id: api
            label: API again
            provider: edge
        data:
          - id: orders
            label: Orders
            store: sql
            owner: api
            status: done
        """
        let issues = loader.issues(in: yaml)

        // Catches a loader that stops at the first problem or reports a subset.
        #expect(issues.sortedMessages == [
            DocumentIssue.unknownKey(path: "bogus"),
            .unresolvedReference(path: "stores[0].provider", id: "ghost"),
            .duplicateID(path: "services[1].id", id: "api"),
            .invalidStatus(path: "data[0].status", value: "done"),
        ].sortedMessages)
    }
}
