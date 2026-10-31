# CONTRACTS.md — Shared Types, JSON Schemas & Trait Boundaries

> **Rule:** Every struct and trait below defines an immutable wire contract between the 10 `gaugeblock` repositories. All wire types MUST derive `serde::Serialize`, `serde::Deserialize`, `Debug`, `Clone`, and `PartialEq`.

> **Foundation crates (not member contracts):** `gaugeblock-contracts` holds every wire type on this
> page. Two further crates in `common/` will hold *behaviour* rather than data, and their boundary is
> frozen in [`common/ARCHITECTURE.md` §4](./common/ARCHITECTURE.md): `gaugeblock-git` owns every git and
> worktree operation (`GB-131`), `gaugeblock-workspace` owns canonical `.gaugeblock/` paths, member
> topology and suite config and may depend on `gaugeblock-git` but never the reverse (`GB-189`). No
> member may add a private path or git helper once those exist.

---

## 1. `miter` Contracts (AST Slicing, Lexical Scope & Verification)

Exported by `miter-engine` and consumed by `chalkline`, `dado`, `batten`, `joiner`, and `rabbet`.

### Note on `Language` and `SymbolKind`

`miter`'s `Language` and `SymbolKind` are **internal AST taxonomies**, not wire types: they carry no
`serde` derives, and `SymbolKind` names 15 polyglot declaration kinds (`Module`, `Struct`, `Enum`,
`Trait`, `Class`, `Interface`, `TypeAlias`, `Function`, `Method`, `Property`, `Table`,
`InfraResource`, `DockerStage`, `K8sManifest`, `Heading`). The shapes below are the *wire* view seen by
cross-language consumers; a boundary converts between the two.

```rust
use serde::{Deserialize, Serialize};

/// A source language or declarative format the suite reads.
///
/// Mirrors `miter`'s implemented taxonomy: a language is listed only when an extractor exists.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize)]
#[serde(rename_all = "lowercase")]
pub enum Language {
    Rust,
    TypeScript,
    Tsx,
    JavaScript,
    Python,
    Sql,
    Html,
    Css,
    Markdown,
    Dockerfile,
    Yaml,
    Hcl,
    Env,
}

// Wire spelling: the lowercase `name()` form (`"rust"`, `"typescript"`, `"dockerfile"`).
// Deserialization is case-insensitive and also accepts `rs`, `ts`, `js`, `py`, `md`, `yaml`/`yml`,
// `hcl`/`terraform`, `css`/`scss` and `dockerfile`/`docker`.

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct SymbolBinding {
    pub name: String,
    pub ty: String,
    pub is_mutable: bool,
    pub kind: SymbolKind,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum SymbolKind {
    LocalVar,
    Parameter,
    Function,
    TypeOrStruct,
    TraitOrInterface,
    Constant,
}

/// Extracted by `miter` at a specific byte/line offset to feed `dado` and `batten`.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct LexicalScope {
    pub repo_relative_path: String,
    pub language: Language,
    pub enclosing_symbol: Option<String>,
    pub bindings: Vec<SymbolBinding>,
    pub available_imports: Vec<String>,
}

/// Returned by `miter` after validating a synthesized AST splice or running compiler checks.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct VerificationReport {
    pub ast_valid: bool,
    pub typecheck_passed: bool,
    pub tests_passed: Option<bool>,
    pub diagnostics: Vec<CompilerDiagnostic>,
    pub duration_ms: u64,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct CompilerDiagnostic {
    pub file: String,
    pub line: usize,
    pub column: usize,
    pub code: Option<String>,
    pub message: String,
    pub suggestion: Option<String>,
}
```

---

## 2. `storypole` Contracts (Backlog, Task DAG, Decisions & Agent Continuity)

Exported by `storypole-core` and persisted in `.gaugeblock/storypole/` (or legacy `.storypole/` fallback): `.gaugeblock/config.toml` (repo config `[storypole]`), `ledger.jsonl` (git-tracked append-only event log), and `index.sqlite` (ephemeral derived relational index). Consumed by `chalkline`, `joiner`, `benchwork`, and external MCP agents.

