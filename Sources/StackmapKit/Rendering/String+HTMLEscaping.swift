extension String {
    /// The string with `&`, `<`, `>`, `"`, and `'` replaced by character references.
    var htmlEscaped: String {
        var result = ""
        result.reserveCapacity(utf8.count)
        for character in self {
            switch character {
            case "&": result += "&amp;"
            case "<": result += "&lt;"
            case ">": result += "&gt;"
            case "\"": result += "&quot;"
            case "'": result += "&#39;"
            default: result.append(character)
            }
        }
        return result
    }
}
