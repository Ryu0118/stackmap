import Foundation

extension String {
    /// How many times `needle` occurs, without overlaps.
    func occurrences(of needle: String) -> Int {
        components(separatedBy: needle).count - 1
    }

    /// The values of `attribute` on every `<tag ...>` start tag, in page order.
    func attributeValues(of attribute: String, onTag tag: String) -> [String] {
        guard let regex = try? Regex("<\(tag)\\b[^>]*?\\b\(attribute)=\"([^\"]*)\"") else { return [] }
        return matches(of: regex).compactMap { match in
            match.output[1].substring.map(String.init)
        }
    }
}
