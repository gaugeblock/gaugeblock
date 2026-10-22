# `gaugeblock` — Precision Neurosymbolic Code Synthesis Suite

> A deterministic, multi-repository meta-harness for AI-native systems engineering, AST slicing, semantic task management, and verified code synthesis.

---

## Ecosystem Architecture

The `gaugeblock` suite consists of 9 standalone, highly focused tools that connect deterministically via strict wire data contracts:

| Repository | Role | Core Responsibility |
|---|---|---|
| [`miter`](https://github.com/gaugeblock/miter) | AST & Verification | AST slicing, lexical scope indexing, and compiler error verification. |
| [`storypole`](https://github.com/gaugeblock/storypole) | Backlog & DAG | Git-native append-only ledger (`.storypole/`), task DAG, and MCP memory server. |
| [`sawhorse`](https://github.com/gaugeblock/sawhorse) | Model Runtime | 3-mode provider-agnostic inference engine (OpenAI-compat, Local GGUF, Candle). |
| [`chalkline`](https://github.com/gaugeblock/chalkline) | Spec Planner | Interactive `/grill-me` specification planner, AST extractor, and DAG compiler. |
| [`dado`](https://github.com/gaugeblock/dado) | Context Slicer | AST context window optimization and minimal symbol slice assembly. |
| [`batten`](https://github.com/gaugeblock/batten) | Grammar & Guidance | Context-free grammar (CFG) constrained decoding engine. |
| [`joiner`](https://github.com/gaugeblock/joiner) | Code Synthesizer | Neurosymbolic hole filler, iterative AST patcher, and compiler verifier. |
| [`benchwork`](https://github.com/gaugeblock/benchwork) | Benchmark & UI | Local web console, SWE-bench evaluation harness, and execution recorder. |
| [`rabbet`](https://github.com/gaugeblock/rabbet) | Telemetry & Training | DPO/RL trace collector, privacy scrubber, and dataset compiler. |

---

## Core Documentation

* **[`AGENTS.md`](./AGENTS.md):** Non-negotiable engineering laws, workspace conventions, and agent execution loop.
* **[`CONTRACTS.md`](./CONTRACTS.md):** Shared wire types, JSON schemas, and inter-repository trait boundaries.
* **[`ROADMAP.md`](./ROADMAP.md):** Master 9-phase bootstrap and implementation roadmap.
* **[`CONTRIBUTING.md`](./CONTRIBUTING.md):** Conventional commits, atomic commits, tiered verification matrix, and semantic versioning.
* **[`PRODUCT.md`](./PRODUCT.md):** Product requirements, user stories, and design invariants.

---

## Development & Verification Standards

All repositories in this workspace adhere to strict quality invariants:

* **File Size Limit:** No `.rs`, `.ts`, or `.tsx` file may exceed 250 lines of code.
* **Tiered Verification Matrix:**
  * **Tier 1 (Inner Loop):** `cargo check -p <crate>` for rapid iteration (<2s).
  * **Tier 2 (Commit Gate):** `cargo fmt --check -p <crate>`, `cargo clippy -p <crate>`, and `cargo test -p <crate>` before each atomic commit.
  * **Tier 3 (Task Gate):** Full workspace check (`fmt`, `clippy -D warnings`, `test`) before closing tasks.
  * **Tier 4 (Release Gate):** Cross-repo meta-harness E2E and wire schema validation.
* **Atomic Conventional Commits:** `<type>(<scope>): <summary>` (e.g. `feat(storypole-core): implement ledger writer`).
* **Semantic Versioning:** Workspace-synchronized versioning inheriting from `[workspace.package] version` and tagged `vX.Y.Z`.
