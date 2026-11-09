---
status: accepted
date: 2026-11-08
deciders: colinwolff
consulted: none
informed: none
---

# A ticket is a file, and its identity is its uuid

## Context and Problem Statement

Tickets were stored as one append-only ledger per repository. Every write appended to the most contended file in
the repository, so two branches always conflicted at end-of-file, an ownership move meant rewriting a log, and a
ticket's mapping to an external tracker had nowhere to live. `GB-79` recorded the consequence: the same task could
exist in two copies that disagreed about whether the work was done.

The migration to one file per ticket (`GB-331`) has now run against the suite: 350 tickets, 159 staying at the root
and 191 distributed to the repositories their own scope named. That makes the storage contract a thing other code
depends on rather than a design in progress, so it is written down.

## Decision Drivers

- A merge must be able to resolve two branches touching different tickets without a conflict.
- A clone of one repository must answer for its own backlog.
- A ticket must never exist in two places, because nothing defines which copy wins.
- External tracker integration must not require a central mapping that is itself cross-repository state.

## Considered Options

1. One append-only ledger per repository (the previous state).
2. One file per ticket, ownership by the ticket's own scope.
3. A record-oriented database, with the files as a projection.

## Decision Outcome

Chosen: **2**, with these invariants:

- **One file per ticket**, at `.gaugeblock/storypole/tickets/<KEY>.json`, holding the task, its events and an
  optional external mapping. A merge is a file merge; an ownership move is a file move.
- **Identity is the task uuid.** A uuid in two files is corruption to report with both paths, never a state to
  merge. The rollup refuses it (`GB-330`) because `GB-79` is what merging it looks like.
- **The owner is `scope.repo`**, fixed at creation. Adoption may attribute an unscoped ticket to the repository that
  owns its crate, and only when the evidence is unambiguous (`GB-331`).
- **A key prefix is a minting convention, never an owner.** `GB-17` living in `benchwork` is legal; the prefix map
  is consulted only when minting. Numbers come from one counter per repository, in the git directory (`GB-347`).
- **Edges reference, they never copy.** An edge carries the target's uuid for identity plus a cached key and
  repository for rendering where the target is not present (`GB-332`). Copying the target is the `GB-79` failure.
- **Replay order comes from the record, not the file.** Events sort by `(timestamp, id)`, so a merge that
  interleaves two histories cannot let a stale status win on line position.
- **Writing is exclusive and atomic.** A new record is reserved with `O_CREAT|O_EXCL`, written completely, and
  renamed into place; a read-modify-write takes a per-ticket lock (`GB-329`, `GB-345`).

### The integration seam

A ticket carries an optional `external` field — system, id, sync timestamp — and no adapter. The mapping travels
with the ticket it describes, so a central map never has to exist and a per-ticket sync failure stays isolated.
Adapters are deliberately unimplemented: the format is compatible with one, and building one before knowing the
workflow is how a six-step epic closes at 0/6.

### What this does not decide

- **Rendering** the locator is consumer-side (`GB-332`).
- **Adoption** of the 72 tickets attributed by crate evidence has been reviewed and run, but a future ticket whose
  crate name is ambiguous will need the same judgement, not an extension of the rule.

## Consequences

- Good: a solo clone is complete; a merge is a file merge; ownership moves are `git mv`.
- Good: `storypole verify` can be made to refuse on evidence rather than on trust (`GB-334`).
- Bad: 350 small files instead of one ledger, so a whole-store operation reads every file. The rollup is the
  intended path for that, and an index is derived from them.
- Bad: the legacy ledger path remains readable, so two layouts exist until the last repository migrates.
- Neutral: `ledger-archive/ledger-migrated.jsonl` keeps the pre-migration history. It is evidence, not state.

## More Information

Implements the storage half of ADR 0009 and supersedes the ledger append described in ADR 0001. Related: `GB-329`,
`GB-330`, `GB-331`, `GB-332`, `GB-333`, `GB-345`, `GB-347`, `GB-79`.
