# ROADMAP.md — `gaugeblock` 9-Repository Master Build Plan

> **Strategy:** Each phase unlocks a dogfooding capability used to accelerate the next phase.  
> **Rule:** Every source file across every phase must remain strictly **under 250 lines**.

### Suite Implementation Status

| Phase | Repository | Capability | Status | Ticket | Version / Release |
| :---: | :--- | :--- | :---: | :---: | :---: |
| **0** | `gaugeblock` (meta-harness) | Multi-repo orchestration & contracts | **DONE** | — | `v0.0.1-alpha.1` |
| **1** | `gaugeblock/storypole` | Git-native backlog, task DAG & memory | **DONE** | Bootstrap | `v0.1.0-beta.1` |
| **2** | `gaugeblock/sawhorse` | 3-mode provider-agnostic LLM runtime | **DONE** | `GB-1` | `v0.1.0-beta.1` |
| **3** | `gaugeblock/chalkline` | Spec planner, `/grill-me` & DAG compiler | **DONE** | `GB-2` | `v0.1.0-beta.1` |
| **4** | `gaugeblock/dado` | Deterministic AST patterns & typed holes | **DONE** | `GB-3` | `v0.1.0-beta.1` |
| **5** | `gaugeblock/batten` | Dynamic scope-to-CFG grammar compiler | **DONE** | `GB-4` | `v0.1.0-beta.1` |
| **6** | `gaugeblock/joiner` | Master neurosymbolic synthesis engine | **DONE** | `GB-5` | `v0.1.0-beta.1` |
| **7** | `gaugeblock/benchwork` | Modular visual workbench UI & local daemon | **DONE** | `GB-6` | `v0.1.0-beta.1` |
| **8** | `gaugeblock/rabbet` | Telemetry corpus hub & open-weight foundry | **DONE** | `GB-7` | `v0.1.0-beta.1` |

---

## Phase 0: Meta-Harness & Namespace Foundation (`DONE`)
* **Target:** Root `neurosymbolic-suite/` workspace + `gaugeblock` GitHub org + `crates.io` (`0.0.1-alpha.1` reservations) + `gaugeblock.dev`.
* **Deliverables:**
  - [x] Verify and reserve all 9 repository families under `gaugeblock` (`miter`, `storypole`, `sawhorse`, `chalkline`, `dado`, `batten`, `joiner`, `benchwork`, `rabbet`).
  - [x] Publish `AGENTS.md`, `PRODUCT.md`, `CONTRACTS.md`, and `ROADMAP.md` in the root harness.
  - [x] Add root `.cargo/config.toml` with `[patch.crates-io]` mappings for local sibling checkouts.

---

## Phase 1: `gaugeblock/storypole` — Git-Native Backlog, Task DAG & MCP Memory Store (`DONE`)
* **Dependencies:** None (Pure Rust + `rusqlite` + `serde_json` + `clap`).
* **Why First:** Once `storypole` is built, your AI coding agents immediately use `storypole` via CLI and MCP to track tasks, dependencies, and deferred tech debt for Phases 2 through 8.
* **Sub-Crates & Modules (<250 LOC each):**
  - `storypole-core`:
    - [x] `model.rs`: `TaskNode`, `TaskStatus`, `TaskKind`, `LedgerEvent` (from `CONTRACTS.md`).
    - [x] `ledger.rs`: Append-only `.storypole/ledger.jsonl` reader/writer with deterministic git-merge conflict resilience.
    - [x] `index.rs`: Ephemeral `.storypole/index.sqlite` builder and sync engine.
    - [x] `dag.rs`: Topological sort, cycle detection, and `next_ready_tasks()` query engine.
  - `storypole-mcp`:
    - [x] `server.rs`: JSON-RPC 2.0 stdio MCP server exposing `storypole_next`, `storypole_defer`, `storypole_update_status`, and `storypole_add_task`.
  - `storypole-cli`:
    - [x] `main.rs` & `commands.rs`: `storypole init`, `add`, `next`, `defer`, `graph`, `serve` (HTTP/WS daemon for `benchwork`), and `mcp`.
* **Exit Criteria:** `storypole` initializes `.storypole/` in the meta-harness, imports Phases 2–8 as DAG nodes, and serves tasks over MCP. (`VERIFIED`)

---

