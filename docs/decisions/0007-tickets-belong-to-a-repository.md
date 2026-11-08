---
status: accepted
date: 2026-11-07
deciders: colinwolff
consulted: none
informed: none
---

# A ticket belongs to a repository, and its receipt says which

**Supersedes:** none · **Related:** `GB-313`, `GB-316`, `GB-311`, `GB-305`

## Context and Problem Statement

The suite is twelve repositories with one canonical backlog at the root. Work happens inside member
repositories; tickets live in the harness ledger.

Nothing recorded which repository a ticket referred to. `TaskScope` carried `repo` and `crate_name`
fields that no path ever populated, so `resolve_target_dir` fell through to the harness root. A receipt
produced for `miter` work therefore named the harness branch and the harness commit count — plausible,
well-formed, and about the wrong repository.

Two consequences followed. Agents began branching the harness to the same name as the member branch so
that a ledger line could be tied to a code branch. And `storypole verify` could not run inside a member
repository at all, because the member holds a stub store rather than a view of the canonical ledger.

## Decision Outcome

1. **A ticket carries a repository scope**, resolved by one function in a fixed order: explicit
   argument, persisted scope, derivation from the files and symbols the ticket names, the working
   directory at claim time, then harness. The function reports *how* it resolved.
2. **Derivation is persisted once, at claim.** Later commands read the persisted value. A later
   disagreement is an error rather than a silent re-derivation.
3. **A receipt records its provenance**: repository, branch, base and head commits, commit count, and
   the verification chain key that matched. A receipt is evidence, and evidence that does not say what
   it measured is decoration.
4. **Absence does not resolve to a default.** An unscoped ticket cannot be certified as member work;
   `verify` refuses and names the candidate scope.
5. **The ledger is linear on the harness `main`.** Code branches belong to member repositories. The
   harness is not branched for member work, because the receipt — not the branch name — carries the
   link between record and code.
6. **The canonical ledger is discovered through suite topology** from inside a member repository. The
   guard introduced in `GB-305` (a nested repository must not adopt an unrelated parent ledger) is
   retained for repositories that are not members of the suite.

## Consequences

- Mirror-branching in the harness has no remaining purpose and should not be done.
- Receipts for different repositories and different chains become distinguishable, which is a
  precondition for any later claim about suite-wide verification coverage.
- A guessed scope that turns out wrong is now a visible error rather than a quiet default. Tickets
  created before this decision have no scope and will be treated as unscoped until corrected.
- `storypole` gains a dependency on suite topology (`gaugeblock-workspace`) for ledger discovery, which
  is the same dependency the layout gate already requires of crates naming `.gaugeblock`.
