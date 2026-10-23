# Changelog

All notable changes to the `gaugeblock` meta-harness and multi-repository workspace will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Added
* **Benchwork Conversational Engineer & Backlog Polish (GB-14 – GB-18):**
  - Interactive `/grill-me` chat UI integrated into Spec Studio (GB-14).
  - Backlog Kanban board, tabular issue lists, and task detail inspector drawer (GB-15).
  - Neurosymbolic X-ray realignment and backlog synthesis triggers (GB-16).
  - Interactive `sawhorse.toml` provider configuration manager (GB-17).
  - Configurable 9-document repository architecture manager and AST-grounded documentation generator (GB-18).
* **Workspace Test Runner (GB-13):**
  - Adopted `cargo-nextest` for parallel workspace test execution with process isolation and JUnit CI reporting.
  - Deployed `.config/nextest.toml` configuration across all 9 workspaces and root meta-harness.
  - Updated `AGENTS.md` and `CONTRIBUTING.md` tiered verification matrices.
  - Modernized CI workflows with `taiki-e/install-action@nextest` and `cargo test --doc --workspace`.
  - Added unified `scripts/test-suite.sh` test runner.

---

## [0.1.0-beta.1] - 2026-10-22

### Added
* **Phase 8: `gaugeblock/rabbet` — Telemetry Corpus Hub & Open-Weight Foundry (GB-7):**
  - `rabbet-core`: SQLite master store with WAL mode and Litestream continuous replication.
  - Reverse AST cold miner extracting synthetic `(Scope + TypedHole -> TargetExpression)` training pairs across open-source repositories using `miter` and `dado`.
  - Ingestion gate with double-checked SHA-256 verification and secret/PII scrubber preventing contaminated telemetry egress.
  - Arrow RecordBatch Parquet exporter generating `router_sft.parquet`, `hole_filler_sft.parquet`, and `hole_filler_dpo.parquet` dataset shards.
  - Recurring Gold trace pattern clustering engine to discover candidate deterministic `dado` patterns.
  - `rabbet-cli`: Public ingestion gate server (`rabbet serve`), token-authenticated Maintainer Admin Console (`/admin` and `/api/v1/admin/*`), and dataset management subcommands (`mine-oss`, `export-parquet`, `publish-hub`, `admin`).
* **Phase 7: `gaugeblock/benchwork` — Modular Visual Workbench UI (GB-6):**
  - `benchwork-core`: Workspace capability scanner detecting active artifacts (`SPEC.md`, `PRODUCT.md`, `.storypole`, `.dado`, `sawhorse.toml`, `.rabbet`), Spec Studio Markdown parser, DAG graph queries, neurosymbolic X-ray service, and telemetry hub service.
  - `benchwork-cli`: Axum REST/WebSocket/SSE aggregator daemon serving bundled frontend static assets via `rust-embed` (`benchwork up`).
  - `benchwork-mcp`: Stdio JSON-RPC 2.0 MCP server exposing `benchwork_capabilities`, `benchwork_snapshot`, `benchwork_resolve_decision`, and `benchwork_trigger_synthesis`.
  - `web`: Industrial CAD shell in Vite, React 19, TypeScript, and Tailwind with four reactive panels:
    - *Panel 1 (Spec & `/grill-me` Studio):* Interactive decision option cards with live `SPEC.md`/`PRODUCT.md` preview and polyglot contract generators.
    - *Panel 2 (Backlog & Live DAG Board):* SVG topological task graph visualizer, filtering bar, and agent claim/handoff inspector.
    - *Panel 3 (AST & Synthesis Inspector):* Visualization of `dado` templates, `batten` CFG rules, and streaming `joiner` token fills.
    - *Panel 4 (Model & Telemetry Hub):* 3-mode provider ping diagnostics and Rabbet DPO training telemetry trace inspector.
* **Phase 6: `gaugeblock/joiner` — Master Neurosymbolic Synthesis Orchestrator (GB-5):**
  - `joiner-core`: System 1 classification router mapping `(TaskNode + LexicalScope)` to deterministic `dado` patterns, AST surgical edits, or Oracle escalation.
  - Hole filler orchestrator executing `batten`-constrained token completions through `sawhorse` (`ModelRole::HoleFiller`).
  - Compiler verification loop passing exact `miter` diagnostics and compiler exit codes back into progressive retry loops.
  - Oracle fallback handler tagging novel code solutions for downstream `rabbet` pattern mining.
  - Local synthesis telemetry logger writing `AnonymizedSynthesisTrace` records (Bronze, Silver, Gold tiers).
  - `joiner-cli` & `joiner-mcp`: Subcommands `joiner run-next`, `joiner synthesize`, Axum daemon for `benchwork`, and stdio MCP server (`joiner_run_next`, `joiner_synthesize`).
