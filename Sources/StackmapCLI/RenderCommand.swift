import ArgumentParser
import Foundation
import StackmapKit

/// `stackmap render`: reads a stack map file and writes the HTML page.
///
/// Writes to `--output` when given, otherwise to standard output. On a load
/// or scope error it prints one `error: ` line per problem to standard error
/// and exits with status 1 without writing any output file.
package struct RenderCommand: AsyncParsableCommand {
    /// The subcommand name and help text.
    package static let configuration = CommandConfiguration(
        commandName: "render",
        abstract: "Render a stack map file as an HTML page."
    )

    /// The stack map file to read.
    @Argument(help: "The stack map file to read.")
    package var config = "stackmap.yml"

    /// Where to write the page; standard output when omitted.
    @Option(name: [.short, .long], help: "Where to write the HTML page. Defaults to standard output.")
    package var output: String?

    /// The scope to render on its own; the whole system when omitted.
    @Option(help: "Render only this scope id.")
    package var scope: String?

    /// Creates the command; ArgumentParser fills in options after parsing.
    package init() {}

    /// Runs the command.
    package func run() async throws {
        let html = try renderPage()

        if let output {
            do {
                try html.write(toFile: output, atomically: true, encoding: .utf8)
            } catch {
                throw fail(["cannot write \(output): \(error.localizedDescription)"])
            }
        } else {
            FileHandle.standardOutput.write(Data(html.utf8))
        }
    }

    private func renderPage() throws -> String {
        let text: String
        do {
            text = try String(contentsOfFile: config, encoding: .utf8)
        } catch {
            throw fail(["cannot read \(config): \(error.localizedDescription)"])
        }

        let document: StackmapDocument
        do {
            document = try DocumentLoader().load(yaml: text)
        } catch {
            throw fail(error.issues.map { "\(config): \($0)" })
        }

        do {
            return try HTMLRenderer().render(document, selection: scope.map(ScopeSelection.scope) ?? .all)
        } catch {
            switch error {
            case let .unknownScope(id): throw fail(["\(config): no scope with id '\(id)'"])
            }
        }
    }

    private func fail(_ messages: [String]) -> ExitCode {
        let text = messages.map { "error: \($0)\n" }.joined()
        FileHandle.standardError.write(Data(text.utf8))
        return ExitCode.failure
    }
}
