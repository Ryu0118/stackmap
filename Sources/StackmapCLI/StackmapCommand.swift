import ArgumentParser

/// The `stackmap` root command.
package struct StackmapCommand: AsyncParsableCommand {
    /// The command name, help text, and version shown by `--version`.
    package static let configuration = CommandConfiguration(
        commandName: "stackmap",
        abstract: "Render a tech stack map from a YAML file.",
        version: StackmapVersion.current,
        subcommands: [RenderCommand.self]
    )

    /// Creates the command; ArgumentParser fills in options after parsing.
    package init() {}
}
