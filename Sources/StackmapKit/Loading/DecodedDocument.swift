/// Document entries that decoded, before references are checked.
struct DecodedDocument {
    let title: String
    let scopes: [IndexedEntry<Scope>]
    let providers: [IndexedEntry<Provider>]
    let stores: [IndexedEntry<Store>]
    let clients: [IndexedEntry<Client>]
    let services: [IndexedEntry<Service>]
    let data: [IndexedEntry<DataItem>]

    var document: StackmapDocument {
        StackmapDocument(
            title: title,
            scopes: scopes.map(\.value),
            providers: providers.map(\.value),
            stores: stores.map(\.value),
            clients: clients.map(\.value),
            services: services.map(\.value),
            data: data.map(\.value)
        )
    }
}
