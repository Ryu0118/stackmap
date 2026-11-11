extension String {
    /// The string with `&`, `<`, `>`, `"`, and `'` replaced by character references.
    ///
    /// Works on Unicode scalars, not `Character`s: a special character followed
    /// by a combining mark is one grapheme that does not equal `<`, yet an HTML
    /// parser still reads the `<`.
    var htmlEscaped: String {
        var result = String.UnicodeScalarView()
        for scalar in unicodeScalars {
            switch scalar {
            case "&": result.append(contentsOf: "&amp;".unicodeScalars)
            case "<": result.append(contentsOf: "&lt;".unicodeScalars)
            case ">": result.append(contentsOf: "&gt;".unicodeScalars)
            case "\"": result.append(contentsOf: "&quot;".unicodeScalars)
            case "'": result.append(contentsOf: "&#39;".unicodeScalars)
            default: result.append(scalar)
            }
        }
        return String(result)
    }
}
