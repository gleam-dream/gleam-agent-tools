# Transport, identity, and email research

Refreshed 2026-10-20. This pass produced `http-gun`, `warden`, and `correio` consumer skills. Each is a single self-contained file with a decision table, ordinary application path, ownership rules, and red flags. The earlier boundaries report supplied leads, not current evidence.

## Source identity

The GitHub connector's repository `branches` endpoints confirmed these exact `main` revisions during this pass. All three local worktrees matched and were clean before research. Browser indexing of Warden returned an older `master` README with obsolete local-path installation instructions; the connector and exact local revision take precedence.

| Package | Exact selected revision | Target and status |
| --- | --- | --- |
| HTTP Gun | [`db1cc9789af6cc6af2175d502dfcabb0451f4e2e`](https://github.com/gleam-dream/http_gun/tree/db1cc9789af6cc6af2175d502dfcabb0451f4e2e) | Erlang, Gleam >=1.18, unreleased 0.1.0 |
| Warden | [`33e9056e66cee33da4822a1c1afb9aed642eb89e`](https://github.com/gleam-dream/warden/tree/33e9056e66cee33da4822a1c1afb9aed642eb89e) | Erlang, Gleam >=1.18, unreleased/pre-production 0.1.0 |
| Correio | [`a44986421f3b71bb55e9a4a8813fc89c83aaa79c`](https://github.com/gleam-dream/correio/tree/a44986421f3b71bb55e9a4a8813fc89c83aaa79c) | Erlang, Gleam >=1.18, unpublished/pre-release 0.1.0 |

Reviewed each package's `AGENTS.md`, README, `gleam.toml`, resolved `manifest.toml`, relevant native design sections and pending ledgers, and coverage map. Selected public APIs, consumer implementations, and test bodies below substantiate the skill rules. Native Typst sources were read directly; no rendered-document inspection is claimed.

## HTTP Gun claims

| Intended rule | Primary evidence at selected revision | Limit |
| --- | --- | --- |
| Reuse a supervised shared client; views share a pool | [README](https://github.com/gleam-dream/http_gun/blob/db1cc9789af6cc6af2175d502dfcabb0451f4e2e/README.md), `src/http_gun.gleam`, design client lifecycle | A linked manual start is suitable only when its caller owns that lifetime |
| `send` returns status/body data; non-2xx is transport success | README and exported `send` API | No application/business-success interpretation |
| Prefer scoped streaming; opener reads, copies share cursor, explicit bodies close after EOF | [`body.gleam`](https://github.com/gleam-dream/http_gun/blob/db1cc9789af6cc6af2175d502dfcabb0451f4e2e/src/http_gun/body.gleam), [`usage_views`](https://github.com/gleam-dream/http_gun/blob/db1cc9789af6cc6af2175d502dfcabb0451f4e2e/examples/ordinary/src/usage_views.gleam), design body demand | An HTTP timeout cannot interrupt arbitrary application computation after completion |
| Retry helper considers kind, evidence, and application idempotency | [`error.is_retryable`](https://github.com/gleam-dream/http_gun/blob/db1cc9789af6cc6af2175d502dfcabb0451f4e2e/src/http_gun/error.gleam#L246) | Only Unavailable/Network/TimedOut qualify; NotSent alone is insufficient for every failure kind |
| Recording needs explicit secret policy and finish acknowledgement | [`redaction.gleam`](https://github.com/gleam-dream/http_gun/blob/db1cc9789af6cc6af2175d502dfcabb0451f4e2e/src/http_gun/redaction.gleam), README, design recording | Defaults preserve query values and bodies; no new crash-durability or guaranteed cleanup claim |
| Public API excludes uploads/redirect following/decompression/proxies/SSE parsing | README and design pending ledger | Gun's broader API is not HTTP Gun's wrapper contract |

Freshly retrieved [RFC 9110 §9.2.2](https://www.rfc-editor.org/rfc/rfc9110.html#section-9.2.2) provides the external HTTP idempotency context. The guide's concrete classifications come from HTTP Gun's implementation rather than inferring remote execution from the RFC.

## Warden claims

| Intended rule | Primary evidence at selected revision | Limit |
| --- | --- | --- |
| Choose relying-party, service, or resource role; reuse one client | [README](https://github.com/gleam-dream/warden/blob/33e9056e66cee33da4822a1c1afb9aed642eb89e/README.md), design role/lifecycle sections | Supervised background discovery can return ProviderNotReady |
| Use public login helpers and map issuer/subject to application identity | README, [`usage/responsibilities`](https://github.com/gleam-dream/warden/blob/33e9056e66cee33da4822a1c1afb9aed642eb89e/consumer/src/warden_reference/usage/responsibilities.gleam) | Warden's browser binding is not the application's authenticated session or permission policy |
| Handle closed Action and retain carried recovery | Same consumer; `warden.gleam` exports | A projected Action alone loses the recovery value |
| Recovery republishes custody without provider replay | [`lost_publication_acknowledgement_recovers_without_provider_test`](https://github.com/gleam-dream/warden/blob/33e9056e66cee33da4822a1c1afb9aed642eb89e/test/warden_session_test.gleam#L281) explicitly compares token request counts | Test source inspected, not freshly executed |
| Durable sessions need both stores, stable sealing key, atomic conditional writes | README, [`store.gleam`](https://github.com/gleam-dream/warden/blob/33e9056e66cee33da4822a1c1afb9aed642eb89e/src/warden/store.gleam), PostgreSQL adapter README | Generic checker does not establish real lock-wait timing; timed-out commit is not rollback |
| JWT verification and introspection offer different evidence | `src/warden/resource.gleam`, README resource example | No claim that local signature/expiry verification immediately detects provider revocation |
| Stop returning does not confirm every external effect finished | README and design lifecycle/application responsibilities | Captured pool lifetime remains application-owned; stronger shutdown completion is pending |

Freshly retrieved [OIDC Core §5.7](https://openid.net/specs/openid-connect-core-1_0.html#ClaimStability) supports the issuer/subject identity key. Warden's independent review, release SBOM, selected conformance, provider interoperability, and dependency review obligations remain open release conditions. The guide makes no certification, whole-cryptography audit, arbitrary-provider compatibility, or unsupported-flow claim.

## Correio claims

| Intended rule | Primary evidence at selected revision | Limit |
| --- | --- | --- |
| Inject `delivery.Sender`; distinguish all four outcomes | [`delivery.gleam`](https://github.com/gleam-dream/correio/blob/a44986421f3b71bb55e9a4a8813fc89c83aaa79c/src/correio/delivery.gleam), `usage/delivery_outcomes.gleam` | Accepted is submission, not inbox arrival; scheduling and duplicate policy belong to application |
| SMTP config is pure, TLS is verified, local plaintext cannot carry credentials | `src/correio/smtp.gleam`, SMTP test source | No live SMTP-provider qualification performed |
| Lost DATA acknowledgement is unknown without automatic retry | [`lost_data_acknowledgement_is_unknown_without_retry_test`](https://github.com/gleam-dream/correio/blob/a44986421f3b71bb55e9a4a8813fc89c83aaa79c/test/mail/smtp_test.gleam#L65) counts DATA exactly once | Source assertion, not a fresh test result |
| Postmark needs response semantics and explicit token/body redaction | [`correio_postmark.gleam`](https://github.com/gleam-dream/correio/blob/a44986421f3b71bb55e9a4a8813fc89c83aaa79c/adapters/correio_postmark/src/correio_postmark.gleam), adapter README | HTTP 2xx alone is insufficient; no live account qualification |
| Checkpoint before triggering; mailbox content needs explicit development access | Root README and mailbox README | Capture is bounded, explicitly owned runtime; no server listener is supplied by mailbox |
| Passwordless issue does not send; evidence requires confirmed consumption | [`passwordless.gleam`](https://github.com/gleam-dream/correio/blob/a44986421f3b71bb55e9a4a8813fc89c83aaa79c/src/correio/passwordless.gleam), `usage/passwordless_memory.gleam` | Evidence does not create accounts, permissions, or sessions |
| Recover original command and retain evidence for idempotent session publication | Same sources; `unknown_acknowledgement_recovers_original_receipt_after_expiry_test`; passwordless design | No stable recovery-handle persistence format; original authentication time is retained |
| Landing GET does not consume; protected intentional POST verifies | [`passwordless_demo.gleam`](https://github.com/gleam-dream/correio/blob/a44986421f3b71bb55e9a4a8813fc89c83aaa79c/apps/passwordless_demo/src/passwordless_demo.gleam#L338), routing and confirm bodies | Application pattern, not automatic Correio middleware or production session implementation |
| New issue does not revoke earlier challenge | Passwordless design and `revoke_and_new_issue_are_independent_test` source | Explicit revocation follows application resend policy |
| Durable challenge store borrows named Pog pool and subject codec | PostgreSQL adapter README and passwordless storage design | Migration and cleanup remain explicit; cross-restart recovery needs separate application design |

Freshly retrieved [Postmark Email API](https://postmarkapp.com/developer/api/email-api) confirms the provider's ErrorCode/MessageID response structure. The adapter's conservative malformed-response classification remains its own contract. `address.gleam` explicitly documents excluded quoted local parts, address literals, and SMTPUTF8 mailboxes.

## Resolved dependency evidence

| Input | Selected resolutions |
| --- | --- |
| HTTP Gun root and ordinary consumer locks | Gun 2.6.0, Cowlib 2.21.0, gleam_otp 1.3.0, Sinal `58c6e7dea08abccd9f187d16b9ef5f9bb86eb769` |
| Warden root and consumer locks | HTTP Gun `db1cc9789af6cc6af2175d502dfcabb0451f4e2e`, same Sinal, gose 2.2.0, kryptos 1.5.0 |
| Correio core lock | gen_smtp 1.3.0 |
| Correio Postmark lock | HTTP Gun `fb06140984529b37e7286bfae5d31ff16c3a2231`, Sinal `9727f9baab6ed4f796780a0c3a1027c3292c5fc7` |
| Correio demo lock | Warden `b4797c1503efb403d7860884aad6336ee55550fb`, HTTP Gun `e4f00b8525e20a7b568b2cd585fe4e37db161b26`, Sinal `9727f9baab6ed4f796780a0c3a1027c3292c5fc7`, Pog 4.1.0 |

Sibling HEAD inspection does not establish an integration pass at a consumer's older lock. No dependency updates were made. A later disputed integration claim must be probed at its actual manifest resolution.

## Validation and limits

No code prototypes or runtime suites were needed for the selected rules: public contracts, consumer implementation, and selected test bodies answered the claims. This pass ran only file/manifest inspection and mechanical skill checks. It does not report fresh package, database, provider, browser, or oracle test passes.

Each skill has only `name` and `description` frontmatter, no compulsory peer loads, no supporting files, and exact-revision source links. Mechanical checks establish format and size, not agent effectiveness. No package implementation, installed skill, credential, provider account, repository history, or publication was changed.

Pending design verification is not closed by these focused reads. HTTP Gun retains numeric/native-assumption and recording-publication questions; Warden retains shutdown/reconciliation/profile questions; Correio retains broader delivery and browser verification entries. The skills avoid new numeric-default tables and stronger guarantees than the reviewed public sources establish.
