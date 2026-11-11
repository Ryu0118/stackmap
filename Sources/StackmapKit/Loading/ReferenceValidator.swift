/// Checks ids and cross-references of decoded entries.
struct ReferenceValidator {
    private(set) var issues: [DocumentIssue] = []

    mutating func validate(_ decoded: DecodedDocument) {
        let scopeIDs = checkIDs(decoded.scopes.map { ($0.index, $0.value.id) }, list: "scopes", reserved: [Self.wholeSystemScopeID])
        let providerIDs = checkIDs(decoded.providers.map { ($0.index, $0.value.id) }, list: "providers")
        let storeIDs = checkIDs(decoded.stores.map { ($0.index, $0.value.id) }, list: "stores")
        _ = checkIDs(decoded.clients.map { ($0.index, $0.value.id) }, list: "clients")
        let serviceIDs = checkIDs(decoded.services.map { ($0.index, $0.value.id) }, list: "services")
        _ = checkIDs(decoded.data.map { ($0.index, $0.value.id) }, list: "data")

        for entry in decoded.stores {
            check(entry.value.provider, in: providerIDs, path: "stores[\(entry.index)].provider")
        }
        for entry in decoded.services {
            check(entry.value.provider, in: providerIDs, path: "services[\(entry.index)].provider")
            checkList(entry.value.scopes, in: scopeIDs, path: "services[\(entry.index)].scopes")
            checkList(entry.value.calls, in: serviceIDs, path: "services[\(entry.index)].calls")
            for (index, call) in entry.value.calls.enumerated() where call == entry.value.id {
                issues.append(.selfCall(path: "services[\(entry.index)].calls[\(index)]"))
            }
        }
        for entry in decoded.clients {
            checkList(entry.value.scopes, in: scopeIDs, path: "clients[\(entry.index)].scopes")
            checkList(entry.value.calls, in: serviceIDs, path: "clients[\(entry.index)].calls")
        }
        for entry in decoded.data {
            checkData(entry, scopeIDs: scopeIDs, storeIDs: storeIDs, serviceIDs: serviceIDs)
        }
    }

    private mutating func checkData(_ entry: IndexedEntry<DataItem>, scopeIDs: Set<String>, storeIDs: Set<String>, serviceIDs: Set<String>) {
        let path = "data[\(entry.index)]"
        let item = entry.value
        check(item.store, in: storeIDs, path: "\(path).store")
        check(item.owner, in: serviceIDs, path: "\(path).owner")
        checkList(item.scopes, in: scopeIDs, path: "\(path).scopes")
        guard let migration = item.migration else { return }

        check(migration.to, in: storeIDs, path: "\(path).migration.to")
        if migration.to == item.store {
            issues.append(.migrationTargetIsSource(path: "\(path).migration.to"))
        }
    }

    /// The scope id the page uses for the whole-system view.
    private static let wholeSystemScopeID = "all"

    /// Reports invalid, reserved, and duplicate ids and returns the set of ids declared.
    private mutating func checkIDs(_ entries: [(Int, String)], list: String, reserved: Set<String> = []) -> Set<String> {
        var seen: Set<String> = []
        for (index, id) in entries {
            let path = "\(list)[\(index)].id"
            if !Self.isValidID(id) || reserved.contains(id) {
                issues.append(.invalidID(path: path, id: id))
            }
            if !seen.insert(id).inserted {
                issues.append(.duplicateID(path: path, id: id))
            }
        }
        return seen
    }

    private mutating func check(_ id: String, in ids: Set<String>, path: String) {
        if !ids.contains(id) {
            issues.append(.unresolvedReference(path: path, id: id))
        }
    }

    private mutating func checkList(_ list: [String], in ids: Set<String>, path: String) {
        for (index, id) in list.enumerated() {
            check(id, in: ids, path: "\(path)[\(index)]")
        }
    }

    private static func isValidID(_ id: String) -> Bool {
        guard let first = id.unicodeScalars.first, isAlphanumeric(first) else { return false }

        return id.unicodeScalars.allSatisfy { isAlphanumeric($0) || $0 == "-" || $0 == "_" }
    }

    private static func isAlphanumeric(_ scalar: Unicode.Scalar) -> Bool {
        scalar.isASCII && (scalar.properties.isAlphabetic || ("0" ... "9").contains(scalar))
    }
}
