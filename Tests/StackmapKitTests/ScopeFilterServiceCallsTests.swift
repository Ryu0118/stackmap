import StackmapKit
import Testing

@Suite("Service calls when filtering by scope")
struct ScopeFilterServiceCallsTests {
    let filter = ScopeFilter()
    let document = ScopeFixtures.serviceCalls

    private func calls(_ scoped: ScopedDocument) -> [String: [String]] {
        Dictionary(uniqueKeysWithValues: scoped.services.map { ($0.id, $0.calls) })
    }

    @Test("calls to services that are not kept are dropped")
    func dropsCallsToDroppedServices() throws {
        let shop = try filter.filter(document, selection: .scope("shop"))

        // Catches dangling service calls, which would draw connectors to missing cards.
        #expect(calls(shop) == ["a": ["b"], "b": [], "d": ["a"]])
    }

    @Test("calls within a scope are kept in order")
    func keepsCallsWithinScope() throws {
        let ops = try filter.filter(document, selection: .scope("ops"))

        // Catches calls being dropped by the caller's scope instead of the callee's.
        #expect(calls(ops) == ["c": [], "d": ["c"]])
    }

    @Test("the whole system keeps every call")
    func allKeepsEveryCall() throws {
        let all = try filter.filter(document, selection: .all)

        // Catches filtering being applied to the whole-system view.
        #expect(calls(all) == ["a": ["b", "c"], "b": [], "c": [], "d": ["a", "c"]])
    }

    @Test("a service whose calls are all dropped stays")
    func serviceStaysWithoutCalls() throws {
        let ops = try filter.filter(document, selection: .scope("ops"))

        // Catches a service being removed because its calls were filtered away.
        #expect(ops.services.map(\.id) == ["c", "d"])
    }
}