```rust
use serde::{Deserialize, Serialize};
use uuid::Uuid;

/// Per-repository or meta-harness configuration loaded from `.gaugeblock/config.toml` [storypole] or legacy `.storypole/config.toml`.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct StorypoleConfig {
    /// Human-readable ticket prefix (e.g., "GB", "SP", "MTR"). Generates IDs like `SP-14`.
    pub ticket_prefix: String,
    /// Optional allow-list of valid repository names (enforced when non-empty).
    pub allowed_repos: Vec<String>,
    /// Optional allow-list of valid crate/package names (enforced when non-empty).
    pub allowed_crates: Vec<String>,
    /// Default lease time-to-live in minutes before an `InProgress` agent claim expires.
    pub claim_ttl_minutes: u32,
    /// Optional map of `(crate_or_repo_name, verification_command)`.
    pub verification_commands: Vec<(String, String)>,
}

/// Configuration defining multi-repository workspace membership.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize, Default)]
pub struct WorkspaceConfig {
    /// List of member repository paths or names (e.g. `["benchwork", "miter"]`).
    pub members: Vec<String>,
    /// Default ticket prefix for workspace-level / cross-cutting tasks.
    pub default_prefix: Option<String>,
}

/// A member repository discovered within a workspace.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct DiscoveredMember {
    pub name: String,
    pub repo_path: std::path::PathBuf,
    pub dot_dir: Option<std::path::PathBuf>,
    pub ticket_prefix: Option<String>,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum TaskKind {
    Epic,
    Feature,
    Refactor,
    Bug,
    TechDebt,
    Spike,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum TaskStatus {
    /// Captured via `storypole defer`; awaits human or `chalkline` triage before entering `Ready`.
    Triage,
    /// Blocked by unverified `blocked_by` tasks or unresolved `Pending` decisions.
    Blocked,
    /// All hard dependencies verified and zero pending decisions; eligible for `storypole next`.
    Ready,
    /// Actively claimed by an agent or human under an active lease.
    InProgress,
    /// Active AST pattern/hole synthesis in progress via `joiner`.
    Synthesizing,
    /// Running compiler / test verification via `miter`.
    Verifying,
    /// Passed verification with a recorded `VerificationReceipt`.
    Verified,
    /// Intentionally parked for future milestones.
    Deferred,
    /// Completed and archived out of active backlog views.
    Archived,
    /// Exhausted retry budget or failed verification; requires handoff inspection or split.
    Failed,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum EdgeKind {
    /// Hard topological execution lock: target cannot enter `Ready` until source is `Verified`.
    BlockedBy,
    /// Soft bi-directional link: surfaces sibling summary & decisions in context briefings.
    RelatedTo,
    /// Provenance link: created automatically when an agent defers an issue during an active task.
    DiscoveredFrom,
    /// Hierarchical grouping under a parent Epic or split task.
    ParentEpic,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct TaskEdge {
    pub kind: EdgeKind,
    pub target_id: Uuid,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub target_ticket_key: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub target_repo: Option<String>,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum DecisionStatus {
    Pending,
    Resolved,
    Superseded,
}

/// A decision node attached to a task, supporting chained follow-up decisions and reversal.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct TaskDecision {
    pub decision_id: Uuid,
    pub parent_decision_id: Option<Uuid>,
    pub status: DecisionStatus,
    pub category: String,
    pub question: String,
    pub proposed_options: Vec<String>,
    pub chosen_option: Option<String>,
    pub rationale: Option<String>,
    pub resolved_by: Option<String>,
    pub updated_at_epoch_ms: u64,
}

/// Structured continuity checkpoint recorded when an agent pauses, yields, or fails mid-task.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct HandoffPacket {
    pub recorded_by_agent: String,
    pub timestamp_ms: u64,
    pub completed_items: Vec<String>,
    pub remaining_items: Vec<String>,
    pub last_error_or_blocker: Option<String>,
    pub git_ref: Option<String>,
    pub dirty_files: Vec<String>,
}

/// Active agent claim lock with lease expiration to prevent parallel agent collisions.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct AgentClaim {
    pub agent_id: String,
    pub claimed_at_epoch_ms: u64,
    pub lease_expires_at_epoch_ms: u64,
    pub git_branch: Option<String>,
    pub base_commit_sha: Option<String>,
}

/// Execution step within an attached TaskPlan.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct PlanStep {
    pub step_id: String,
    pub title: String,
    pub target_files: Vec<String>,
    pub verification_gate: Option<String>,
    pub completed: bool,
}

/// Attached architectural plan and execution blueprint.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct TaskPlan {
    pub summary: String,
    pub design_markdown: String,
    pub steps: Vec<PlanStep>,
    pub plan_file_path: Option<String>,
    pub updated_at_epoch_ms: u64,
}

/// Evidence required to transition a task into `TaskStatus::Verified`.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct VerificationReceipt {
    pub verifier: String,
    pub command: String,
    pub exit_code: Option<i32>,
    pub diagnostic_count: Option<u32>,
    pub summary: String,
    pub verified_at_epoch_ms: u64,
    pub git_branch: Option<String>,
    pub base_commit_sha: Option<String>,
    pub head_commit_sha: Option<String>,
    pub commit_shas: Vec<String>,
}

/// Multi-dimensional scope coordinates for filtering across repos, crates, and AST symbols.
#[derive(Debug, Clone, Default, PartialEq, Eq, Serialize, Deserialize)]
pub struct TaskScope {
    pub repo: Option<String>,
    pub crate_name: Option<String>,
    pub module_path: Option<String>,
    pub target_files: Vec<String>,
    pub target_symbols: Vec<String>,
    pub labels: Vec<String>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct TaskNode {
    pub id: Uuid,
    /// Human-friendly sequential key (e.g., `SP-14`, `GB-3`).
    pub ticket_key: String,
    pub slug: String,
    pub title: String,
    pub description: String,
    pub kind: TaskKind,
    pub status: TaskStatus,
    pub priority: u8, // 1 (highest) to 5 (lowest)
    pub scope: TaskScope,
    pub edges: Vec<TaskEdge>,
    pub decisions: Vec<TaskDecision>,
    pub acceptance_criteria: Vec<String>,
    pub plan: Option<TaskPlan>,
    pub active_claim: Option<AgentClaim>,
    pub latest_handoff: Option<HandoffPacket>,
    pub verification_receipt: Option<VerificationReceipt>,
    pub created_at_epoch_ms: u64,
    pub updated_at_epoch_ms: u64,
}

/// Assembled context payload returned by `storypole next` / `storypole claim` / MCP tools.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct TaskContextBriefing {
    pub task: TaskNode,
    pub verification_command: Option<String>,
    /// `(ticket_key, title, status)` for every task linked by `RelatedTo`, `BlockedBy` or
    /// `ParentEpic` in **either** direction. Outgoing edges cover dependencies and the parent
    /// epic; the inbound pass surfaces an epic's children, dependents blocked by this task, and
    /// siblings that recorded the link on their own side. Mutual links appear once.
    pub related_tasks_summary: Vec<(String, String, TaskStatus)>,
    pub inherited_decisions: Vec<TaskDecision>,
    pub file_collision_warnings: Vec<String>,
    pub known_deferred_issues_in_scope: Vec<(String, String)>,
}

/// Immutable append-only event written to `.storypole/ledger.jsonl`.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[serde(tag = "event", rename_all = "snake_case")]
pub enum LedgerEvent {
    TaskCreated {
        task: TaskNode,
    },
    TaskUpdated {
        task_id: Uuid,
        title: Option<String>,
        description: Option<String>,
        priority: Option<u8>,
        scope: Option<TaskScope>,
        acceptance_criteria: Option<Vec<String>>,
        timestamp_ms: u64,
    },
    StatusChanged {
        task_id: Uuid,
        from: TaskStatus,
        to: TaskStatus,
        reason: Option<String>,
        timestamp_ms: u64,
    },
    EdgeAdded {
        task_id: Uuid,
        edge: TaskEdge,
        timestamp_ms: u64,
    },
    EdgeRemoved {
        task_id: Uuid,
        edge: TaskEdge,
        timestamp_ms: u64,
    },
    DecisionRaised {
        task_id: Uuid,
        decision: TaskDecision,
        timestamp_ms: u64,
    },
    DecisionResolved {
        task_id: Uuid,
        decision_id: Uuid,
        chosen_option: String,
        rationale: String,
        resolved_by: String,
        spawned_followup: Option<TaskDecision>,
        appended_criterion: Option<String>,
        timestamp_ms: u64,
    },
    DecisionSuperseded {
        task_id: Uuid,
        decision_id: Uuid,
        reason: String,
        timestamp_ms: u64,
    },
    TaskClaimed {
        task_id: Uuid,
        claim: AgentClaim,
    },
    TaskReleased {
        task_id: Uuid,
        agent_id: String,
        timestamp_ms: u64,
    },
    HandoffRecorded {
        task_id: Uuid,
        handoff: HandoffPacket,
        new_status: TaskStatus,
    },
    TaskSplit {
        parent_task_id: Uuid,
        spawned_children: Vec<TaskNode>,
        timestamp_ms: u64,
    },
    PlanUpdated {
        task_id: Uuid,
        plan: TaskPlan,
        timestamp_ms: u64,
    },
    TaskVerified {
        task_id: Uuid,
        receipt: VerificationReceipt,
    },
    DeferredItemCaptured {
        task: TaskNode,
        captured_by_agent: String,
        discovered_from_task_id: Option<Uuid>,
    },
}
```

