---
name: llm-wire
description: Call LLM providers and handle typed answers, tool requests, streaming, classification, and transcription with llm_wire. Use for provider request preparation, conversation replay, structured output, stream lifetimes, and retry decisions in Gleam applications.
---

# LLM Wire

Choose LLM Wire on Erlang/OTP for common typed provider outcomes, preflight validation, and streaming while the application owns history, tools, and retries. A narrow provider client suffices without these shared contracts; Fabric adds retained execution. Generation adapters cover OpenAI Responses, Anthropic Messages, and Google GenerateContent.

Use Hex `llm_wire` 0.1.0 and retain the resolved `manifest.toml`.

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
2. Build messages with `request`; add tools, output codecs, or reusable `generation.Settings` as needed.
3. Call `prepare` before execution. It validates and encodes without I/O; handle unsupported settings and schemas there.
4. Run with an application-owned HTTP Gun client. Share a supervised client in a service; stop a short-lived client on every exit path.
5. Match every outcome: `Answer`, `NeedsTools`, `OutputLimited`, and `Refused`. A token-limited partial answer is not a complete typed answer.

Use `with_output(name, codec)` for decoded answers. Its codec must have a record root. Provider schema profiles differ; a valid Blueprint codec alone does not establish provider acceptance.

## Own the tool loop

- Declare tools from their input contracts and decode arguments before acting.
- On `NeedsTools`, retain the returned `AssistantTurn`. Append `message.Assistant(turn)` and one `tool_result` for every call to the next request.
- Preserve call ids, ordering, and opaque provider replay data when storing history. Use the message and turn codecs; rebuilding a turn from visible text loses information.
- Keep authorization, effect identity, and tool errors in the application. A model request cannot authorize a business action.

## Own streams and retries

- Read a stream until `Done`, or close it explicitly when abandoning it. Keep one outstanding reader.
- Treat `next_within` returning `TimedOut` as a read timeout: the stream remains readable. It does not establish that the provider call ended.
- Use `advise(failure)` to classify retry prospects. LLM Wire never schedules or retries automatically.
- Inspect `sent`, `partial_output`, and optional usage. `MaybeSent` can mean paid remote work; missing usage does not mean zero tokens.
- Bound attempts, backoff, and provider delay by one application deadline. `ProviderDelay` is uncapped advice; do not sleep beyond the remaining budget.

Classification maps authored alternatives into native answers, such as `Publish` or `Revise`; confidence is provider evidence, not correctness. Classification and transcription have separate contracts; neither implies generation streaming, uploaded-audio lifecycle, or diarization.

## Red flags

- Retrying every timeout or treating retry advice as an effect guarantee.
- Flattening assistant turns to text before a tool round or restart.
- Treating output truncation, refusal, or invalid structured output as success.
- Sharing a stream reader or abandoning a stream without closing it.
- Assuming this Erlang package supplies a browser implementation.

## Verify

Check the application's manifest before using a signature. Validate changed request and replay claims with the package's offline consumer playback; use live providers only when the task requires live behavior.

## Sources

[HexDocs](https://hexdocs.pm/llm_wire/0.1.0/) · [Public API](https://github.com/gleam-dream/llm_wire/blob/0e872683dc674a3b652019037926ad218a165a21/src/llm_wire.gleam) · [Consumer topics](https://github.com/gleam-dream/llm_wire/tree/0e872683dc674a3b652019037926ad218a165a21/examples/consumer) · [Design](https://github.com/gleam-dream/llm_wire/tree/0e872683dc674a3b652019037926ad218a165a21/docs/design)
