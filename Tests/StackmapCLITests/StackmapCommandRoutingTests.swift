import ArgumentParser
import StackmapCLI
import Testing

@Suite("Routing from the root command")
struct StackmapCommandRoutingTests {
    @Test("render with its arguments reaches the render command")
    func routesRender() throws {
        let parsed = try StackmapCommand.parseAsRoot(["render", "a.yml", "-o", "b.html", "--scope", "s"])
        let command = try #require(parsed as? RenderCommand)

        // Catches a root command without the render subcommand, which rejects -o as an unknown option.
        #expect(command.config == "a.yml")
        #expect(command.output == "b.html")
        #expect(command.scope == "s")
    }

    @Test("render without arguments keeps its defaults")
    func routesRenderDefaults() throws {
        let parsed = try StackmapCommand.parseAsRoot(["render"])
        let command = try #require(parsed as? RenderCommand)

        // Catches defaults being lost when parsed through the root.
        #expect(command.config == "stackmap.yml")
        #expect(command.output == nil)
    }

    @Test("an unknown subcommand is rejected")
    func unknownSubcommand() {
        // Catches unknown words being silently accepted by the root command.
        #expect(throws: (any Error).self) {
            try StackmapCommand.parseAsRoot(["frobnicate", "a.yml"])
        }
    }
}
