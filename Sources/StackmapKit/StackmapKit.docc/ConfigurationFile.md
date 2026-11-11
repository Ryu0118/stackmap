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
- Ids must be unique within each list.
- Every reference (`provider`, `store`, `owner`, `calls`, `scopes`,
  `migration.to`) must name an id that exists in the matching list.
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

A client's calls to services that are not kept are dropped. A migration's
target store is shown by name only; it is not kept as a store on its own.

## The diagram

The diagram is laid out in rows, top to bottom:

1. Clients. Each one sits above the services it calls, with a connector into
   each service.
2. Services, inside a band for their provider. Providers appear in the order
   they are declared. Within a provider, services are ordered by their first
   scope (the first entry of their `scopes`, ranked in the order scopes are
   declared, unscoped services last) and then by declaration order. When the
   whole system is rendered and the file declares scopes, consecutive
   services in the same provider with the same first scope sit in a scope
   band. Unscoped services sit in no scope band.
3. Under each service, one card listing the data it owns in stores on its own
   provider, each line tagged with the store label.
4. At the bottom, a band per provider for stores the services reach on
   another provider. Each such store is one card, listing its data, with a
   connector from every service that owns data in it.

`planned` data is drawn dashed. `migrating` data is drawn dashed in the accent
color and names the target store.
