---
name: llm-wire
description: Call LLM providers and handle typed answers, tool requests, streaming, classification, and transcription with llm_wire. Use for provider request preparation, conversation replay, structured output, stream lifetimes, and retry decisions in Gleam applications.
---

# LLM Wire

Choose LLM Wire on Erlang/OTP for common typed provider outcomes, preflight validation, and streaming while the application owns history, tools, and retries. A narrow provider client suffices without these shared contracts; Fabric adds retained execution. Generation adapters cover OpenAI Responses, Anthropic Messages, and Google GenerateContent.

Use Hex `llm_wire` 0.2.0 with `json_blueprint >= 2.2.0`; retain the resolved `manifest.toml`.

## Abstraction decision tree

```text
Need model-selected tool execution with retained recovery? → Fabric
Need a provider call controlled by the application? → LLM Wire
├── Text, structured answer, or tools → request → prepare → run
├── Incremental generation → stream → next until Done
├── Typed choices, scores, or question batches → classify request family
└── Bounded inline audio → transcription request family
```

## Prepare, execute, interpret

1. Select an adapter and model available to the application. Supply credentials through live configuration.
2. Build messages with `request`; add tools, output codecs, a thinking level, or reusable `generation.Settings`.
3. Call `prepare` before execution. It validates and encodes without I/O; handle unsupported settings and schemas there.
4. Run with an application-owned HTTP Gun client. Share a supervised client in a service; stop a short-lived client on every exit path.
5. Match every outcome: `Answer`, `NeedsTools`, `OutputLimited`, and `Refused`. A token-limited partial answer is not a complete typed answer. The token limit also counts thoughts; leave headroom with a thinking level.

Use `with_output(name, codec)` for decoded answers. Its codec must have a record root. Provider schema profiles differ; a valid Blueprint codec alone does not establish provider acceptance.

## Own the tool loop

- Declare tools from their input contracts and decode arguments before acting.
- On `NeedsTools`, retain the returned `AssistantTurn`. Append `message.Assistant(turn)` and one `tool_result` for every call to the next request.
- Preserve call ids, ordering, and opaque provider replay data when storing history. Use the message and turn codecs; rebuilding a turn from visible text loses information.
- Keep authorization, effect identity, and tool errors in the application. A model request cannot authorize a business action.
- Each call copies its tool list about five times ([measured](https://github.com/gleam-dream/llm_wire/blob/9059fdfa54c3d72eb489914926f3cea75b2e99f6/issues/hold-tools-once-per-call/PRD.md)). A `tool.new` tool's decode closure holds its input codec, so every copy includes it (about its own size from json_blueprint 2.2.0). `from_contract` and `from_json_schema` tools copy schema only; the `with_output` codec stays in your process. For tools sent on many calls, prefer contract-only tools with `decode_arguments`. Build run-time enums once ([codec guide](https://github.com/lostbean/json_blueprint/blob/v2.2.0/docs/CODEC-PRACTICE.md)).
- In 0.2.0 every OpenAI tool call fails with `Protocol("Duplicate tool block completion")`; until a fixed release, use another adapter for tools.

## Own streams and retries

- Read a stream until `Done`, or close it when abandoning it. Keep one outstanding reader.
- `next_within` returning `TimedOut` is a read timeout: the stream stays readable and the call may continue.
- Use `advise(failure)` to classify retry prospects. LLM Wire never retries automatically.
- Inspect `sent`, `partial_output`, and optional usage; `output_tokens` includes thoughts. `MaybeSent` can mean paid remote work; missing usage does not mean zero tokens.
- Bound attempts, backoff, and provider delay by one application deadline. `ProviderDelay` is uncapped advice; do not sleep beyond the remaining budget.

Classification maps authored alternatives into native answers; confidence is provider evidence, not correctness. Neither classification nor transcription implies generation streaming, uploaded audio, or diarization.

## Red flags

- Retrying every timeout or treating retry advice as an effect guarantee.
- Treating output truncation, refusal, or invalid structured output as success.

## Verify

Check the manifest before using a signature. Validate changed request and replay claims with the package's offline consumer playback; use live providers only when the task requires live behavior.

## Sources

[HexDocs](https://hexdocs.pm/llm_wire/0.2.0/) · [Public API](https://github.com/gleam-dream/llm_wire/blob/v0.2.0/src/llm_wire.gleam) · [Consumer topics](https://github.com/gleam-dream/llm_wire/tree/v0.2.0/examples/consumer) · [Design](https://github.com/gleam-dream/llm_wire/tree/v0.2.0/docs/design)
