/// The page shell. Kept in source because release archives ship only the binary.
enum PageTemplate {
    /// Assembles the page; every argument must already be escaped HTML.
    static func page(title: String, subtitle: String, tabs: String, sections: String, script: String) -> String {
        let scriptTag = script.isEmpty ? "" : "\n<script>\(script)</script>"
        return """
        <!doctype html>
        <html lang="en">
        <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>\(title)</title>
        <style>\(PageStyle.css)</style>
        </head>
        <body>
        <header>
        <h1>\(title)</h1>\(subtitle)
        \(tabs)
        </header>
        <main>
        \(sections)
        </main>\(scriptTag)
        </body>
        </html>

        """
    }

    /// Switches sections from the tab buttons and keeps the choice in the URL hash.
    static let tabScript = """
    (() => {
      const tabs = [...document.querySelectorAll("[data-tab]")];
      const sections = [...document.querySelectorAll("section[data-scope]")];
      const show = (id) => {
        sections.forEach((section) => { section.hidden = section.dataset.scope !== id; });
        tabs.forEach((tab) => tab.setAttribute("aria-selected", String(tab.dataset.tab === id)));
      };
      tabs.forEach((tab) => tab.addEventListener("click", () => {
        show(tab.dataset.tab);
        history.replaceState(null, "", "#" + tab.dataset.tab);
      }));
      const wanted = decodeURIComponent(location.hash.slice(1));
      show(sections.some((section) => section.dataset.scope === wanted) ? wanted : "all");
    })();
    """
}
