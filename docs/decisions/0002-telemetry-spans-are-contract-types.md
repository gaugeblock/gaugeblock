---
status: accepted
date: 2026-11-05
deciders: colinwolff
consulted: none
informed: none
---

# Flight-recorder spans are shared contract types in an append-only log

## Context and Problem Statement

Reasoning traces are the raw material for training data and for diagnosing agent work, but each tool was
capable of recording only what it could see. A trace written by one process and read by another needs a shape
both agree on, and a channel that does not depend on the daemon being up.

## Decision Drivers

- Cross-process: producers are CLIs, MCP servers and the release gate.
- Recording must never fail the work it observes.
- Concatenation must not require coordination between writers.

## Considered Options

1. An in-process event bus in `benchwork`.
2. A per-tool log format.
3. One span record type in `gaugeblock-contracts`, appended as JSONL.

## Decision Outcome

Chosen: **3**. `TelemetrySpan` lives in contracts, one `O_APPEND` line per span, emitted fail-open; the file
is the channel. `benchwork` indexes and streams it, but nothing records *through* a server.

## Consequences

- Good: producers need no running daemon; a read-only checkout or full disk means "no telemetry", never a
  failed command.
- Good: an index can be rebuilt by re-tailing, so the database is disposable.
- Bad: the log is plaintext on disk, so spans must not carry prompt or completion text - which is why the
  record has no field for it.

## Links

- `GB-243`, `common/crates/gaugeblock-contracts/src/telemetry.rs`
