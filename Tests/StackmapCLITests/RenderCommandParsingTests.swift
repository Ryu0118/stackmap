import ArgumentParser
import StackmapCLI
import Testing

@Suite("Parsing render command arguments")
struct RenderCommandParsingTests {
    @Test("with no arguments the config defaults to stackmap.yml and output goes to stdout for the whole system")
    func defaults() throws {
        let command = try #require(try RenderCommand.parse([]) as? RenderCommand)

        // Catches a changed default config path, or a default output file or scope.
        #expect(command.config == "stackmap.yml")
        #expect(command.output == nil)
        #expect(command.scope == nil)
    }

    @Test("the config path, output, and scope are read from arguments")
    func explicitArguments() throws {
        let command = try #require(try RenderCommand.parse(["site.yml", "-o", "out.html", "--scope", "shop"]) as? RenderCommand)

        // Catches options bound to the wrong property.
        #expect(command.config == "site.yml")
        #expect(command.output == "out.html")
        #expect(command.scope == "shop")
    }

    @Test("--output is the long form of -o")
    func longOutputOption() throws {
        let command = try #require(try RenderCommand.parse(["--output", "out.html"]) as? RenderCommand)

        // Catches the short option being the only spelling.
        #expect(command.output == "out.html")
        #expect(command.config == "stackmap.yml")
    }

    @Test("an unknown option is rejected")
    func unknownOption() {
        // Catches typos being silently ignored.
        #expect(throws: (any Error).self) {
            try RenderCommand.parse(["--colour", "red"])
        }
    }
}
