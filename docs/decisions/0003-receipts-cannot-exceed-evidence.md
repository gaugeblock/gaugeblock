---
status: accepted
date: 2026-11-06
deciders: colinwolff
consulted: none
informed: none
---

# A verification receipt may never be stronger than the evidence behind it

## Context and Problem Statement

`storypole verify` recorded `exit_code: 0` in under a second having run nothing, unless `--run` was
remembered. `verification_commands` was empty in all eleven configs, so the configured gate never ran, and a
fallback to `cargo test` was indistinguishable in the receipt from a full chain. Certification looked present
and was absent - the worst state for a record intended to become training data.

## Decision Drivers

- A receipt is evidence; evidence that overstates itself is worse than none.
- The suite's own agents gate on these receipts.
- Silence that reads as success is the dominant defect class observed in this project.

## Considered Options

1. Keep the manual default and document it.
2. Make execution the default, with `--manual` as an explicit opt-out, and label weakness in the receipt.
3. Error when no command is configured.

## Decision Outcome

Chosen: **2**. `verify` executes the configured command by default; `--manual` records an attestation and says
so; the verifier string and summary record which command ran. A fallback to `cargo test` is retained but
labelled, because a single-repo clone may legitimately only have cargo.

## Consequences

- Good: certification costs what the gate costs - measured 12.4s suite-level, 84.8s repo-level including a
  cold compile - and means something.
- Good: within minutes of being real, the gate caught two documentation drifts introduced the same hour.
- Bad: `verify` is no longer instant, and a caller who wanted a quick note must now ask for it.

## Links

- `GB-268`, `GB-269`, `GB-272`