## 3. `chalkline` Contracts (Spec Graph, `/grill-me` Decisions & Cross-Language Contracts)

Exported by `chalkline-core` and consumed by `storypole`, `dado`, `joiner`, and `benchwork`.

```rust
use serde::{Deserialize, Serialize};
use uuid::Uuid;

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct DecisionHole {
    pub id: Uuid,
    pub category: String, // e.g., "error_strategy", "auth_boundary", "schema_type"
    pub question: String,
    pub options: Vec<DecisionOption>,
    pub auto_resolved_by_miter: Option<usize>,
    pub selected_option: Option<usize>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct DecisionOption {
    pub label: String,
    pub tradeoff_summary: String,
    pub impacted_symbols: Vec<String>,
}

/// Neutral wire schema locked by `chalkline` so `dado` can emit matching Rust + TS types.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct SharedTypeContract {
    pub name: String,
    pub fields: Vec<ContractField>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct ContractField {
    pub name: String,
    pub canonical_type: String, // e.g., "uuid", "string", "i64", "vec<string>", "option<i32>"
    pub required: bool,
}

/// Canonical 9-document repository architecture contracts managed by chalkline.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct DocAuditReport {
    pub items: Vec<DocAuditItem>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct DocAuditItem {
    pub doc_type: DocType,
    pub path: std::path::PathBuf,
    pub status: DocStatus,
    pub violations: Vec<String>,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum DocStatus {
    Present,
    Missing,
    Drifted,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum DocType {
    Readme,
    Contributing,
    Product,
    Architecture,
    Spec,
    Design,
    Roadmap,
    Changelog,
    Agents,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct WorkspaceDocsAuditReport {
    pub targets: Vec<(String, DocAuditReport)>,
}
```

