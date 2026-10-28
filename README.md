# `gaugeblock` — Precision Neurosymbolic Code Synthesis Suite

[![License: Apache-2.0](https://img.shields.io/badge/License-Apache--2.0-blue.svg)](LICENSE)
[![gaugeblock](https://img.shields.io/badge/suite-gaugeblock-orange.svg)](https://github.com/gaugeblock)
[![Documentation](https://img.shields.io/badge/docs-9--doc%20topology-green.svg)](ARCHITECTURE.md)
[![Rust 2024](https://img.shields.io/badge/Rust-2024%20Edition-orange.svg)](https://www.rust-lang.org)

> A deterministic, multi-repository meta-harness for AI-native systems engineering, AST slicing, semantic task management, and verified code synthesis.

---

## Ecosystem Architecture

The `gaugeblock` suite consists of 10 standalone, highly focused tools that connect deterministically via strict wire data contracts:

| Repository | Role | Core Responsibility |
|---|---|---|
| [`miter`](https://github.com/gaugeblock/miter) | AST & Verification | AST slicing, lexical scope indexing, secret redaction, and compiler error verification. |
| [`storypole`](https://github.com/gaugeblock/storypole) | Backlog & DAG | Git-native append-only ledger (`.storypole/`), task DAG, and MCP memory server. |
| [`sawhorse`](https://github.com/gaugeblock/sawhorse) | Model Runtime | 3-mode provider-agnostic inference engine (OpenAI-compat, Local GGUF, Candle). |
| [`chalkline`](https://github.com/gaugeblock/chalkline) | Spec Planner & 9-Docs | Interactive `/grill-me` specification planner, AST extractor, DAG compiler, and 9-doc architecture manager. |
| [`dado`](https://github.com/gaugeblock/dado) | Pattern Engine | Deterministic polyglot AST patterns, typed holes (`?[id: Type]`), structural mixins, and Tree-sitter splicing. |
| [`batten`](https://github.com/gaugeblock/batten) | Grammar & Guidance | Dynamic scope-to-Context-Free Grammar (GBNF/Lark/Regex) compiler and pre-flight validator. |
| [`joiner`](https://github.com/gaugeblock/joiner) | Code Synthesizer | Master neurosymbolic hole filler, iterative AST patcher, compiler repair loop, and telemetry spooler. |
| [`benchwork`](https://github.com/gaugeblock/benchwork) | Benchmark & UI | Local web CAD console (`benchwork up`), multi-repo store aggregator, and Benji AI engineer. |
| [`rabbet`](https://github.com/gaugeblock/rabbet) | Telemetry & Training | Public telemetry corpus hub, privacy scrubber, Parquet dataset compiler, and open-weight foundry. |
| [`outfeed`](https://github.com/gaugeblock/outfeed) | Packaging & Delivery | Neurosymbolic release gate, AST drift inspector, changelog synthesizer, and suite delivery orchestrator. |

---

## Why `gaugeblock`?

Modern LLM-driven coding tools rely on pure stochastic autoregression—forcing models to regurgitate hundreds of lines of boilerplate syntax, guess variable scopes, and hallucinate types across file boundaries.

`gaugeblock` inverts this paradigm through **neurosymbolic program synthesis**:

| Without `gaugeblock` | With `gaugeblock` |
|---|---|
| **Stochastic Autoregression:** LLM predicts every token of code, boilerplate, imports, and types from scratch—burning 85% of token budget and context on predictable structure. | **Deterministic AST Skeletons:** `miter` extracts live symbol scopes; `dado` provides structural AST patterns with typed holes (`?[id: Type]`); LLMs only fill constrained logic. |
| **Context Window Exhaustion:** Agents read 800-line files repeatedly with raw `cat` or `grep`, quickly hitting prompt saturation and degrading reasoning quality. | **Surgical AST Slicing:** `miter skeleton` and `miter lookup` return compact signatures and cross-file reference graphs in milliseconds with zero secret leakage. |
| **Grammar & Scope Hallucinations:** Models invent out-of-scope identifiers, call non-existent methods, or generate invalid syntax in 40%+ of complex edits. | **Scope-to-Grammar Compiling:** `batten` compiles active lexical variables into Context-Free Grammars (GBNF/Lark), physically constraining LLM generation to valid tokens. |
| **Silent Multi-File Contract Drift:** Types, database schemas, and API contracts diverge silently across Rust, TypeScript, and SQL definitions. | **Continuous Contract Enforcement:** `miter contracts` and `chalkline docs check` audit cross-language types, public contracts, and documentation drift before commits. |
| **Chaotic Agent Workflows:** Agents fix out-of-scope bugs inline, forget design invariants, and lose work across context window truncations. | **Git-Native Task DAG & Laws:** `storypole` maintains append-only task leases and zero-inline deferrals; `chalkline` resolves ambiguity via `/grill-me`. |


---

## Canonical 9-Document Architecture

Every repository across the `gaugeblock` meta-harness enforces an orthogonal, mutually exclusive separation of concerns across 9 essential markdown documents (managed and audited via `chalkline docs check`):

* **[`README.md`](./README.md):** Public elevator pitch, ecosystem architecture, installation, and quickstart.
* **[`CONTRIBUTING.md`](./CONTRIBUTING.md):** Human developer local workstation setup, toolchain requirements, and PR etiquette.
* **[`PRODUCT.md`](./PRODUCT.md):** User personas, problem statements, customer journeys, and success metrics.
* **[`ARCHITECTURE.md`](./ARCHITECTURE.md):** Multi-repository meta-harness topology, crate boundaries, and subsystem wiring.
* **[`SPEC.md`](./SPEC.md):** Formal behavioral invariants, state machines, and algebraic data type contracts.
* **[`DESIGN.md`](./DESIGN.md):** Architectural Decision Records (ADRs), trade-off analyses, and design explorations.
* **[`ROADMAP.md`](./ROADMAP.md):** Strategic horizons, milestone epics, and breaking change schedules.
* **[`CHANGELOG.md`](./CHANGELOG.md):** Chronological historical release logs (Keep a Changelog format) and unreleased entries.
* **[`AGENTS.md`](./AGENTS.md):** Non-negotiable engineering directives, file-size ceilings (<=250 LOC), and verification loops for autonomous systems.
* **[`CONTRACTS.md`](./CONTRACTS.md):** Cross-repository shared wire types, JSON schemas, and inter-tool trait boundaries.

---

## Installation & Dogfooding Workflow

The entire `gaugeblock` suite is designed to be built, installed, and dogfooded directly from `PATH` rather than executing ad-hoc build artifacts from repository `target/` directories.

### 1. Bootstrap Workspace Checkouts & Binaries

To bootstrap a developer workspace, clone all member repositories, compile seed binaries, and synchronize MCP configs:

```bash
# Clone all repositories and install full toolchain (SSH protocol)
./scripts/bootstrap.sh

# Or clone pinned to exact commits in suite.lock:
./scripts/bootstrap.sh --locked

# Or use HTTPS instead of SSH:
./scripts/bootstrap.sh --protocol https
```

### 2. Build and Install the Suite

The install script automatically installs chosen binaries to `~/.cargo/bin` and synchronizes active MCP endpoints to Antigravity's `mcp_config.json`:

```bash
# Full suite (all 10 tools, release build)
./scripts/install-suite.sh

# Install specific tools by name:
./scripts/install-suite.sh miter storypole dado

# Add --debug for faster inner-loop compilation:
./scripts/install-suite.sh --debug miter
```

Installed binaries:
`miter`, `storypole`, `sawhorse`, `chalkline`, `dado`, `batten`, `joiner`, `benchwork`, `rabbet`, `outfeed`.

### 2. Antigravity MCP Server Configuration

To empower AI coding agents with the suite's toolset, register the MCP stdio servers in Antigravity (`~/.gemini/antigravity/mcp_config.json` or `.agents/mcp_config.json`):

```json
{
  "mcpServers": {
    "miter": { "command": "miter", "args": ["mcp"] },
    "storypole": { "command": "storypole", "args": ["mcp"] },
    "chalkline": { "command": "chalkline", "args": ["mcp"] },
    "dado": { "command": "dado", "args": ["mcp"] },
    "batten": { "command": "batten", "args": ["mcp"] },
    "joiner": { "command": "joiner", "args": ["mcp"] },
    "benchwork": { "command": "benchwork", "args": ["mcp"] },
    "outfeed": { "command": "outfeed", "args": ["mcp"] }
  }
}
```

### 3. Asynchronous Defect Tracking with `storypole`

When executing any task, agents must never fix out-of-scope defects inline. Record unexpected bugs, edge cases, or missing AST patterns immediately into `storypole`:

```bash
storypole defer --kind bug --symbol "<crate::path>" --title "Unexpected parser panic on malformed macro"
```

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
