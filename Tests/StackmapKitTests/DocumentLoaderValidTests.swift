import StackmapKit
import Testing

@Suite("Loading valid stack map files")
struct DocumentLoaderValidTests {
    let loader = DocumentLoader()

    @Test("the example from the configuration guide loads into the expected document")
    func specExampleLoads() throws {
        let document = try loader.load(yaml: SpecExample.yaml)

        // Catches a mis-mapped key, a reordered list, or a wrong default anywhere in the schema.
        #expect(document == SpecExample.document)
    }

    @Test("a file with only a version loads with every default")
    func versionOnlyUsesDefaults() throws {
        let document = try loader.load(yaml: "version: 1\n")

        // Catches a wrong default title or a nil list instead of an empty one.
        #expect(document == StackmapDocument())
        #expect(document.title == "Stack Map")
    }

    @Test("data without status, scopes, or identifiers gets live and empty lists")
    func dataDefaults() throws {
        let yaml = """
        version: 1
        providers:
          - id: edge
            label: Edge
        stores:
          - id: sql
            label: SQL
            provider: edge
        services:
          - id: api
            label: API
            provider: edge
        data:
          - id: orders
            label: Orders
            store: sql
            owner: api
        """
        let document = try loader.load(yaml: yaml)
        let item = try #require(document.data.first)

        // Catches status defaulting to planned, or optional lists staying unset.
        #expect(item.status == .live)
        #expect(item.scopes.isEmpty)
        #expect(item.identifiers.isEmpty)
        #expect(item.migration == nil)
    }

    @Test("clients and services without scopes or description keep them empty")
    func optionalFieldsDefault() throws {
        let yaml = """
        version: 1
        providers:
          - id: edge
            label: Edge
        clients:
          - id: web
            label: Web
        services:
          - id: api
            label: API
            provider: edge
        """
        let document = try loader.load(yaml: yaml)

        // Catches an empty string substituted for a missing description, or a missing calls list failing.
        #expect(document.clients == [Client(id: "web", label: "Web")])
        #expect(document.services == [Service(id: "api", label: "API", provider: "edge")])
    }

    @Test("lists keep declaration order instead of being sorted")
    func declarationOrderIsKept() throws {
        let yaml = """
        version: 1
        scopes:
          - id: zeta
            label: Z
          - id: alpha
            label: A
        providers:
          - id: second
            label: Second
          - id: first
            label: First
        """
        let document = try loader.load(yaml: yaml)

        // Catches ids collected through a dictionary or sorted alphabetically.
        #expect(document.scopes.map(\.id) == ["zeta", "alpha"])
        #expect(document.providers.map(\.id) == ["second", "first"])
    }

    @Test("a migration note is optional")
    func migrationWithoutNote() throws {
        let yaml = YAMLBuilder().with {
            $0.dataExtra = "status: migrating\n    migration:\n      to: sql"
        }.yaml
        let item = try #require(try loader.load(yaml: yaml).data.first)

        // Catches a missing note being treated as an error or as an empty string.
        #expect(item.status == .migrating)
        #expect(item.migration == Migration(to: "sql", note: nil))
    }

    @Test("planned and live statuses load", arguments: [DataStatus.live, DataStatus.planned])
    func nonMigratingStatuses(status: DataStatus) throws {
        let yaml = YAMLBuilder().with { $0.dataExtra = "status: \(status.rawValue)" }.yaml
        let item = try #require(try loader.load(yaml: yaml).data.first)

        // Catches a status keyword that is not mapped to its case.
        #expect(item.status == status)
    }

    @Test("the same id may be used in different lists")
    func sameIDAcrossLists() throws {
        let yaml = """
        version: 1
        scopes:
          - id: edge
            label: Scope
        providers:
          - id: edge
            label: Provider
        stores:
          - id: edge
            label: Store
            provider: edge
        services:
          - id: edge
            label: Service
            provider: edge
            scopes: [edge]
        """
        let document = try loader.load(yaml: yaml)

        // Catches uniqueness being enforced across lists instead of within each list.
        #expect(document.services.map(\.id) == ["edge"])
        #expect(document.stores.map(\.provider) == ["edge"])
    }

    @Test("ids made of letters, digits, hyphens, and underscores are valid", arguments: ["a", "9lives", "A-b_c", "x1-2_3"])
    func validIDs(id: String) throws {
        let yaml = "version: 1\nscopes:\n  - id: \(id)\n    label: Scope\n"
        let document = try loader.load(yaml: yaml)

        // Catches an id pattern that is too strict, such as one that rejects a leading digit.
        #expect(document.scopes == [Scope(id: id, label: "Scope")])
    }
}
