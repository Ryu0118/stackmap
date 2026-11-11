/// Per-diagram rules that highlight the connectors of the card under the pointer.
///
/// Uses `:has()` so the page needs no script. Only ids made of ASCII letters,
/// digits, `-`, and `_` get a rule, so nothing in the stylesheet needs escaping.
enum EdgeFocusStyle {
    static func css(for nodes: [NodeID]) -> String {
        nodes.filter { isPlain($0.id) }.map { node in
            let name = "\(node.kind.rawValue):\(node.id)"
            let hovered = ".diagram:has([data-node='\(name)']:hover)"
            return "\(hovered) .edge[data-source='\(name)'],\(hovered) .edge[data-target='\(name)']{opacity:1;stroke-width:3}"
        }.joined()
    }

    private static func isPlain(_ id: String) -> Bool {
        !id.isEmpty && id.unicodeScalars.allSatisfy { $0.isASCII && ($0.properties.isAlphabetic || ("0" ... "9").contains($0) || $0 == "-" || $0 == "_") }
    }
}
