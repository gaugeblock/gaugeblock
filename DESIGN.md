# System — Architectural Design & Decisions

> Canonical Architectural Decision Records (ADRs) recorded for the `gaugeblock` suite and synchronized with `.gaugeblock/storypole/ledger.jsonl`.

---

## Architectural Decision Records (ADRs)

### ADR-001: Deterministic 9-Document Topology & Orthogonal Boundaries
- **Status:** Accepted (Resolved in `GB-18`)
- **Context:** Resolves documentation drift across human and LLM workflows by establishing rigid orthogonal boundaries.
- **Decision:** Enforce the canonical 9-Document Architecture Matrix (`README.md`, `CONTRIBUTING.md`, `PRODUCT.md`, `ARCHITECTURE.md`, `SPEC.md`, `DESIGN.md`, `ROADMAP.md`, `CHANGELOG.md`, `AGENTS.md`) with strict orthogonal separation of concerns to prevent scope confusion and documentation drift.
- **Consequences:** Every document has a single purpose. Human and LLM agents know precisely where each class of knowledge belongs without tangling.

### ADR-002: Declarative `.gaugeblock/docs.toml` Schema with Fallback Conventions
- **Status:** Accepted (Resolved in `GB-18`)
- **Context:** Multiple repositories require path mappings and AST/Git cross-check policies.
- **Decision:** Store path mappings and AST/Git cross-check rules in `.gaugeblock/docs.toml` with convention-over-configuration fallbacks (root `.md` then `docs/`) to support monorepos, custom layouts, and policy toggles.
- **Consequences:** Configurable doc validation without hardcoding paths.

### ADR-003: Layered Suite Responsibilities
- **Status:** Accepted (Resolved in `GB-18`)
- **Context:** How to cleanly partition scanning, verification, templates, and UI across suite tools.
- **Decision:** `miter-engine` extracts deterministic AST/Cargo/Clap/Toolchain/Git facts (`WorkspaceInventory`); `chalkline-core` owns `.gaugeblock/docs.toml`, the 9-doc templates, brownfield section classifier/disentangler (`DocMigrationPlan`), and drift verifier (`DocDriftReport`); `benchwork-core` + `web/` Panel 1 provide the visual studio, settings gear, and conversational doc chat over `chalkline-core`.
- **Consequences:** Clear single responsibility across crates; zero cyclic coupling.

### ADR-004: Section-Isolated `.gaugeblock/config.toml` Deserialization
- **Status:** Accepted (Resolved in `GB-36`)
- **Context:** How standalone repositories parse and deserialize configuration from a shared `.gaugeblock/config.toml`.
- **Decision:** Each tool deserializes only its own TOML table (`[storypole]`, `[miter]`, `[sawhorse]`, etc.) from `.gaugeblock/config.toml`, ignoring unknown keys to maintain zero-coupling and Unix standalone value.
- **Consequences:** Standalone CLI/MCP tools can read a consolidated config file without depending on a shared meta-crate.

### ADR-005: Unified Config Precedence
- **Status:** Accepted (Resolved in `GB-36`)
- **Context:** Handling coexistence of `.gaugeblock/` and legacy dotfiles (`.storypole/`, `sawhorse.toml`).
- **Decision:** `.gaugeblock/config.toml` and `.gaugeblock/<tool>/` take primary precedence; legacy repository-root dotfiles (`.storypole/`, `sawhorse.toml`) are retained as fallbacks for backwards compatibility.
- **Consequences:** Smooth migration path without breaking older scripts or workflows.

### ADR-006: 3-Tier Context Injection Strategy
- **Status:** Accepted (Resolved in `GB-46`)
- **Context:** How to provide rich suite awareness to the agent without blowing token budgets or context limits.
- **Decision:** Adopt 3-tier context injection:
  1. *Tier A (Pinned Session Identity):* Repo overview, 9-Doc boundaries, Mermaid guardrails, and `AGENTS.md` laws.
  2. *Tier B (Per-Turn `<gaugeblock_environment>` XML Envelope):* Deterministic ~250-token snapshot of active branch, viewport focus, Storypole task counts, docs drift status, and active model role.
  3. *Tier C (Explicit @-Mentions & /-Commands):* Deterministic Rust expansion of `@task:<KEY>`, `@doc:<NAME>`, `@symbol:<NAME>`, `@crate:<NAME>`, `/grill-me`, `/disentangle`, and `/plan <KEY>`.
- **Consequences:** High context precision with minimal token overhead and zero hallucination of workspace state.

### ADR-007: Automatic Read Execution vs. Staged Human-in-the-Loop Proposal Mutation
- **Status:** Accepted (Resolved in `GB-46`)
- **Context:** Tool execution safety boundaries and agent autonomy.
- **Decision:** Read-only suite tools (`miter_inspect_scope`, `storypole_query_tasks`, `chalkline_check_drift`, `dado_preview_contract`) execute automatically inside the Rust ReAct loop; state-mutating tools (`propose_decision_hole`, `propose_doc_patch`, `propose_task_plan`, `trigger_joiner_run`) emit staged `ToolProposal` payloads requiring explicit human approval in the UI.
- **Consequences:** Fast read-only analysis without friction, guaranteed human safety on file writes and ledger updates.

### ADR-008: Resilient Single-Model Tool Parsing & Serde Recovery
- **Status:** Accepted (Resolved in `GB-46`)
- **Context:** Handling differing LLM tool serialization quirks (e.g. stringified JSON, XML tags, escaped quotes).
- **Decision:** Support both native JSON tool calling and deterministic `<tool_call>` XML fallback, plus serde stringified-JSON recovery (`deserialize_maybe_stringified`) so Single-Model Mode and local GGUF models never fail on nested tool arguments.
- **Consequences:** Robust model compatibility across all inference backends (OpenAI, Anthropic, GGUF, Candle).

### ADR-009: Dual-Storage Chat Persistence & Telemetry Spool
- **Status:** Accepted (Resolved in `GB-46`)
- **Context:** How chat threads are persisted, indexed, and integrated with training telemetry.
- **Decision:** Dual Storage in `.gaugeblock/chat/`: Source of truth is `.gaugeblock/chat/threads.jsonl` (append-only `ChatLedgerEvent` stream); derived fast cache is `.gaugeblock/chat/index.sqlite` (git-ignored, indexing threads, entity associations, pending proposals, FTS5). When proposals are resolved: approved as-is emits Silver SFT trace to `.gaugeblock/spool/outbox.jsonl`; edited/rejected emits Gold DPO preference pair for `rabbet` (`planner_dpo.parquet`).
- **Consequences:** Git-friendly versioning of AI engineer conversations with automated telemetry spooling for model fine-tuning.

### ADR-010: Topological Packaging, crates.io Recovery & Delivery Suite
- **Status:** Accepted (Resolved in `GB-48`, `GB-52`)
- **Context:** Safe automated release gate, version bumping, and publishing across multi-repo workspaces.
- **Decision:** Implement `outfeed` as the standalone release gate. Automatically compute the intra-workspace crate DAG via topological sorting to guarantee dependent sub-crates (`*-core`, `*-mcp`) publish before parent binaries (`*-cli`, root facade). Gracefully catch crates.io 400 "already uploaded" responses without aborting workspace releases. Provide `outfeed install`, `push`, `publish`, and `release` CLI/MCP operations.
- **Consequences:** 100% automated, reliable release operations with zero manual ordering errors or version lockstep desynchronizations.
