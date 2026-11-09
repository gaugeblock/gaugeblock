---
status: accepted
date: 2026-11-08
deciders: colinwolff
consulted: none
informed: none
---

# Source state follows the branch; derived state follows the checkout

## Context and Problem Statement

ADR 0001 put canonical state in one `.gaugeblock` per repository, resolved through the git common dir, so that
every worktree of a repository agrees. That is true of the *path resolver* and was assumed true of the state
itself. Parallel agent work made the assumption testable and it does not hold.

Measured on a repository with one linked worktree: `ledger.jsonl` has different inodes in the main checkout
(`56762556`) and in the worktree (`56762621`). Git checks out tracked files per working tree, so a worktree has
its own copy of every tracked file under `.gaugeblock`. Nothing resolves that away, because the copy is what the
branch says the state is.

Three defects came from not having decided this: a worktree with no local store built a second one (`GB-346`),
two branches minted the same ticket number and merged as an add/add conflict (`GB-347`), and claim leases would
be invisible across worktrees, letting two agents take one ticket (`GB-333`).

## Decision Drivers

- Parallel agents in several worktrees are the intended workflow, not an edge case.
- Tracked state must be reviewable and revertable with the change that produced it.
- Coordination must not be reviewable: a lease is not a design decision.
- A ticket number must be unique in a repository, whatever checkout mints it.

## Considered Options

1. Everything in the common dir: one state directory for all worktrees.
2. Everything per worktree, including leases and counters.
3. Split by whether the state is tracked.

## Decision Outcome

Chosen: **3**.

- **Tracked state follows the branch.** Tickets, the legacy ledger, and design plans live in the working
  tree's `.gaugeblock/storypole`. A change to them rides the branch that made it, is reviewed with the code,
  and merges per file. Two worktrees holding two sets of tickets is correct behaviour, not divergence.
- **Derived and coordination state follows the checkout.** `index.sqlite` is disposable and rebuildable. The
  ticket-number counter and (per `GB-333`) claim leases are coordination state: shared by every checkout of one
  repository and never tracked. Both live in the **git directory** (`<common>/.git/storypole/…`), which is
  shared per repository by construction and needs no ignore rules.
- **Numbers are allocated from the shared counter**, taking `max(counter, index)` so a repository whose history
  predates the counter continues from the numbers already in use rather than re-issuing them.

## Consequences

- Good: two agents cannot mint the same ticket number, and cannot silently take the same ticket.
- Good: a ticket edit appears in the pull request for the work it describes.
- Good: no `.gitignore` gymnastics — coordination state never enters the working tree.
- Bad: a claim made in one worktree is not part of the branch history, so the ledger does not record it until
  some later event does. The ticket file keeps the claim as history once it is written.
- Bad: a repository with no commits has no reliable common dir, so allocation falls back to the store
  directory. Acceptable: there is nothing to coordinate with yet.
- Neutral: `.gaugeblock` in the working tree remains the only tracked location, so ADR 0001's rule about
  *where state lives* stands. What this decides is *which copy of it a command sees*.

## More Information

Supersedes in part ADR 0001, which did not distinguish tracked from derived state. Related: `GB-329` (the
ticket records that exposed it), `GB-333` (leases), `GB-346`, `GB-347`.