---

## 4. `dado` & `batten` Contracts (AST Templates, Typed Holes & CFG Masks)

Exported by `dado-core` and `batten-core`; consumed by `joiner` and `rabbet`.

```rust
use serde::{Deserialize, Serialize};

/// A single Typed Hole inside a `dado` AST template: `?[hole_id: expected_type]`
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct TypedHole {
    pub hole_id: String,
    pub expected_type: String,
    pub ast_node_kind: String, // e.g., "expression", "match_arm_body", "predicate"
    pub max_tokens: u16,
    pub allow_literals: bool,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct DadoPattern {
    pub pattern_id: String, // e.g., "rust.axum.handler.sqlx_tx.v1"
    pub language: miter_engine::Language,
    pub description: String,
    pub template_source: String,
    pub required_imports: Vec<String>,
    pub holes: Vec<TypedHole>,
    #[serde(default)]
    pub canonical_example_fills: std::collections::BTreeMap<String, String>,
}

/// Produced by `batten` from `(LexicalScope + TypedHole)`.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct CompiledGrammarConstraint {
    pub hole_id: String,
    pub format: GrammarFormat,
    pub grammar_definition: String, // Raw GBNF or Lark grammar string
    pub allowed_identifiers: Vec<String>,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum GrammarFormat {
    Gbnf,
    Lark,
    Regex,
}
```

