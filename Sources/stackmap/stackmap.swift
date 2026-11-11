import StackmapCLI

@main
enum Stackmap {
    static func main() async {
        await StackmapCommand.main()
    }
}
