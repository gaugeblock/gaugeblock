---
status: accepted
date: 2026-11-06
deciders: colinwolff
consulted: none
informed: none
---

# A crate whose product *is* composition gets its own layer, and the exemption is directional

## Context and Problem Statement

The layering gate (`miter deps --layers`) fails an edge between two domain crates unless the edge is
allowlisted with a ticket. That is the right default: two product cores importing each other weld two
surfaces together that were meant to evolve independently.

But some crates exist to drive other products. `joiner-core` runs a synthesis loop over `dado`, `batten`,
`sawhorse` and `miter-harness`; `benchwork-core` sits behind the workbench UI and drives storypole,
chalkline, joiner and dado on the operator's behalf. Their edges to product crates are the *product*, not a
leak. Forcing them into the allowlist would have meant entries that can never be paid off, which quietly
teaches the reader that allowlist entries are permanent — and then real debt hides among them.

## Decision Drivers

- An exemption must be falsifiable. "This crate has many dependencies" cannot be the test, or any crate
  qualifies by acquiring edges.
- The allowlist means *we owe a fix*. A composition root owes nothing, so it cannot live in the allowlist.
- The exemption must not weaken the gate for anyone else.

## Considered Options

1. **Allowlist the edges.** Rejected: an entry that can never be deleted degrades the meaning of every
   other entry, and the gate stops being a to-do list.
2. **Create a layer above domain for composition roots.** Chosen.
3. **Inject ports so the core never names its collaborators.** Rejected for `outfeed-core` specifically:
   under a port, the core still names the capabilities, so the coupling survives behind a trait object and
   the gate goes green while the dependency lives on. The code was moved out into `outfeed-orchestrator`
   instead (`GB-285`, `GB-286`).

## Decision

There is a layer between domain and integrator: `Orchestrator`, rank 2. A crate on the `ORCHESTRATORS` list
is classified there, and its edges to product crates classify as **downward**, which is unconstrained.

The list is hand-maintained and deliberately short — three members: `joiner-core`, `benchwork-core`,
`outfeed-orchestrator`.

## The test, stated so that it can fail

A crate is an orchestrator when **deleting the composition would delete the product**. If you removed its
calls into other products, would there still be a product left? If yes, it is not an orchestrator and the
composition is a step inside it.

The near-misses are recorded in the source next to the list, because they are the interesting cases:

- `outfeed-core` composes storypole and sawhorse, but its product is planning and applying one release;
  reading a task receipt is a step inside that. The composition moved out to a sibling crate rather than
  being blessed here.
- `chalkline-core` reads `storypole` and `miter-polyglot` to audit documentation. Documentation is the
  product; the reads are incidental.

## Consequences

The exemption is **directional and asymmetric**, which is what keeps it from being a free pass:

- An orchestrator may depend on foundation and domain crates freely.
- **Nothing in a lower layer may depend on an orchestrator.** A product reaching up is an upward edge,
  which the gate rejects outright — not an allowlist candidate.
- An orchestrator may not reach for an integrator. `outfeed-orchestrator → outfeed-cli` would be upward
  and forbidden, so composition roots cannot borrow CLI helpers.
- Two orchestrators depending on each other is lateral and gated like any other edge.

The cost is therefore real: an orchestrator cannot be used as a library by the products it drives. It is a
top-of-stack crate in the product graph, reachable only from integrators.

## Confirmation

`miter deps --layers` prints every crate's layer, so a mistake in the hand-maintained list is visible rather
than silent: a misclassified crate shows up as an unallowlisted lateral edge. The current state is one
lateral edge (`dado-core → miter-polyglot`, blocked on `GB-246`), one hundred and fifty-four downward, zero
upward. The allowlist went from nineteen entries to one as these members were found and either extracted or
classified (`GB-204`).
