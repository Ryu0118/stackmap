/// The page's inline stylesheet, with light and dark palettes.
enum PageStyle {
    static let css = """
    :root {
      color-scheme: light dark;
      --bg: #f6f6f3; --surface: #ffffff; --ink: #16181d; --muted: #555b66; --line: #dcddd8;
      --band-provider: #eef2f7; --band-provider-line: #c9d3e0; --band-scope-line: #9aa6b6;
      --client: #16181d; --client-ink: #ffffff; --wire: #7a808a; --shared: #c2710c; --accent: #1d4ed8;
      --c0-ink: #1d4ed8; --c0-bg: #e8eefd; --c1-ink: #0f766e; --c1-bg: #e1f3f0;
      --c2-ink: #8a4b0b; --c2-bg: #fdf0df; --c3-ink: #6d28d9; --c3-bg: #f0eafd;
      --c4-ink: #9d174d; --c4-bg: #fce8f1; --c5-ink: #166534; --c5-bg: #e6f4ea;
      --c6-ink: #374151; --c6-bg: #eef0f2; --c7-ink: #854d0e; --c7-bg: #fdf6d8;
    }
    @media (prefers-color-scheme: dark) {
      :root {
        --bg: #111317; --surface: #1b1e24; --ink: #eceef2; --muted: #a3a9b4; --line: #2f343d;
        --band-provider: #181c23; --band-provider-line: #333b48; --band-scope-line: #4b5566;
        --client: #eceef2; --client-ink: #111317; --wire: #8b919c; --shared: #f0a24a; --accent: #8fb4ff;
        --c0-ink: #a9c1ff; --c0-bg: #1d2a4a; --c1-ink: #7fd6c8; --c1-bg: #13332f;
        --c2-ink: #f5c08a; --c2-bg: #3a2814; --c3-ink: #c9b2ff; --c3-bg: #2c2148;
        --c4-ink: #f5a9c8; --c4-bg: #40192b; --c5-ink: #95dba8; --c5-bg: #16331f;
        --c6-ink: #c7ccd4; --c6-bg: #2a2f37; --c7-ink: #f1d488; --c7-bg: #3a3012;
      }
    }
    * { box-sizing: border-box; }
    body { margin: 0; background: var(--bg); color: var(--ink);
      font: 15px/1.6 -apple-system, BlinkMacSystemFont, "Segoe UI", "Hiragino Sans", "Noto Sans JP", sans-serif; }
    header, main { margin: 0 auto; padding: 0 clamp(16px, 4vw, 48px); }
    header { padding-top: 40px; display: flex; flex-direction: column; gap: 12px; }
    h1 { margin: 0; font-size: 32px; line-height: 1.2; }
    h2 { margin: 40px 0 16px; font-size: 20px; }
    h3 { margin: 24px 0 12px; font-size: 16px; }
    .subtitle, .muted { color: var(--muted); }
    .subtitle { margin: 0; }
    .tabs { display: flex; flex-wrap: wrap; gap: 6px; align-self: flex-start; padding: 6px;
      background: var(--surface); border: 1px solid var(--line); border-radius: 12px; }
    .tabs button { min-height: 40px; padding: 0 16px; border: 0; border-radius: 8px; background: transparent;
      color: var(--ink); font: inherit; font-weight: 600; cursor: pointer; }
    .tabs button[aria-selected="true"] { background: var(--ink); color: var(--bg); }
    main { padding-bottom: 64px; }
    .diagram-scroll { overflow-x: auto; border: 1px solid var(--line); border-radius: 16px; background: var(--bg); }
    .diagram { position: relative; }
    .wires { position: absolute; inset: 0; overflow: visible; }
    .band { stroke-width: 1; }
    .band-provider { fill: var(--band-provider); stroke: var(--band-provider-line); }
    .band-scope { fill: none; stroke: var(--band-scope-line); stroke-dasharray: 6 5; stroke-width: 1.5; }
    .band-label { position: absolute; font-size: 13px; line-height: 16px; font-weight: 700; color: var(--muted); white-space: nowrap; }
    .band-label-provider { color: var(--ink); }
    .edge { fill: none; stroke: var(--wire); stroke-width: 2; stroke-linejoin: round; }
    .edge-sharedStore { stroke: var(--shared); }
    .edge { transition: opacity .15s; }
    .diagram:has(.card:hover) .edge { opacity: .18; }
    .edge.k0 { stroke: var(--c0-ink); } .edge.k1 { stroke: var(--c1-ink); } .edge.k2 { stroke: var(--c2-ink); }
    .edge.k3 { stroke: var(--c3-ink); } .edge.k4 { stroke: var(--c4-ink); } .edge.k5 { stroke: var(--c5-ink); }
    .edge.k6 { stroke: var(--c6-ink); } .edge.k7 { stroke: var(--c7-ink); }
    .arrowhead-k0 { fill: var(--c0-ink); } .arrowhead-k1 { fill: var(--c1-ink); } .arrowhead-k2 { fill: var(--c2-ink); }
    .arrowhead-k3 { fill: var(--c3-ink); } .arrowhead-k4 { fill: var(--c4-ink); } .arrowhead-k5 { fill: var(--c5-ink); }
    .arrowhead-k6 { fill: var(--c6-ink); } .arrowhead-k7 { fill: var(--c7-ink); }
    .arrowhead-plain { fill: var(--wire); }
    .arrowhead-shared { fill: var(--shared); }
    .card { position: absolute; display: flex; flex-direction: column; justify-content: center; gap: 0; overflow: hidden;
      padding: 10px 14px; border-radius: 10px; background: var(--surface); border: 1px solid var(--line); font-size: 13px; line-height: 24px; }
    .card .text { display: flex; flex-direction: column; min-width: 0; line-height: 20px; }
    .card strong { font-size: 14px; word-break: break-all; overflow-wrap: anywhere; }
    .card .text span { color: var(--muted); word-break: break-all; overflow-wrap: anywhere; }
    .card-client { background: var(--client); border-color: var(--client); }
    .card-client strong, .card-client .text span { color: var(--client-ink); }
    .card-service { border-color: var(--band-provider-line); }
    .card-serviceStores, .card-sharedStore { justify-content: flex-start; }
    .card-sharedStore { border: 1.5px solid var(--shared); }
    .card-title { line-height: 28px; margin-bottom: 4px; }
    .line { display: flex; align-items: flex-start; gap: 6px; min-width: 0; min-height: 24px; }
    .line .text { display: block; min-width: 0; padding: 2px 0; line-height: 20px; word-break: break-all; overflow-wrap: anywhere; }
    .status-planned .text { color: var(--muted); }
    .status-planned .chip, .status-migrating .chip { background: transparent; outline: 1.5px dashed currentColor; outline-offset: -1.5px; }
    .status-migrating .text { color: var(--accent); }
    .chip { display: inline-block; flex: none; padding: 0 6px; border-radius: 4px; font-size: 11px; font-weight: 700; line-height: 18px; margin-top: 3px; white-space: nowrap; }
    \((0 ..< 8).map { ".c\($0) { color: var(--c\($0)-ink); background: var(--c\($0)-bg); }" }.joined(separator: "\n"))
    .legend { display: flex; flex-wrap: wrap; gap: 20px; margin: 12px 0 0; padding: 0; list-style: none; font-size: 13px; color: var(--muted); }
    .legend li { display: inline-flex; align-items: center; gap: 8px; }
    .swatch { display: inline-block; width: 24px; height: 0; border-top: 2px solid var(--wire); }
    .swatch-shared { border-top-color: var(--shared); }
    .swatch-planned { border-top: 2px dashed var(--accent); }
    .summary, .migrations { display: flex; flex-wrap: wrap; gap: 10px; margin: 0; padding: 0; list-style: none; }
    .summary li { display: flex; align-items: center; gap: 8px; padding: 10px 14px; border: 1px solid var(--line);
      border-radius: 12px; background: var(--surface); }
    .summary .count { font-size: 20px; font-weight: 700; }
    .migrations { flex-direction: column; }
    .migrations li { display: flex; flex-wrap: wrap; align-items: center; gap: 8px; padding: 12px 16px;
      border: 1.5px dashed var(--accent); border-radius: 12px; background: var(--surface); }
    .table-scroll { margin-top: 24px; overflow-x: auto; border: 1px solid var(--line); border-radius: 12px; background: var(--surface); }
    table { width: 100%; min-width: 760px; border-collapse: collapse; font-size: 13px; }
    th { text-align: left; color: var(--muted); font-weight: 600; }
    th, td { padding: 10px 16px; border-bottom: 1px solid var(--line); vertical-align: top; }
    tbody tr:last-child td { border-bottom: 0; }
    code { font: 12px/1.6 ui-monospace, SFMono-Regular, Menlo, monospace; color: var(--muted); }
    .status { font-weight: 600; }
    .status-live { color: var(--muted); }
    .status.status-planned { color: var(--muted); font-style: italic; }
    .status.status-migrating { color: var(--accent); }
    .empty { color: var(--muted); }
    """
}
