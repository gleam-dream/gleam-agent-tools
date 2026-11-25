---
name: llm-wire
description: Call LLM providers and handle typed answers, tool requests, streaming, classification, and transcription with llm_wire. Use for provider request preparation, conversation replay, structured output, stream lifetimes, and retry decisions in Gleam applications.
metadata:
  library: gleam-dream/llm_wire
  library-ref: 72e7d496e416bbe3e2819e738fa106b1595d4ed9
---

# LLM Wire

Choose LLM Wire on Erlang/OTP for common typed provider outcomes, preflight validation, and streaming while the application owns history, tools, and retries. A narrow provider client suffices without these shared contracts; Fabric adds retained execution. Generation adapters cover OpenAI Responses, Anthropic Messages, and Google GenerateContent.

Add the latest `llm_wire` release (`gleam add llm_wire`); retain the resolved `manifest.toml`.

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

1. Select an adapter and an available model. Supply credentials through live configuration.
2. Build messages with `request`; add tools, output codecs, a thinking level, or reusable `generation.Settings`.
3. Call `prepare` first; it validates and encodes without I/O. Handle unsupported settings and schemas there.
4. Run with an application-owned HTTP Gun client. Share a supervised client in a service; stop a short-lived client on every exit path.
5. Match every outcome: `Answer`, `NeedsTools`, `OutputLimited`, and `Refused`. A token-limited partial answer is incomplete. The token limit also counts thoughts; leave headroom with a thinking level.

Use `with_output(name, codec)` for decoded answers. Its codec must have a record root. Provider schema profiles differ; a valid Blueprint codec does not prove provider acceptance.

## Own the tool loop

- Declare tools from their input contracts and decode arguments before acting.
- On `NeedsTools`, retain the returned `AssistantTurn`. Append `message.Assistant(turn)` and one `tool_result` for every call to the next request.
- Preserve call ids, ordering, and opaque provider replay data when storing history. Use the message and turn codecs; rebuilding a turn from visible text loses information.
- Keep authorization, effect identity, and tool errors in the application. A model request cannot authorize a business action.
- A `tool.new` tool carries its input codec into each call's processes; the `with_output` codec stays in your process ([codecs and process copies](https://github.com/gleam-dream/llm_wire/blob/main/README.md#codecs-and-process-copies)). For tools sent on many calls, use `from_contract` or `from_json_schema` tools, which copy schema only, with `decode_arguments`, and build run-time enums once ([codec guide](https://github.com/gleam-dream/json_blueprint/blob/main/docs/CODEC-PRACTICE.md)).
- Handle `ThinkingUnsupported` from `prepare`: a thinking level the provider cannot carry is refused, never dropped.

## Own streams and retries

- Read a stream until `Done`, or close it when abandoning it. Keep one outstanding reader.
- `next_within` returning `TimedOut` is a read timeout: the stream stays readable and the call may continue.
- Classify retry prospects with `advise(failure)`. LLM Wire never retries.
- Inspect `sent`, `partial_output`, and optional usage; `output_tokens` includes thoughts. `MaybeSent` can mean paid remote work; missing usage does not mean zero tokens.
- Bound attempts, backoff, and provider delay by one application deadline. `ProviderDelay` is uncapped advice; never sleep past the remaining budget.

Classification maps authored alternatives into native answers; confidence is provider evidence, not correctness. Neither classification nor transcription implies generation streaming, uploaded audio, or diarization.

## Red flags

- Retrying every timeout or treating retry advice as an effect guarantee.
- Treating output truncation, refusal, or invalid structured output as success.

## Verify

Check the manifest before using a signature. Validate changed request and replay claims with the package's offline consumer playback; use live providers only when live behavior is required.

## Sources

[HexDocs](https://hexdocs.pm/llm_wire/) · [Public API](https://github.com/gleam-dream/llm_wire/blob/main/src/llm_wire.gleam) · [Consumer topics](https://github.com/gleam-dream/llm_wire/tree/main/examples/consumer) · [Design](https://github.com/gleam-dream/llm_wire/tree/main/docs/design)
