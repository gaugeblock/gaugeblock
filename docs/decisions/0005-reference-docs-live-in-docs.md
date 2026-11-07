---
status: accepted
date: 2026-11-06
deciders: colinwolff
consulted: none
informed: none
---

# Reference documents live in `docs/`; README, CHANGELOG and AGENTS stay at the root

## Context and Problem Statement

Nine markdown documents sat at every repository root, so the shopfront competed with reference material and
the root filled with prose that is read rarely and referenced often.

## Decision Drivers

- README is the crates.io readme and the first thing a visitor sees.
- `CHANGELOG.md` and `AGENTS.md` are read by tooling and agents at conventional paths.
- The docs audit is config-driven, so moving files costs configuration rather than code.

## Considered Options

1. Leave everything at the root.
2. Move all nine into `docs/`.
3. Move the six reference documents, keeping README, CHANGELOG and AGENTS at the root.

## Decision Outcome

Chosen: **3**. `.gaugeblock/docs.toml` declares a path per document type, which the audit already honoured, so
no chalkline change was needed. Applied across all eleven repositories.

## Consequences

- Good: roots are shopfronts; reference material has a home; 108/108 documents audit clean afterwards.
- Good: locations are configuration, so a future repository can choose differently.
- Bad: relative links break in both directions on the move - inbound from root docs, outbound to `./src`. The
  audit caught every one, which is the reason this was safe to do eleven times.

## Links

- `GB-275`, `.gaugeblock/docs.toml`
