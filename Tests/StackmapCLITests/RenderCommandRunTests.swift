import ArgumentParser
import Foundation
import StackmapCLI
import Testing

@Suite("Running the render command")
struct RenderCommandRunTests {
    private func command(_ arguments: [String]) throws -> RenderCommand {
        try #require(try RenderCommand.parse(arguments) as? RenderCommand)
    }

    @Test("it writes the whole system to the output file")
    func writesPage() async throws {
        let directory = try TemporaryDirectory()
        defer { directory.cleanUp() }
        let config = try directory.write(CLIFixtures.valid, as: "stackmap.yml")

        try await command([config, "-o", directory.path("out.html")]).run()
        let html = try directory.read("out.html")

        // Catches nothing written, or a page missing the whole-system and per-scope sections.
        #expect(html.attributeValues(of: "data-scope", onTag: "section").sorted() == ["all", "ops", "shop"])
    }

    @Test("--scope renders only that scope")
    func scopedPage() async throws {
        let directory = try TemporaryDirectory()
        defer { directory.cleanUp() }
        let config = try directory.write(CLIFixtures.valid, as: "stackmap.yml")

        try await command([config, "-o", directory.path("out.html"), "--scope", "shop"]).run()
        let html = try directory.read("out.html")

        // Catches --scope being ignored, or the scope applied after the whole page was written.
        #expect(html.attributeValues(of: "data-scope", onTag: "section") == ["shop"])
        #expect(html.occurrences(of: "data-node=\"service:api\"") == 1)
        #expect(html.occurrences(of: "data-node=\"service:bot\"") == 0)
    }

    @Test("an invalid file fails with status 1 and writes nothing")
    func invalidFile() async throws {
        let directory = try TemporaryDirectory()
        defer { directory.cleanUp() }
        let config = try directory.write(CLIFixtures.invalid, as: "bad.yml")

        // Catches a failure reported with another status, or an empty output file left behind.
        await #expect(throws: ExitCode.failure) {
            try await command([config, "-o", directory.path("out.html")]).run()
        }
        #expect(!directory.exists("out.html"))
    }

    @Test("an unknown scope fails with status 1 and writes nothing")
    func unknownScope() async throws {
        let directory = try TemporaryDirectory()
        defer { directory.cleanUp() }
        let config = try directory.write(CLIFixtures.valid, as: "stackmap.yml")

        // Catches a page being written for a scope that does not exist.
        await #expect(throws: ExitCode.failure) {
            try await command([config, "-o", directory.path("out.html"), "--scope", "nope"]).run()
        }
        #expect(!directory.exists("out.html"))
    }

    @Test("a failing run leaves an existing output file untouched")
    func failureKeepsExistingOutput() async throws {
        let directory = try TemporaryDirectory()
        defer { directory.cleanUp() }
        let config = try directory.write(CLIFixtures.invalid, as: "bad.yml")
        _ = try directory.write("previous page", as: "out.html")

        _ = try? await command([config, "-o", directory.path("out.html")]).run()

        // Catches the output file being truncated before the input is validated.
        #expect(try directory.read("out.html") == "previous page")
    }

    @Test("a config file that does not exist is an error and writes nothing")
    func missingConfig() async throws {
        let directory = try TemporaryDirectory()
        defer { directory.cleanUp() }

        // Catches a missing file producing an empty page.
        await #expect(throws: (any Error).self) {
            try await command([directory.path("absent.yml"), "-o", directory.path("out.html")]).run()
        }
        #expect(!directory.exists("out.html"))
    }

    @Test("running twice produces identical files")
    func repeatedRunsMatch() async throws {
        let directory = try TemporaryDirectory()
        defer { directory.cleanUp() }
        let config = try directory.write(CLIFixtures.valid, as: "stackmap.yml")

        try await command([config, "-o", directory.path("one.html")]).run()
        try await command([config, "-o", directory.path("two.html")]).run()

        // Catches output depending on the output path or the time of the run.
        #expect(try directory.read("one.html") == directory.read("two.html"))
    }
}