## Phase 2: `gaugeblock/sawhorse` — Provider-Agnostic 3-Mode LLM Runtime (`DONE`)
* **Dependencies:** None (Standalone Rust runtime).
* **Why Second:** Gives `chalkline` (Phase 3) and `joiner` (Phase 6) immediate, unified access to local, in-house, and OpenAI-compatible (`jev`/`vLLM`/cloud) models.
* **Sub-Crates & Modules (<250 LOC each):**
  - `sawhorse-core`:
    - [x] `config.rs`: Role-based routing table (`Planner`, `System1Router`, `HoleFiller`, `Oracle`) loaded from `sawhorse.toml`.
    - [x] `traits.rs`: `ModelProvider` async trait + `InferenceRequest` / `InferenceResponse`.
    - [x] `providers/openai_compat.rs`: Mode 3 HTTP client supporting `jev`, `vLLM`, OpenRouter, and standard OpenAI endpoints (including grammar/schema pass-through).
    - [x] `providers/local_gguf.rs`: Mode 2 local inference adapter (`llama.cpp` / `mistral.rs` server or subprocess).
    - [x] `providers/candle_native.rs`: Mode 1 native Rust `candle` weight loader for specialized `gaugeblock` micro-models.
  - `sawhorse-cli`:
    - [x] `main.rs`: `sawhorse ping`, `sawhorse bench`, `sawhorse complete --role hole_filler --grammar <file>`, `sawhorse init`.
* **Exit Criteria:** Can execute a single prompt across Mode 3 (OpenAI/Jev) and Mode 2 (Local) through the exact same Rust trait call. (`VERIFIED`)

---

## Phase 3: `gaugeblock/chalkline` — `/grill-me` Spec Planner & DAG Compiler (`DONE`)
* **Dependencies:** `miter-engine`, `storypole-core`, `sawhorse-core`.
* **Why Third:** Unlocks interactive spec generation and automatic `storypole` task DAG population for the remaining repositories.
* **Sub-Crates & Modules (<250 LOC each):**
  - `chalkline-core`:
    - [x] `spec_parser.rs`: Parses and updates `PRODUCT.md` and `DESIGN.md` AST sections.
    - [x] `recon.rs`: Queries `miter-engine` on the target repo to auto-resolve known conventions (error crates, async runtime, naming) without bothering the human.
    - [x] `griller.rs`: Identifies true `DecisionHole` ambiguities and conducts the structured `/grill-me` Q&A loop via `sawhorse`.
    - [x] `contracts_gen.rs`: Locks `SharedTypeContract` schemas for cross-language boundaries.
    - [x] `dag_compiler.rs`: Compiles approved specs into `TaskNode` graphs and writes them directly to `storypole`.
  - `chalkline-cli` & `chalkline-mcp`:
    - [x] `chalkline grill`, `chalkline compile-dag`, `chalkline sync`, `chalkline recon`, `chalkline mcp`.
* **Exit Criteria:** Running `chalkline grill` on a feature prompt updates `DESIGN.md` and emits a verified topological task DAG into `storypole`. (`VERIFIED`)

---

## Phase 4: `gaugeblock/dado` — Deterministic AST Pattern & Typed Hole Engine (`DONE`)
* **Dependencies:** `miter-engine`.
* **Sub-Crates & Modules (<250 LOC each):**
  - `dado-core`:
    - [x] `hole.rs`: Parser and validator for `?[hole_id: ExpectedType]` markers inside templates.
    - [x] `pattern.rs` / `registry`: `DadoPattern` registry, embedded TOML loader, and structural mixin composer.
    - [x] `splice.rs`: Deterministic AST splicer that substitutes filled hole expressions and injects `required_imports` using Tree-sitter zero-ERROR nodes.
    - [x] `polyglot.rs`: Deterministic Rust <-> TypeScript contract codegen from `chalkline`'s `SharedTypeContract`.
  - `dado-mcp`:
    - [x] `server.rs`: JSON-RPC 2.0 stdio server exposing `dado_list_patterns`, `dado_inspect_pattern`, `dado_render`, `dado_emit_contract`, and `dado_verify_pack`.
  - `dado-cli`:
    - [x] `main.rs` & `handlers.rs`: `dado list`, `dado inspect`, `dado render`, `dado contract`, `dado verify-pack`, `dado init`, `dado mcp`.
