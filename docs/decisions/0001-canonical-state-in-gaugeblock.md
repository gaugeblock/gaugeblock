---
status: accepted
date: 2026-10-29
deciders: colinwolff
consulted: none
informed: none
---

# Canonical suite state lives in `.gaugeblock`, rooted at the git common dir

## Context and Problem Statement

The suite had sixty-three sites each spelling `.gaugeblock` relative to whatever directory the caller was in.
That is correct in the main checkout and wrong in a linked worktree, where the working tree and the common dir
differ - so a worktree grew a second ledger and a second spool, and two agents working in parallel disagreed
about which records existed.

## Decision Drivers

- Standalone value: each repository must work alone, so state cannot live in one central place.
- Worktrees and parallel agents must see one truth.
- Tools must not each invent their own path convention.

## Considered Options

1. Recompute every path at each call site.
2. One suite-wide directory for everything.
3. One canonical directory per repository, resolved through the git common dir.

## Decision Outcome

Chosen: **3**. `GaugeblockPaths::discover` resolves `.gaugeblock` from the git common dir, so every worktree of
a repository agrees, and separate repositories stay independent. Path knowledge lives in one crate
(`gaugeblock-workspace`) rather than in sixty-three places.

## Consequences

- Good: worktrees share a ledger; no tool needs its own path logic; tested by `GB-189`.
- Good: the rule is per repository, which keeps each tool usable alone.
- Bad: a tool that takes a raw path can still bypass the resolver, so the guarantee holds only where the
  resolver is used.

## Links

- `GB-189`, `common/crates/gaugeblock-workspace/src/paths.rs`
