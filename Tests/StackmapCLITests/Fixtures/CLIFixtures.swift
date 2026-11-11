enum CLIFixtures {
    static let valid = """
    version: 1
    scopes:
      - id: shop
        label: Shop
      - id: ops
        label: Ops
    providers:
      - id: edge
        label: Edge
    services:
      - id: api
        label: api
        provider: edge
        scopes: [shop]
      - id: bot
        label: bot
        provider: edge
        scopes: [ops]
    """

    static let invalid = "version: 2\n"
}
