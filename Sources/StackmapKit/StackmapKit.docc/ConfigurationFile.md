# Configuration File

The YAML file that describes a stack map, and how stackmap reads it.

## Overview

A stack map file lists the clients, services, and stores of a system, and
every piece of data with the store it lives in and the service that owns it.
`stackmap render` reads the file (by default `stackmap.yml` in the current
directory) and writes one HTML page.

```yaml
version: 1
title: Example Platform

scopes:
  - id: shop
    label: Shop
  - id: ops
    label: Operations

providers:
  - id: edge
    label: Cloudflare
  - id: cloud
    label: Firebase

stores:
  - id: sql
    label: D1
    provider: edge
  - id: cache
    label: KV
    provider: edge
  - id: docs
    label: Firestore
    provider: cloud

clients:
  - id: mobile
    label: Mobile app
    scopes: [shop]
    calls: [api]

services:
  - id: api
    label: api
    description: Public API
    provider: edge
    scopes: [shop]
  - id: bot
    label: bot
    description: Chat bot
    provider: edge
    scopes: [ops]

data:
  - id: orders
    label: Orders
    store: docs
    owner: api
    identifiers: [orders]
    status: migrating
    migration:
      to: sql
      note: "#42"
  - id: sessions
    label: Sessions
    store: cache
    owner: api
  - id: jobs
    label: Scheduled jobs
    store: sql
    owner: bot
    status: planned
```

## Keys

Every list is optional. `version` is required and must be `1`.

| Key | Type | Meaning |
| --- | --- | --- |
| `version` | integer | Schema version. Only `1` is supported. |
| `title` | string | Page title. Defaults to `Stack Map`. |
| `scopes[].id`, `.label` | string | A part of the system that can be rendered on its own. |
| `providers[].id`, `.label` | string | A platform that hosts services or stores, drawn as a band. |
| `stores[].id`, `.label`, `.provider` | string | A storage product on a provider. |
| `clients[].id`, `.label` | string | Something outside the providers that calls services. |
| `clients[].description` | string | Optional second line. |
| `clients[].scopes` | [string] | Scope ids. |
| `clients[].calls` | [string] | Service ids the client calls. |
| `services[].id`, `.label`, `.provider` | string | A deployable service on a provider. |
| `services[].description` | string | Optional second line. |
| `services[].scopes` | [string] | Scope ids. |
| `services[].calls` | [string] | Ids of other services this service calls. |
| `data[].id`, `.label`, `.store`, `.owner` | string | A piece of data, the store it lives in, and the owning service id. |
| `data[].scopes` | [string] | Scope ids. Omitted means the owner's scopes. |
| `data[].identifiers` | [string] | Table, collection, binding, or key names. |
| `data[].status` | string | `live` (default), `planned`, or `migrating`. |
| `data[].migration.to` | string | Store id the data is moving to. Required when `status` is `migrating`, and not allowed otherwise. |
| `data[].migration.note` | string | Optional note, such as an issue number. |

Every key marked string is required within its entry except
`description`, `title`, and `migration.note`.

## Validation

stackmap reads the whole file and reports every problem at once instead of
stopping at the first. Each problem names the path of the offending key,
such as `services[1].provider` or `data[0].migration.to`.

- A key the schema does not define is an error, so a typo never silently
  switches something off.
- An empty file, text that is not YAML, and a root that is not a mapping are
  reported as malformed YAML.
- A string value is read as its literal text, so `id: 123` and `id: yes` are
  the ids `123` and `yes`. A null value (`id:` or `id: null`) counts as
  missing. A list or mapping where a string belongs, or a
  list entry that is not a mapping, is a type error at that path
  (`services[0]`).
- An id must start with an ASCII letter or digit and contain only ASCII
  letters, digits, `-`, and `_`. Ids are case-sensitive.
- The scope id `all` is reserved for the whole-system view and is reported
  as an invalid id. Other lists may use `all`, and `All` is a different id.
- Ids must be unique within each list.
- Every reference (`provider`, `store`, `owner`, `calls`, `scopes`,
  `migration.to`) must name an id that exists in the matching list. Both
  `clients[].calls` and `services[].calls` name service ids.
- A service may not call itself; `services[n].calls[m]` naming service `n`
  is reported as a self call. A repeated id in `calls` is allowed.
- `migration` is required when `status` is `migrating`, is not allowed for
  any other status, and `migration.to` must differ from `store`.

## Scopes

An entry with no scopes belongs to every scope. Data without `scopes` uses
its owner's scopes.

Rendering one scope keeps:

- clients and services that belong to it,
- data that belongs to it and whose owner is kept,
- stores that hold kept data, and providers that host kept services or
  stores.

A client's or service's calls to services that are not kept are dropped. A migration's
target store is shown by name only; it is not kept as a store on its own.

## The diagram

The diagram places cards on one grid of columns shared by every row, and no
row holds more than four cards. Rows run top to bottom:

1. Clients, in declaration order, four to a row.
2. One band per provider, in the order providers are declared, for each
   provider that hosts a kept service or a shared store (below). Inside it:
   - Service rows. Services are grouped by their first scope (the first
     entry of their `scopes`, ranked in the order scopes are declared,
     unscoped services last), each group in declaration order. Each group
     starts a new row and wraps after four services. When the whole system
     is rendered and the file declares scopes, each row segment of a group
     with a first scope sits in a scope band labeled with that scope; a group
     that wraps gets one band per row. Unscoped services sit in no scope
     band. When one scope is rendered or no scopes are declared, services
     are not grouped and simply wrap after four.
   - Under each service, one card listing the data it owns in stores on its
     own provider, each line tagged with the store label.
   - Then the provider's shared stores: stores on this provider holding data
     owned by a service on another provider, in declaration order, four to a
     row. Each is one card listing that data.

A card's text is never cut off. A data line that is too long for its card
wraps, and the card grows to fit. The width of a line is estimated
conservatively (an East Asian wide or fullwidth character counts as one
em, any other character as 0.65 em), so a card may be taller than its text
needs but never shorter.

### Connectors

- A client calls a service (`clients[].calls`), a service calls a service
  (`services[].calls`), and a service owns data in a shared store. Each of
  these connectors leaves the bottom of its source card and ends with an
  arrowhead one pixel above the top of its target card. A repeated id in
  `calls` is drawn once.
- A service is joined to the card listing its own data by a short straight
  connector.
- Connectors run only through the space between rows and the vertical
  channels between columns (and left of the first column), never through a
  card. Every segment is horizontal or vertical. A target may sit in a row
  above its source, in the same row, or below it.
- Different connectors never run along the same line. The one exception is
  a client's own connectors: they leave from one point and share their
  first horizontal run, like a bus. A service's outgoing connectors leave
  from separate points on the left part of its bottom edge, and the
  connectors into a card arrive at separate points on its top edge.

In the HTML page every connector carries `data-source` and `data-target`
attributes naming its cards as `kind:id`, such as `client:mobile` or
`service:api`. Connectors from each client share one color. Pointing at a
card highlights the connectors that start or end at it.

`planned` data is drawn dashed. `migrating` data is drawn dashed in the accent
color and names the target store.
