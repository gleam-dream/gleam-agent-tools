---
name: gleam-sql
description: Build and debug PostgreSQL data access with Squirrel, Pog, and Cigogne. Use for SQL generation, query decoding, transactions, migrations, nullability, connection ownership, and generated-code drift.
---

# Gleam SQL

Keep authored SQL, runtime connections, and migration history under explicit ownership.

## Abstraction decision tree

```text
Does PostgreSQL fit the application's persistence contract?
├─ No → Keep its suitable database and client
└─ Yes → Choose the needed capability
   ├─ Execute queries and own a pool → Pog
   ├─ Generate typed access from authored SQL → Squirrel + Pog
   ├─ Apply ordered SQL schema changes → Cigogne
   └─ Commit related statements together → One Pog transaction connection
```

## Generate against the intended schema

- Check package versions and targets. Research covered Squirrel 4.7.0, Pog 4.1.0, and Cigogne 5.0.6. Squirrel supports PostgreSQL >=16; Pog and Cigogne execute on Erlang.
- Recommend this SQL-first lane when its contract fits. Respect existing persistence choices; a JavaScript app can use migration tooling without gaining a JavaScript database runtime.
- Add Squirrel as a development dependency. Author one statement per `.sql` file in `src/**/sql/`; run `gleam run -m squirrel` to generate the neighboring `sql.gleam` module.
- Apply the intended migrations before generating or checking. The generator interrogates a live database; use the same schema baseline in CI and deployment planning.
- Edit SQL, then regenerate. Run `gleam run -m squirrel check` to detect stale generated access. Keep database credentials in the environment.
- Bind values as parameters. Select trusted query shapes for identifiers and ordering; bound values cannot stand in for arbitrary SQL syntax.
- Inspect generated representations. In this version, PostgreSQL `numeric` decodes as `Float` and JSON/JSONB as `String`; exact money and domain JSON require a deliberate representation and validation.
- Handle nullable inputs explicitly. PostgreSQL metadata does not expose parameter nullability to Squirrel. Prefer separate set/clear queries; reserve a sentinel only when the domain excludes that value.

## Runtime and transaction ownership

- Supervise the pool and budget connection capacity. Verify readiness through an actual query; successful pool startup alone need not establish a usable connection.
- Pass the callback's transaction connection to every participating query. Pog commits callback `Ok` and rolls back callback `Error` or panic; propagate failures instead of replacing them with success.
- Treat decoding failure after a write as possible completed execution. Propagate it through the transaction if rollback is required; an `Error` outside that transaction does not establish rollback.
- Keep external effects and separately committed package stores outside claims of one atomic transaction. The application owns authorization and business invariants.

## Migrate deliberately

- Use Cigogne's timestamped SQL files with up/down/end sections. Create new migrations for changes to applied history; stored hashes detect edits.
- Choose one migration owner per schema installation. `include-lib` creates application migration files; importing a library does not install its schema.
- Use `priv/cigogne.toml` or documented flags for Cigogne configuration. Do not invent a `[tools.cigogne]` interface.
- Inspect transaction options. `disable_transaction` supports a single-query migration and breaks any claim that every selected migration commits atomically together.

## Red flags

- Hand edits to generated Gleam or generation against an unrelated schema.
- User-controlled identifiers interpolated into SQL.
- Empty strings silently converted to null in a domain that permits both.
- `Float` assumed to preserve exact database decimal values.
- A query using the pool instead of its transaction connection.
- Applied migrations rewritten or hash checks bypassed in production.
- Assuming every error proves that no write occurred.

## Sources

[Squirrel](https://squirrel.hexdocs.pm/), [Pog transactions and execution](https://pog.hexdocs.pm/pog.html), [Cigogne migrations](https://cigogne.hexdocs.pm/).