* **Exit Criteria:** Ships with a core pack of 15 verified Rust + TypeScript patterns; `dado render` deterministically emits compilable ASTs when provided hole values. (`VERIFIED`)

---

## Phase 5: `gaugeblock/batten` — Dynamic Scope-to-CFG Grammar Compiler (`DONE`)
* **Dependencies:** `miter-engine`, `dado-core` (optional `llguidance` integration).
* **Sub-Crates & Modules (<250 LOC each):**
  - `batten-core`:
    - [x] `type_norm.rs` & `scope_filter.rs`: Two-tier normalized type matching, unwraps/conversions, and safe fallback widening.
    - [x] `grammar/gbnf.rs`: Depth-bounded GBNF grammar emitter for llama.cpp and mistral.rs.
    - [x] `grammar/lark.rs`: EBNF Lark emitter for llguidance, outlines, and vLLM.
    - [x] `grammar/regex.rs`: Bounded PCRE regular expression emitter.
    - [x] `validator/`: Microsecond-fast zero-LLM validator checking 100% identifier membership, delimiter balancing, and literal policies.
  - `batten-cli`:
    - [x] `batten compile --scope scope.json --hole hole.json --format <gbnf|lark|regex>`.
    - [x] `batten validate --constraint constraint.json --candidate "<expr>"`.
    - [x] `batten inspect --scope scope.json --hole hole.json`.
    - [x] `batten mcp`: Stdio JSON-RPC 2.0 Model Context Protocol server.
  - `batten-mcp`:
    - [x] Standalone MCP server exposing `batten_compile` and `batten_validate`.
* **Exit Criteria:** Given a sample `miter` scope and a `Result<User, AppError>` hole, `batten` emits a GBNF grammar that permits only in-scope identifiers and valid Rust expression syntax. (`VERIFIED`)

---

## Phase 6: `gaugeblock/joiner` — Master Neurosymbolic Synthesis Orchestrator (`DONE`)
* **Dependencies:** `miter-engine`, `storypole-core`, `sawhorse-core`, `chalkline-core`, `dado-core`, `batten-core`.
* **Sub-Crates & Modules (<250 LOC each):**
  - `joiner-core`:
    - [x] `router.rs`: System 1 classifier that maps `(TaskNode + LexicalScope)` to either a `DadoPattern`, an AST Surgical Edit, or Oracle escalation.
    - [x] `filler.rs`: Iterates over each `TypedHole` in a `DadoPattern`, compiles its grammar via `batten`, and calls `sawhorse` (`ModelRole::HoleFiller`).
    - [x] `verifier.rs`: Calls `miter` to splice the result and run `cargo check` / `tsc` / unit tests; feeds exact compiler diagnostics back on retry.
    - [x] `oracle.rs`: Escalation handler when no `dado` pattern matches; tags novel solutions as candidates for `rabbet` pattern extraction.
    - [x] `telemetry.rs`: AST-anonymizes verified runs via `miter` and writes local `AnonymizedSynthesisTrace` records (Bronze/Silver/Gold).
  - `joiner-cli` & `joiner-mcp`:
    - [x] `joiner run-next` (pulls from `storypole`), `joiner synthesize <task_id>`, `joiner daemon` (HTTP/WS API for `benchwork`).
    - [x] `joiner mcp`: Stdio JSON-RPC 2.0 Model Context Protocol server exposing `joiner_run_next` and `joiner_synthesize`.
* **Exit Criteria:** `joiner run-next` pulls a ready Rust task from `storypole`, selects a `dado` pattern, fills its holes using a `batten`-constrained model via `sawhorse`, verifies compilation via `miter`, and marks the task `Verified` in `storypole`. (`VERIFIED`)

---

