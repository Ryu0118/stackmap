import StackmapKit
import Testing

@Suite("Validating ids in stack map files")
struct DocumentLoaderIDTests {
    let loader = DocumentLoader()

    @Test("ids that break the id pattern are rejected", arguments: ["", "-lead", "_lead", "has space", "dot.ted", "slash/y", "ünï"])
    func invalidIDs(id: String) {
        let yaml = "version: 1\nscopes:\n  - id: \"\(id)\"\n    label: Scope\n"
        let issues = loader.issues(in: yaml)

        // Catches an id pattern that allows spaces, dots, or a leading separator, or an empty id slipping through.
        #expect(issues == [.invalidID(path: "scopes[0].id", id: id)])
    }

    @Test("an invalid id is reported in every list", arguments: [
        ("providers", "providers[0].id", "  - id: \"a b\"\n    label: P\n"),
        ("stores", "stores[0].id", "  - id: \"a b\"\n    label: S\n    provider: edge\n"),
        ("clients", "clients[0].id", "  - id: \"a b\"\n    label: C\n"),
        ("services", "services[0].id", "  - id: \"a b\"\n    label: V\n    provider: edge\n"),
    ])
    func invalidIDInEachList(list: String, path: String, entry: String) {
        let provider = list == "providers" ? "" : "providers:\n  - id: edge\n    label: Edge\n"
        let issues = loader.issues(in: "version: 1\n\(provider)\(list):\n\(entry)")

        // Catches id validation being applied to only some lists.
        #expect(issues == [.invalidID(path: path, id: "a b")])
    }

    @Test("a data id is validated too")
    func invalidDataID() {
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
          - id: "-bad"
            label: Orders
            store: sql
            owner: api
        """
        let issues = loader.issues(in: yaml)

        // Catches the data list being skipped by id validation.
        #expect(issues == [.invalidID(path: "data[0].id", id: "-bad")])
    }

    @Test("a duplicate id is reported at its second use")
    func duplicateIDPointsAtSecondUse() {
        let yaml = """
        version: 1
        scopes:
          - id: shop
            label: First
          - id: ops
            label: Other
          - id: shop
            label: Second
        """
        let issues = loader.issues(in: yaml)

        // Catches the report pointing at the first use, or at every use.
        #expect(issues == [.duplicateID(path: "scopes[2].id", id: "shop")])
    }

    @Test("an id used three times is reported for the second and third use")
    func tripleDuplicate() {
        let yaml = """
        version: 1
        providers:
          - id: edge
            label: A
          - id: edge
            label: B
          - id: edge
            label: C
        """
        let issues = loader.issues(in: yaml)

        // Catches only the first duplicate being reported.
        #expect(issues.sortedMessages == [
            DocumentIssue.duplicateID(path: "providers[1].id", id: "edge"),
            .duplicateID(path: "providers[2].id", id: "edge"),
        ].sortedMessages)
    }
}