---

## 5. `sawhorse` Contracts (3-Mode Nimble LLM Runtime)

Exported by `sawhorse-core` and consumed by `chalkline` and `joiner`.

```rust
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[serde(tag = "mode", rename_all = "snake_case")]
pub enum ExecutionMode {
    /// Mode 1: Specialized `gaugeblock` micro-weights running natively via `candle`
    InHouseCandle { model_id: String, weights_path: String },
    /// Mode 2: Local GGUF / quantized open weights via `mistral.rs` or `llama.cpp`
    LocalRuntime { model_id: String, endpoint_or_path: String },
    /// Mode 3: Any OpenAI-compatible HTTP endpoint (jev, vLLM, OpenRouter, Anthropic/OpenAI)
    OpenAiCompatible { base_url: String, api_key_env: String, model_name: String },
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum ModelRole {
    Planner,       // Used by `chalkline`
    System1Router, // Selects `dado` Pattern ID + structural mixins
    HoleFiller,    // Generates grammar-masked expressions inside `batten` constraints
    Oracle,        // Unconstrained or mildly constrained fallback for novel algorithms
}

// NOTE (GB-217): the catalog of models, their limits, billing tiers and per-protocol reasoning
// encodings is owned by the external `models-catalog` crate, not by this contract. `sawhorse` owns the
// policy - which effort to ask for and how much budget to spend - and this enum is the closed set of
// tiers that may appear on the wire. Six values, because that is where the catalog's own ordinal scale
// stops; a seventh would be a catalog change first.
/// Level of reasoning or thinking effort requested from the model.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum ReasoningEffort {
    None,          // Explicitly disable reasoning trace / thinking phase
    Low,           // Minimal reasoning effort (upstream `minimal` folds here)
    Medium,        // Standard reasoning effort (upstream `med` folds here)
    High,          // Exhaustive reasoning effort
    #[serde(rename = "xhigh")]
    XHigh,         // Beyond High; wire string is `xhigh`, not `x_high`
    Max,           // The model's maximum effort (`maximum` folds here)
}
// Closed set: unknown upstream tokens are dropped, not passed through (GB-221).

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct InferenceRequest {
    pub role: ModelRole,
    pub prompt: String,
    pub system_prompt: Option<String>,
    pub grammar_constraint: Option<String>, // Raw grammar string passed from `batten`
    pub grammar_format: Option<crate::GrammarFormat>, // Gbnf, Lark, or Regex
    pub max_tokens: u16,
    pub temperature: f32,
    pub reasoning_effort: Option<ReasoningEffort>, // Optional reasoning effort level
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct InferenceResponse {
    pub text: String,
    pub prompt_tokens: u32,
    pub completion_tokens: u32,
    pub latency_ms: u64,
    pub model_used: String,
    pub reasoning_trace: Option<String>, // Optional chain-of-thought trace
    pub reasoning_tokens: Option<u32>,   // Tokens consumed by reasoning
}
```

---

## 6. `joiner` & `rabbet` Contracts (Synthesis Traces & Telemetry Tiers)

