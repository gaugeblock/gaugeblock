# CONTRACTS.md — Shared Types, JSON Schemas & Trait Boundaries

> **Rule:** Every struct and trait below defines an immutable wire contract between the 9 `gaugeblock` repositories. All wire types MUST derive `serde::Serialize`, `serde::Deserialize`, `Debug`, `Clone`, and `PartialEq`.

---

## 1. `miter` Contracts (AST Slicing, Lexical Scope & Verification)

Exported by `miter-engine` and consumed by `chalkline`, `dado`, `batten`, `joiner`, and `rabbet`.

```rust
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum Language {
    Rust,
    TypeScript,
    Python,
    Go,
    C,
    Cpp,
}

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

## 2. `storypole` Contracts (Backlog, Task DAG & Ledger Events)

Exported by `storypole-core` and persisted in `.storypole/ledger.jsonl` (git-tracked) + `.storypole/index.sqlite` (local cache). Consumed by `chalkline`, `joiner`, `benchwork`, and external MCP agents.

```rust
use serde::{Deserialize, Serialize};
use uuid::Uuid;

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum TaskKind {
    Feature,
    Refactor,
    Bug,
    TechDebt,
    DecisionHole,
    PatternExtraction,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum TaskStatus {
    Blocked,
    Ready,
    InProgress,
    Synthesizing,
    Verifying,
    Verified,
    Deferred,
    Failed,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct TaskNode {
    pub id: Uuid,
    pub slug: String,
    pub title: String,
    pub description: String,
    pub kind: TaskKind,
    pub status: TaskStatus,
    pub priority: u8, // 1 (highest) to 5 (lowest)
    pub depends_on: Vec<Uuid>,
    pub target_files: Vec<String>,
    pub target_symbols: Vec<String>,
    pub acceptance_criteria: Vec<String>,
    pub created_at_epoch_ms: u64,
    pub updated_at_epoch_ms: u64,
}

/// Immutable append-only event written to `.storypole/ledger.jsonl`.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[serde(tag = "event", rename_all = "snake_case")]
pub enum LedgerEvent {
    TaskCreated { task: TaskNode },
    StatusChanged { task_id: Uuid, from: TaskStatus, to: TaskStatus, reason: Option<String> },
    DependencyAdded { task_id: Uuid, depends_on_id: Uuid },
    DecisionResolved { decision_id: Uuid, question: String, chosen_option: String, rationale: String },
    DeferredItemCaptured { task: TaskNode, captured_by_agent: String, active_task_id: Option<Uuid> },
}
```

---

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

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct InferenceRequest {
    pub role: ModelRole,
    pub prompt: String,
    pub system_prompt: Option<String>,
    pub grammar_constraint: Option<String>, // Raw grammar string passed from `batten`
    pub grammar_format: Option<crate::GrammarFormat>, // Gbnf, Lark, or Regex
    pub max_tokens: u16,
    pub temperature: f32,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct InferenceResponse {
    pub text: String,
    pub prompt_tokens: u32,
    pub completion_tokens: u32,
    pub latency_ms: u64,
    pub model_used: String,
}
```

---

## 6. `joiner` & `rabbet` Contracts (Synthesis Traces & Telemetry Tiers)

Exported by `joiner-core` and `rabbet-core`.

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
    pub language: miter_engine::Language,
    pub tier: TelemetryTier,
    pub selected_pattern_id: Option<String>,
    pub anonymized_scope_signature: String,
    pub filled_holes: Vec<(String, String)>, // (hole_id, anonymized_expression)
    pub rejected_attempt: Option<String>,    // Present on Gold DPO traces
    pub verification: miter_engine::VerificationReport,
}
```