## Phase 7: `gaugeblock/benchwork` — Modular Visual Workbench UI (`DONE`)
* **Dependencies:** Connects directly via Rust library linkage and over HTTP/WebSocket to `storypole`, `chalkline`, `joiner`, `dado`, `batten`, and `sawhorse` (with a lightweight Axum local daemon `benchwork-cli` and stdio `benchwork-mcp`).
* **Architecture (<250 LOC per component/module):**
  - `benchwork-core`:
    - [x] `capabilities.rs`: Scans workspace for `SPEC.md`, `PRODUCT.md`, `.storypole`, `.dado`, `sawhorse.toml`, and `.rabbet` spool.
    - [x] `spec_studio.rs`: `SPEC.md` and Markdown parser, `chalkline` decision resolver, and polyglot contract preview.
    - [x] `dag_service.rs`: Storypole task graph queries, topological sorting, bottleneck detection, agent claims & handoffs.
    - [x] `xray_service.rs`: Dado pattern definitions, Batten grammar compilation, and in-process/daemon Joiner synthesis triggers.
    - [x] `hub_service.rs`: Sawhorse 3-mode provider status, health pings, and Rabbet DPO telemetry trace inspector.
  - `benchwork-cli` & `benchwork-mcp`:
    - [x] `benchwork-cli` (Rust): Single binary (`benchwork up`) that serves the static frontend bundle (`rust-embed`), WebSocket/SSE streams, and REST API.
    - [x] `benchwork-mcp`: Stdio JSON-RPC 2.0 Model Context Protocol server exposing `benchwork_capabilities`, `benchwork_snapshot`, `benchwork_resolve_decision`, and `benchwork_trigger_synthesis`.
  - `web/` (Vite + React 19 + TypeScript + Tailwind):
    - [x] **Plugin Shell:** Automatically detects which `gaugeblock` backends are active and enables corresponding panels (works standalone with just `SPEC.md` or `storypole`!).
    - [x] **Panel 1 — Spec & `/grill-me` Studio (`chalkline`):** Interactive option cards for resolving `DecisionHole` items alongside live `SPEC.md`/`PRODUCT.md` preview and polyglot contract generator preview.
    - [x] **Panel 2 — Backlog & Live DAG Board (`storypole`):** Topological task graph CAD SVG visualizer + multi-filter bar + agent claim/handoff briefing drawer.
    - [x] **Panel 3 — AST & Synthesis Inspector (`dado` + `batten` + `joiner`):** Visualizes Dado patterns and typed holes, Batten CFG rules, and live Joiner synthesis token fills.
    - [x] **Panel 4 — Model & Telemetry Hub (`sawhorse` + `rabbet`):** Configure 3-mode model slots, run ping diagnostics, and inspect/purge Rabbet DPO training telemetry outbox traces.
* **Exit Criteria:** `benchwork up` launches the web UI, renders the live `storypole` DAG, and lets the user step through a `chalkline` `/grill-me` session and watch a `joiner` synthesis trace in real time. (`VERIFIED`)

---

## Phase 8: `gaugeblock/rabbet` — Public Telemetry Corpus Hub & Open-Weight Foundry (`DONE`)
* **Dependencies:** `miter-engine`, `dado-core`.
* **Sub-Crates & Modules (<250 LOC each):**
  - `rabbet-core`:
    - [x] `cold_miner.rs`: Runs `miter` + `dado` in reverse across public Apache/MIT repositories to extract millions of synthetic `(Scope + TypedHole -> TargetExpression)` training pairs before any user telemetry exists.
    - [x] `gate/scrubber.rs` & `gate/validator.rs`: Double-checks that all contributed `AnonymizedSynthesisTrace` records contain zero PII, secrets, or proprietary literals, and validates SHA-256 content hashes.
    - [x] `parquet/exporter.rs`: Compiles Arrow RecordBatches into `router_sft.parquet`, `hole_filler_sft.parquet`, and `hole_filler_dpo.parquet` shards.
    - [x] `miner/pattern_miner.rs`: Clusters recurring Gold Oracle fallbacks to propose new deterministic `dado` patterns.
    - [x] `db/store.rs` & `db/litestream.rs`: SQLite master store with WAL mode and continuous Litestream replication.
  - `rabbet-cli`:
    - [x] `rabbet serve --port <port> --admin-token <token>`: Public Ingestion Gate + Token-protected Maintainer Admin Console (`/admin` + `/api/v1/admin/*`).
    - [x] `rabbet mine-oss <repo_path>`, `rabbet export-parquet`, `rabbet publish-hub`, `rabbet admin <stats|compact|candidates|approve>`.
* **Exit Criteria:** Generates the initial cold-start Rust training dataset in Parquet format from open-source crates, compiles DPO preference pairs from Gold traces, and establishes the Maintainer Admin Control Plane with Litestream continuous replication. (`VERIFIED`)