* **Phase 5: `gaugeblock/batten` — Dynamic Scope-to-CFG Grammar Compiler (GB-4):**
  - `batten-core`: Two-tier normalized type matching, dynamic lexical scope filtering, unwraps/conversions, and safe widening fallbacks.
  - Depth-bounded GBNF grammar emitter for `llama.cpp` and `mistral.rs`.
  - EBNF Lark grammar emitter for `llguidance`, `outlines`, and `vLLM`.
  - Bounded PCRE regular expression emitter.
  - Zero-LLM pre-flight validator enforcing 100% identifier scope membership, delimiter balancing, and literal safety policies in microseconds.
  - `batten-cli` & `batten-mcp`: Subcommands `batten compile`, `batten validate`, `batten inspect`, and stdio MCP server (`batten_compile`, `batten_validate`).
* **Phase 4: `gaugeblock/dado` — Deterministic AST Pattern & Typed Hole Engine (GB-3):**
  - `dado-core`: `?[hole_id: ExpectedType]` template hole syntax parser and validator.
  - Embedded TOML pattern registry and structural mixin composer shipping 15 verified Rust + TypeScript AST patterns.
  - Tree-sitter zero-ERROR AST splicer performing deterministic hole substitution and `required_imports` injection.
  - Polyglot contract code generator producing aligned Rust structs and TypeScript interfaces from `chalkline` `SharedTypeContract` definitions.
  - `dado-cli` & `dado-mcp`: Subcommands `dado list`, `dado inspect`, `dado render`, `dado contract`, `dado verify-pack`, `dado init`, and stdio MCP server (`dado_list_patterns`, `dado_inspect_pattern`, `dado_render`, `dado_emit_contract`, `dado_verify_pack`).
* **Phase 3: `gaugeblock/chalkline` — Spec Planner, /grill-me & DAG Compiler (GB-2):**
  - `chalkline-core`: AST spec parser for `PRODUCT.md` and `DESIGN.md`.
  - Autonomous repository reconnaissance engine querying `miter-engine` to auto-resolve known error crates, async runtimes, and naming conventions.
  - Interactive `/grill-me` engine conducting structured architectural interviews through `sawhorse`.
  - Schema compiler emitting `SharedTypeContract` definitions for cross-language boundaries.
  - Topological DAG compiler generating verified `TaskNode` dependency graphs into `.storypole`.
  - `chalkline-cli` & `chalkline-mcp`: Interactive terminal wizard (`chalkline grill`), `chalkline compile-dag`, `chalkline sync`, `chalkline recon`, and stdio MCP server.
* **Phase 2: `gaugeblock/sawhorse` — Provider-Agnostic 3-Mode LLM Runtime (GB-1):**
  - `sawhorse-core`: Role-based model routing (`Planner`, `System1Router`, `HoleFiller`, `Oracle`) driven by `sawhorse.toml`.
  - Mode 1: Embedded native Rust `candle` weight loader for specialized micro-models.
  - Mode 2: Local GGUF subprocess/server inference adapter (`llama.cpp` and `mistral.rs`).
  - Mode 3: High-throughput OpenAI-compatible HTTP client (`jev`, `vLLM`, OpenRouter, cloud APIs) with grammar and schema pass-through.
  - `sawhorse-cli`: Diagnostic and execution subcommands `sawhorse ping`, `sawhorse bench`, `sawhorse complete`, and `sawhorse init`.
* **Suite Installation & Presets (GB-19):**
  - Created [`scripts/install-suite.sh`](scripts/install-suite.sh) supporting preset build profiles (`--profile all|core|minimal`, `--debug`).
  - Automated detection and synchronization of all 8 Model Context Protocol stdio servers into Antigravity `mcp_config.json`.
  - Hardened binary version probing for CLI tools lacking an explicit `--version` flag.
* **Automated Cross-Manifest Dependency Audit (GB-12):**
  - Created [`scripts/audit-deps.sh`](scripts/audit-deps.sh) to verify root `.cargo/config.toml` directives and assert zero dependency version drift across all 9 workspaces.

### Changed
* **Shared Target Directory Optimization (GB-9):**
  - Configured root `.cargo/config.toml` with `target-dir = "target"`, sharing build artifacts across all 9 member repositories and reclaiming ~20+ GB duplicate disk usage.
* **Compiler Caching via `sccache` (GB-9):**
  - Integrated `sccache` as `rustc-wrapper` and set `CARGO_INCREMENTAL = "0"` to maximize cache hit rates across clean builds and test runs.
* **Architecture & Linker Optimization (GB-9):**
  - Added `-C target-cpu=native` for host instruction acceleration (AVX2/FMA/BMI2 or NEON).
  - Configured macOS `split-debuginfo = "unpacked"` to eliminate slow `dsymutil` steps during debug compilation.
