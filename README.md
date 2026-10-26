# `gaugeblock` — Precision Neurosymbolic Code Synthesis Suite

> A deterministic, multi-repository meta-harness for AI-native systems engineering, AST slicing, semantic task management, and verified code synthesis.

---

## Ecosystem Architecture

The `gaugeblock` suite consists of 10 standalone, highly focused tools that connect deterministically via strict wire data contracts:

| Repository | Role | Core Responsibility |
|---|---|---|
| [`miter`](https://github.com/gaugeblock/miter) | AST & Verification | AST slicing, lexical scope indexing, and compiler error verification. |
| [`storypole`](https://github.com/gaugeblock/storypole) | Backlog & DAG | Git-native append-only ledger (`.storypole/`), task DAG, and MCP memory server. |
| [`sawhorse`](https://github.com/gaugeblock/sawhorse) | Model Runtime | 3-mode provider-agnostic inference engine (OpenAI-compat, Local GGUF, Candle). |
| [`chalkline`](https://github.com/gaugeblock/chalkline) | Spec Planner | Interactive `/grill-me` specification planner, AST extractor, and DAG compiler. |
| [`dado`](https://github.com/gaugeblock/dado) | Context Slicer | AST context window optimization and minimal symbol slice assembly. |
| [`batten`](https://github.com/gaugeblock/batten) | Grammar & Guidance | Context-free grammar (CFG) constrained decoding engine. |
| [`joiner`](https://github.com/joiner) | Code Synthesizer | Neurosymbolic hole filler, iterative AST patcher, and compiler verifier. |
| [`benchwork`](https://github.com/gaugeblock/benchwork) | Benchmark & UI | Local web console, SWE-bench evaluation harness, and execution recorder. |
| [`rabbet`](https://github.com/gaugeblock/rabbet) | Telemetry & Training | DPO/RL trace collector, privacy scrubber, and dataset compiler. |
| [`outfeed`](https://github.com/gaugeblock/outfeed) | Packaging & Delivery | Neurosymbolic release gate, AST drift inspector, changelog synthesizer, and release orchestrator. |

---

## Core Documentation

* **[`AGENTS.md`](./AGENTS.md):** Non-negotiable engineering laws, workspace conventions, and agent execution loop.
* **[`CONTRACTS.md`](./CONTRACTS.md):** Shared wire types, JSON schemas, and inter-repository trait boundaries.
* **[`ROADMAP.md`](./ROADMAP.md):** Master 9-phase bootstrap and implementation roadmap.
* **[`CONTRIBUTING.md`](./CONTRIBUTING.md):** Conventional commits, atomic commits, tiered verification matrix, and semantic versioning.
* **[`PRODUCT.md`](./PRODUCT.md):** Product requirements, user stories, and design invariants.

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