Exported by `gaugeblock-contracts` (re-exported by `joiner-core` and `rabbet-core`) and written by
`storypole`, `joiner`, and `benchwork`. One outbox line is one `SpoolEntry`; the trace alone is not a
line, because a reader cannot recompute a hash that was never recorded (`GB-182`).

```rust
use serde::{Deserialize, Serialize};
use uuid::Uuid;

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum TelemetryTier {
    Bronze,  // Compiled + typechecked on attempt #1
    Silver,  // Passed unit tests on attempt #1
    Gold,    // Required repair/Oracle -> DPO training pair + new pattern candidate
    Diamond, // Survived unchanged in git main across subsequent commits
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct AnonymizedSynthesisTrace {
    pub trace_id: Uuid,
    pub language: gaugeblock_contracts::Language,
    pub tier: TelemetryTier,
    pub selected_pattern_id: Option<String>,
    pub anonymized_scope_signature: String,
    pub filled_holes: Vec<(String, String)>, // (hole_id, anonymized_expression)
    pub rejected_attempt: Option<String>,    // Present on Gold DPO traces
    pub verification: gaugeblock_contracts::VerificationReport,
    pub task_key: Option<String>,        // Storypole provenance; absent on joiner traces
    pub head_commit_sha: Option<String>, // Verified head; absent on joiner traces
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Default, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum SyncStatus {
    #[default]
    Pending, // Awaiting transmission to a rabbet hub
    Synced,  // Acknowledged by the hub
    Rejected, // Rejected by schema validation or hub deduplication
}

/// One line of `<canonical .gaugeblock>/spool/outbox.jsonl`.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct SpoolEntry {
    pub trace: AnonymizedSynthesisTrace,
    pub content_hash: String, // SHA-256 over canonical serde_json bytes of `trace`
    pub sync_status: SyncStatus,
    pub recorded_at_ms: u64,
}
```

`SpoolEntry::hash_trace` is the single hashing implementation: the writer records its result and
`rabbet`'s ingestion gate recomputes it, so a hash mismatch means the payload was edited in transit.
On the wire `sync_status` is a lowercase string (`pending` | `synced` | `rejected`), which is what
outboxes written before the type was shared already contain.

---

## 7. `outfeed` Contracts (Release Gates, AST Drift & Delivery Orchestration)

Exported by `outfeed-core` and consumed by `outfeed-cli`, `outfeed-mcp`, and meta-harness release scripts.

```rust
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub enum ConventionalKind {
    Feat,
    Fix,
    Refactor,
    Perf,
    Docs,
    Style,
    Chore,
    Ci,
    Build,
    Test,
    Other(String),
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CommitInfo {
    pub sha: String,
    pub summary: String,
    pub body: Option<String>,
    pub kind: ConventionalKind,
    pub scope: Option<String>,
    pub is_breaking: bool,
    pub breaking_description: Option<String>,
    pub referenced_tickets: Vec<String>,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum BumpType {
    Major,
    Minor,
    Patch,
    PreReleasePatch,
    PreReleaseMinor,
    PreReleaseAlpha,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ManifestDiff {
    pub relative_path: String,
    pub original_content: String,
    pub proposed_content: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ReleasePlan {
    pub repo_name: String,
    pub current_version: String,
    pub target_version: String,
    pub bump_type: BumpType,
    pub bump_rationale: String,
    pub commits: Vec<CommitInfo>,
    pub referenced_tickets: Vec<String>,
    pub changelog_markdown: String,
    pub manifest_diffs: Vec<ManifestDiff>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ReleaseStatus {
    pub repo_name: String,
    pub current_version: String,
    pub latest_tag: Option<String>,
    pub unreleased_commits: usize,
    pub is_clean: bool,
}
```

### `suite.lock` snapshot (outfeed)

```rust
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SuiteMetadata {
    pub version: String,
    pub created_at: String,
    pub meta_harness: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SuiteToolEntry {
    pub name: String,
    pub version: String,
    pub commit: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub tag: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SuiteLock {
    pub suite: SuiteMetadata,
    pub tools: Vec<SuiteToolEntry>,
}
```

