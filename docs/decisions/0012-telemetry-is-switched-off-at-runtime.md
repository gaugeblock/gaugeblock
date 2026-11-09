---
status: accepted
date: 2026-11-08
deciders: colinwolff
consulted: none
informed: none
---

# Telemetry is on by default, and switched off at runtime, never at compile time

## Context and Problem Statement

One crate emits spans today (`sawhorse-core`, provider completions) and one consumes them (benchwork's panel). A user
who installs `miter` alone therefore writes a file nobody reads. That invites the question of whether telemetry should
be a Cargo feature, so a build can leave it out entirely.

The question is worth answering once rather than per tool, because "optional" has three meanings here and only one of
them works.

## Decision Drivers

- A user must be able to turn it off, and the mechanism must actually reach the code that writes.
- The suite has ten CLIs; every optional build configuration is a configuration nobody tests.
- Emission must never cost a caller correctness, and must never fill the log with junk (`GB-340`).
- The data has a second, future consumer (training corpora), which argues against making it hard to produce.

## Considered Options

1. **A Cargo feature** (`telemetry`, default on, `--no-default-features` to omit it).
2. **A config key** (`[telemetry] enabled`), with the environment variable as an override.
3. **Nothing** - rely on the log rotating away.

## Decision Outcome

Chosen: **2**.

- **`[telemetry] enabled`** in `.gaugeblock/config.toml`, defaulting to `true`, checked at the same choke point as the
  test-binary guard so no emitter can forget it.
- **Precedence is env → config → default.** `GAUGEBLOCK_NO_TELEMETRY` wins because it exists for scripts, CI and test
  runs, where there is no config file to edit; the config wins over the default because that is where the rest of a
  repository's policy already lives.
- **No Cargo feature.** Rejected for a mechanical reason as much as a philosophical one: cargo features are *additive*,
  so a downstream crate cannot switch one off for the build. `default-features = false` declines what the consumer
  would have enabled; any other crate in the graph re-enables it. A feature gate would look like an opt-out and not be
  one - precisely for the "I only installed one tool" case that motivates it. It would also save nothing: spans are
  contract types (`ADR 0002`), so `uuid`, `serde` and `serde_json` are already in the dependency graph.

## Consequences

- Good: the off switch is discoverable where a user looks for configuration, and provably reaches the writer.
- Good: one build configuration, so every tool is tested as shipped.
- Bad: a user with no panel gets a directory they never read. Bounded by rotation (`GB-341`) rather than removed.
- Bad: someone wanting telemetry compiled out entirely cannot have it. Accepted: the cost is one append syscall per
  operation on a fail-open path.
- Neutral: the log stays useful without a panel, because `first_diagnostic` records what failed and how long it took -
  a lone `sawhorse` user debugging a provider has a record. That, not the panel, is the reason the default is on.

## More Information

`GB-340` added the runtime guard this builds on. `GB-338` gives the writer one location; `GB-339` widens emission;
`GB-341` decides retention. Related: `ADR 0002` (spans are contract types), `ADR 0011` (checks and gates).
