import StackmapKit
import Testing

@Suite("Validating data migrations")
struct DocumentLoaderMigrationTests {
    let loader = DocumentLoader()

    @Test("a migrating status without a migration is rejected")
    func migratingNeedsMigration() {
        let yaml = YAMLBuilder().with { $0.dataExtra = "status: migrating" }.yaml
        let issues = loader.issues(in: yaml)

        // Catches a migrating item with no destination being accepted.
        #expect(issues == [.migrationRequired(path: "data[0]")])
    }

    @Test("a migration is rejected for any status but migrating", arguments: ["live", "planned"])
    func migrationNotAllowed(status: String) {
        let yaml = YAMLBuilder().with {
            $0.dataExtra = "status: \(status)\n    migration:\n      to: sql"
        }.yaml
        let issues = loader.issues(in: yaml)

        // Catches a stray migration block being ignored for live or planned data.
        #expect(issues == [.migrationNotAllowed(path: "data[0]")])
    }

    @Test("a migration without a status is rejected because the status defaults to live")
    func migrationWithDefaultStatus() {
        let yaml = YAMLBuilder().with { $0.dataExtra = "migration:\n      to: sql" }.yaml
        let issues = loader.issues(in: yaml)

        // Catches the default status being skipped when checking migration.
        #expect(issues == [.migrationNotAllowed(path: "data[0]")])
    }

    @Test("a migration to the data's own store is rejected")
    func targetIsSource() {
        let yaml = YAMLBuilder().with {
            $0.dataExtra = "status: migrating\n    migration:\n      to: docs"
        }.yaml
        let issues = loader.issues(in: yaml)

        // Catches a no-op migration being accepted.
        #expect(issues == [.migrationTargetIsSource(path: "data[0].migration.to")])
    }

    @Test("a valid migration to another store loads with its note")
    func validMigration() throws {
        let yaml = YAMLBuilder().with {
            $0.dataExtra = "status: migrating\n    migration:\n      to: sql\n      note: \"#7\""
        }.yaml
        let item = try #require(try loader.load(yaml: yaml).data.first)

        // Catches the target and note being swapped or dropped.
        #expect(item.migration == Migration(to: "sql", note: "#7"))
    }
}
