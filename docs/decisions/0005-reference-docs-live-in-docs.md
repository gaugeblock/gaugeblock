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

## Amendment (2026-11-07) — `CONTRIBUTING.md` belongs at the root

This decision was applied by file count rather than by purpose, and `CONTRIBUTING.md` was swept into
`docs/` across all eleven member repositories. It should not have been: GitHub surfaces a contributing
guide in the new-issue and pull-request flows, so its conventional location is the root, next to
`README.md`. A document read by tooling is not reference material, which is the distinction this decision
was reached on in the first place.

Corrected: `CONTRIBUTING.md` is back at the root in every repository, the six reference documents remain
under `docs/`, and the meta-harness root now holds only `README.md`, `CHANGELOG.md`, `CONTRIBUTING.md`
and `AGENTS.md` (`GB-320`).

The migration was also never applied to the meta-harness root at all, and the audit could not say so:
it verified that the paths declared in `docs.toml` existed, and `docs.toml` still declared the
pre-migration layout. The check's input was the thing the migration would change. `chalkline docs check`
now fails when an **undeclared** markdown file sits at a repository root, which is the half that was
missing - declaring where documents belong cannot detect a document nobody declared.

## Links

- `GB-275`, `.gaugeblock/docs.toml`
