import Foundation

/// A unique directory removed on `cleanUp`, so tests never share files.
struct TemporaryDirectory {
    let url: URL

    init() throws {
        url = FileManager.default.temporaryDirectory.appending(path: "stackmap-tests-\(UUID().uuidString)", directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }

    func path(_ name: String) -> String {
        url.appending(path: name).path(percentEncoded: false)
    }

    func write(_ contents: String, as name: String) throws -> String {
        let target = path(name)
        try contents.write(toFile: target, atomically: true, encoding: .utf8)
        return target
    }

    func exists(_ name: String) -> Bool {
        FileManager.default.fileExists(atPath: path(name))
    }

    func read(_ name: String) throws -> String {
        try String(contentsOfFile: path(name), encoding: .utf8)
    }

    func cleanUp() {
        try? FileManager.default.removeItem(at: url)
    }
}
