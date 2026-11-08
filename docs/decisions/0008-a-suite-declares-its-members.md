---
status: accepted
date: 2026-11-07
deciders: colinwolff
consulted: none
informed: none
---

# A suite declares its members; membership is never inferred from layout

**Supersedes:** none · **Amends:** `0007` (which assumed topology could derive membership) · **Related:** `GB-324`, `GB-317`, `GB-305`, `GB-311`

## Context and Problem Statement

`GB-316` needed a member repository to reach the suite's canonical ledger. That requires answering
"which suite contains this repository", and no part of the suite could answer it: `GaugeblockPaths::discover`
resolves through git's own repository discovery, so from inside a member it returns the member as a suite
of one, and `WorkspaceTopology::discover` takes a root as an argument rather than finding one.

Two proxies were tried and both failed, for reasons worth recording:

1. **A hardcoded roster** (`expected_members`) answered correctly for this suite and for no other, and
   made the resolver impossible to test under fixture names.
2. **A git-boundary walk** could not distinguish a member of a suite from a checkout nested inside a
   repository, because in both shapes the store sits above the caller's own repository root.

The underlying reason is that layout carries no intent. A member repository holds its own
`.gaugeblock/` — an index, a stub, a docs configuration — so it looks exactly like a suite of one; and a
suite root is itself a git repository containing members, so it looks exactly like a repository
containing a nested checkout.

## Decision Outcome

The suite states its members in `.gaugeblock/config.toml`:

```toml
[suite]
members = ["miter", "storypole", ...]
```

`SuiteConfig::members` reads it; `Membership::containing` skips any candidate that declares no members,
and a suite that declares nothing answers for nobody.

## Consequences

- A repository that cannot prove it belongs to a suite keeps its own ledger. Adoption is a decision,
  never a fallback, which keeps `GB-305`'s protection without a git-boundary heuristic.
- `storypole` resolves the canonical ledger from inside a member repository: `storypole show` works in
  `miter/crates/engine`, where it previously reported "task not found".
- A suite now has one more thing to get right. Adding a member without adding it to the list means that
  member's work records into its own ledger — visible, and the safe direction, but a real obligation.
- Standalone users who are not this suite must declare their own members. An undeclared suite is a
  cluster of independent repositories, which is the correct reading of an absent declaration.