* **Cargo Compilation Profile Standardization (GB-10):**
  - Configured `[profile.dev.package."*"] opt-level = 2` across all manifests, compiling heavy third-party crates at optimized speed while maintaining instant crate recompilation.
  - Set `debug = 1` (line tables only) for dev and test profiles, slashing binary sizes and link times by >50%.
  - Added `lto = "thin"` and `codegen-units = 1` to release profiles.
* **Suite-Wide Third-Party Dependency Harmonization (GB-11):**
  - Upgraded `toml` to `1.1` (`1.1.8+spec-1.1.0`) across `miter`, `storypole`, `sawhorse`, `chalkline`, and `dado`.
  - Upgraded `redb` to `4.4` in `miter`.
  - Harmonized `rusqlite` with `features = ["bundled", "backup"]` between `storypole` and `rabbet`.
  - Harmonized `tokio` to `1.43`, `thiserror` to `2.0`, and `clap` to `4.5` across all member crates.
  - Audited and verified zero version discrepancies across all 43 third-party dependencies.
* **Tokio Feature Pruning & Dependency Slimming:**
  - Removed coarse `features = ["full"]` on `tokio` across all member crates.
  - Removed unused `tokio` dependencies from `chalkline-cli` and `joiner-mcp`.
  - Replaced CLI binary `tokio` dependencies with minimal subsets (`rt-multi-thread`, `macros`, `net`, `sync`, `time`), dropping dozens of transitive dependencies (`mio`, `socket2`, `signal`, `process`, `parking_lot`).
* **Agent Operational Directives (`AGENTS.md`):**
  - Mandated dogfooding globally installed binaries and registered MCP servers from `PATH`.
  - Prohibited direct execution from local `target/` directories.
  - Enforced zero inline scope creep via mandatory deferral into `storypole defer`.

### Verified
* Incremental check time: ~0.45 seconds (`cargo check -p storypole-core`).
* Dependency audit: `scripts/audit-deps.sh` passing with 0 defects across 43 third-party crates.

---

## [0.0.1-alpha.1] - 2026-10-21

### Added
* **Phase 0: Meta-Harness & Workspace Scaffolding:**
  - Multi-repository workspace layout uniting 9 standalone tools (`miter`, `storypole`, `sawhorse`, `chalkline`, `dado`, `batten`, `joiner`, `benchwork`, `rabbet`).
  - Core architectural contracts and directives:
    - `AGENTS.md`: Hard 250-line file limit, Unix standalone philosophy, zero inline scope creep, tiered verification matrix, and conventional commits specification.
    - `PRODUCT.md`: Neurosymbolic program synthesis architecture and dataflow specifications.
    - `CONTRACTS.md`: Shared wire format specifications and data contract schemas across tool boundaries.
    - `ROADMAP.md`: Master 9-phase dependency graph and milestone exit criteria.
  - Automated namespace reservation tooling ([`scripts/reserve-namespaces.sh`](scripts/reserve-namespaces.sh)) securing 24 crate names across 8 repository families on crates.io at `v0.0.1-alpha.1`.
  - Pure bash topological workspace publishing pipeline ([`scripts/publish-workspace.sh`](scripts/publish-workspace.sh)).
  - Local multi-repo development mapping via `[patch.crates-io]` in root `.cargo/config.toml`.
  - Multi-root VS Code workspace configuration (`gaugeblock.code-workspace`).
* **Phase 1: `gaugeblock/storypole` — Backlog, Task DAG & MCP Memory Store:**
  - `storypole-core`:
    - Git-native append-only JSONL ledger (`.storypole/ledger.jsonl`) with merge conflict resilience.
    - Ephemeral SQLite index (`.storypole/index.sqlite`) with automatic event stream synchronization.
    - Topological task DAG engine with cycle detection on `BlockedBy` and `ParentEpic` edges.
    - Chained decision lifecycle (`Pending`, `Resolved`, `Superseded`).
    - Agent continuity protocol with TTL leases, heartbeats, and structured handoff packets.
    - Zero-interruption issue deferral (`storypole defer`) executing in <5ms.
  - `storypole-mcp`: Stdio JSON-RPC 2.0 Model Context Protocol server exposing 14 tools for AI agent orchestration.
  - `storypole-cli`: Command-line interface with formatted tables, DAG trees, and `--json` egress.
* **Pre-Existing Foundation: `gaugeblock/miter` (v0.1.0-alpha.1 / v0.1.0-alpha.2):**
  - Polyglot AST indexing and symbol cross-reference engine backed by `redb`.
  - Surgical AST navigation (`miter lookup`, `miter skeleton`, `miter references`).
  - Structural analysis suite (`miter audit`, `miter slice`, `miter impact`, `miter contracts`, `miter clones`).
  - Subprocess compiler verification gate (`miter verify`).
  - AST-aware secret and identifier redaction for MCP egress.
  - Stdio JSON-RPC 2.0 MCP server with automated dirty-file refreshing.
