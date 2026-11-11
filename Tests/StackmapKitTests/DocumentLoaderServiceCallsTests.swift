import StackmapKit
import Testing

@Suite("Service calls in stack map files")
struct DocumentLoaderServiceCallsTests {
    let loader = DocumentLoader()

    private func yaml(callsOfFirst calls: String) -> String {
        """
        version: 1
        providers:
          - id: edge
            label: Edge
        services:
          - id: api
            label: API
            provider: edge
            calls: \(calls)
          - id: bot
            label: Bot
            provider: edge
          - id: worker
            label: Worker
            provider: edge
        """
    }

    @Test("service calls load in the order written, duplicates included")
    func callsKeepOrderAndDuplicates() throws {
        let document = try loader.load(yaml: yaml(callsOfFirst: "[worker, bot, worker]"))

        // Catches calls being sorted, deduplicated, or turned into a set.
        #expect(document.services.first?.calls == ["worker", "bot", "worker"])
    }

    @Test("a service without calls has none")
    func callsDefaultToEmpty() throws {
        let document = try loader.load(yaml: yaml(callsOfFirst: "[]"))

        // Catches a missing default or a wrong call attached to other services.
        #expect(document.services.map(\.calls) == [[], [], []])
    }

    @Test("an unknown id in calls is unresolved at its index")
    func unresolvedCall() {
        let issues = loader.issues(in: yaml(callsOfFirst: "[bot, ghost]"))

        // Catches calls not being resolved, or reported without the list index.
        #expect(issues == [.unresolvedReference(path: "services[0].calls[1]", id: "ghost")])
    }

    @Test("a call must name a service, not a provider")
    func callToNonService() {
        let issues = loader.issues(in: yaml(callsOfFirst: "[edge]"))

        // Catches ids being looked up in the wrong list.
        #expect(issues == [.unresolvedReference(path: "services[0].calls[0]", id: "edge")])
    }

    @Test("a service calling itself is reported at the call, as the only issue")
    func selfCall() {
        let issues = loader.issues(in: yaml(callsOfFirst: "[bot, api]"))

        // Catches self calls being accepted, reported at the service, or also reported as unresolved.
        #expect(issues == [.selfCall(path: "services[0].calls[1]")])
    }

    @Test("every self call in a list is reported")
    func repeatedSelfCall() {
        let issues = loader.issues(in: yaml(callsOfFirst: "[api, api]"))

        // Catches validation stopping after the first self call.
        #expect(issues.sortedMessages == [
            DocumentIssue.selfCall(path: "services[0].calls[0]"),
            .selfCall(path: "services[0].calls[1]"),
        ].sortedMessages)
    }

    @Test("a calls value that is not a list of strings is a type error", arguments: ["api", "{a: b}", "[[bot]]"])
    func invalidCallsType(value: String) {
        let issues = loader.issues(in: yaml(callsOfFirst: value))

        // Catches a scalar or nested list being accepted as calls.
        #expect(issues.invalidTypePaths.count == 1)
        #expect(issues.invalidTypePaths.first?.hasPrefix("services[0].calls") == true)
    }
}
