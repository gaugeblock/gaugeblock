---
status: accepted
date: 2026-11-06
deciders: colinwolff
consulted: none
informed: none
---

# Every binary emits one `--json` envelope

## Context and Problem Statement

`storypole list --json` returned a bare array while `show --json` returned an object, and no document stated
what `--json` was supposed to emit. The asymmetry was the symptom; the absence of a stated contract was the
cause, and it is why the shapes diverged.

## Decision Drivers

- Consumers are scripts, which cannot see a shape change.
- An array has nowhere to put anything added later.
- The suite is public and in beta, so a one-time break is cheapest now.

## Considered Options

1. Wrap `list` in an envelope, leaving `show` alone.
2. Flatten `show`, leaving `list` a bare array.
3. One envelope everywhere, defined in contracts, with `schema_version` from the first release.

## Decision Outcome

Chosen: **3**. `gaugeblock_contracts::json::envelope` composes `{schema_version, command, ...payload}`; the
payload key names the thing and never `data`; there is no `--json=payload` mode, because a second mode
recreates the inconsistency. `schema_version` stays `1` for the whole `0.1.x` line.

## Consequences

- Good: one shape, documented in `CONTRACTS.md`, adopted by 19 sites in one commit.
- Good: `schema_version` makes the next change a decision rather than a break.
- Bad: shell consumers written against the old shapes break once, deliberately.

## Links

- `GB-274`, `CONTRACTS.md`
