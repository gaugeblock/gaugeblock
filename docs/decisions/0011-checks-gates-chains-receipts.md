---
status: accepted
date: 2026-11-08
deciders: colinwolff
consulted: none
informed: none
---

# Checks, gates, chains and receipts are four different words

## Context and Problem Statement

The word "gate" was doing three jobs at once, and the consequences were real. `miter audit` was described in its own
help text as a scan that *flags* files, while every repository's verification chain depended on its exit code -
a report used as a gate, admitting it only in config. A reader asked whether `miter verify` was the umbrella term,
which is the obvious reading of the help text and the wrong reading of the system. `miter verify` is isolated
compiler verification of one crate; it appears in **zero** of the thirteen chains.

The confusion cost two conversations and one ticket's worth of preamble, and it will recur because the underlying
distinction was never written down.

## Decision Drivers

- A command's help text must not disagree with how the suite uses it.
- Composition must live in the composition layer (`ADR 0006`), not in whichever leaf tool is convenient.
- One fact, one owner: "what must pass in this repository" should not be described twice.
- A certification is only worth something if the record names what ran.

## Vocabulary

| word | means | examples today |
|:--|:--|:--|
| **check** | a command that inspects a property and exits non-zero when it does not hold | `miter audit`, `miter contracts`, `outfeed lockfiles`, `chalkline docs check` |
| **verification** | a *kind* of check: does it build and typecheck | `miter verify` |
| **gate** | a **role**: a check a workflow refuses to proceed without | `audit --paths` inside a chain; `outfeed gate` |
| **chain** | a composed sequence of gates for one repository | `[storypole] verification_commands[miter]` |
| **receipt** | the record that a chain ran, naming repository, branch and commit window | `VerificationReceipt` |

## Decision Outcome

1. **Kind and role are orthogonal.** "Check" names what a command does; "gate" names what a workflow requires. A
   command becomes a gate by being composed into a chain. Nothing needs renaming to become one.
2. **A check states its own exit behaviour.** If a command exits non-zero, its help text says so and says who depends
   on it. `audit` now does; it previously described itself as a report.
3. **Composition belongs to the composition layer** (`ADR 0006`). Chains are run by `storypole verify <KEY>`
   (ticket-scoped, writes a receipt) and `outfeed gate` (repository-scoped, runs a step matrix). A leaf tool must not
   grow a mode that runs other tools: it would become a composition root by accident and the layering gate would have
   to allowlist it against itself.
4. **`verify` legitimately names two things** because it has two objects: a crate (miter: does it compile) and a
   ticket (storypole: is it done, and here is the evidence). Both are correct where they appear, and distinguishing
   them in prose is cheaper than renaming a verb that receipts, plans and commit messages all reference.
5. **No `--gate` flag.** A suite-wide gate runner would be a second implementation of a chain that already exists,
   with no receipt; and "the same thing ran two ways" is exactly how two copies of one ticket came to disagree
   (`GB-79`).

## Consequences

- Good: the help text and the config can no longer disagree without someone noticing.
- Good: new checks know whether they are leaf checks or gate entries, which decides who calls them.
- Bad: two descriptions of "what must pass" still exist - `outfeed gate`'s hardcoded step matrix and the per-repository
  `verification_commands` strings. Reconciling them is a ticket, not a rename, and is the next thing this vocabulary
  exposes.
- Neutral: `--skip` on `outfeed gate` stays; skipping a step is a property of a runner, not of a check.

## More Information

`MTR-1` recorded the audit/verify question first. The audit help was corrected in `1131b26`. Related: `ADR 0006`,
`GB-272` (the chain), `GB-334` (verify refusals).
