# PRODUCT.md — The `gaugeblock` Neurosymbolic Code Synthesis Architecture

> **Domain:** [gaugeblock.dev](https://gaugeblock.dev)  
> **GitHub Organization:** [github.com/gaugeblock](https://github.com/gaugeblock)  
> **License:** Apache-2.0

---

## 1. Core Thesis: Why `gaugeblock` Exists

In precision machining, a **gauge block** is the ground-truth calibration standard: blocks of hardened steel ground so flat and accurate that when two are slid together with a slight twist ("wringing"), molecular attraction locks them into a single rigid dimension with zero glue or fasteners.

Modern LLM-based software engineering does the exact opposite. It relies on massive, stochastic autoregressive text models to predict 100% of a codebase token-by-token—wasting 85% of compute and context on boilerplate syntax, hallucinating cross-file type contracts, drifting away from specifications across multi-file edits, and failing 40–45% of the time on complex repositories.

**`gaugeblock` replaces stochastic text generation with deterministic neurosymbolic program synthesis:**
1. **Planning & Ambiguity Resolution (`chalkline`)** and **Persistent DAG State (`storypole`)** lock down architectural decisions, cross-language schemas, and task dependencies *before* code generation begins.
2. **Deterministic AST Slicing (`miter`)** and **Parameterized AST Sketches (`dado`)** generate 85% of structural code, imports, traits, and error handling deterministically with zero LLM tokens.
3. **Scope-to-Grammar Compilation (`batten`)** converts the live variables and target return types at each `?[hole: Type]` into a strict Context-Free Grammar (GBNF/Lark) token mask.
4. **Nimble Multi-Mode LLMs (`sawhorse`)** are invoked *only* to route patterns (System 1) and fill tightly constrained 5-to-25 token holes (or escalate novel algorithms to an Oracle fallback), orchestrated end-to-end by **`joiner`**, inspected visually in **`benchwork`**, and continuously improved via compiler-verified telemetry in **`rabbet`**.

---

## 2. The 10-Repository `gaugeblock` Ecosystem

| # | Repository | Crates Published | Core Role & Metaphor |
| :--- | :--- | :--- | :--- |
| **1** | **`gaugeblock/miter`** | `miter-cli` (`miter`), `miter-engine`, `miter-ast`, `miter-storage`, `miter-mcp` | **AST Slicer & Verifier:** Deterministic polyglot AST parser, dependency grapher, signature slicer, and compiler verifier. |
| **2** | **`gaugeblock/storypole`** | `storypole`, `storypole-core`, `storypole-cli`, `storypole-mcp` | **Backlog & DAG Memory Store:** Git-native `.storypole/ledger.jsonl` + ephemeral SQLite index for task DAGs, decision records, and zero-interruption agent tech-debt capture. |
| **3** | **`gaugeblock/sawhorse`** | `sawhorse`, `sawhorse-core`, `sawhorse-cli` | **3-Mode LLM Runtime:** Provider-agnostic inference engine supporting (1) In-House embedded `candle` micro-models, (2) Local GGUF (`mistral.rs`/`llama.cpp`), and (3) OpenAI-compatible APIs (`jev`, `vLLM`, frontier clouds). |
| **4** | **`gaugeblock/chalkline`** | `chalkline`, `chalkline-core`, `chalkline-cli`, `chalkline-mcp` | **Spec & `/grill-me` Planner:** Interactive specification compiler that syncs `PRODUCT.md`/`DESIGN.md`, consults `miter` to auto-resolve known repo conventions, grills the user on true Decision Holes, and emits topological task DAGs into `storypole`. |
| **5** | **`gaugeblock/dado`** | `dado`, `dado-core`, `dado-cli` | **AST Pattern & Typed Hole Engine:** Parameterized polyglot AST templates containing named, typed holes (`?[hole_id: ExpectedType]`), structural mixins, and cross-language contract generators (e.g., Rust structs <-> TypeScript interfaces). |
| **6** | **`gaugeblock/batten`** | `batten`, `batten-core`, `batten-cli` | **Scope-to-CFG Grammar Compiler:** Compiles a `miter` lexical scope and a `dado` hole's target type into a strict Context-Free Grammar (GBNF/Lark/llguidance) so an LLM physically cannot emit out-of-scope identifiers or invalid syntax. |
| **7** | **`gaugeblock/joiner`** | `joiner`, `joiner-core`, `joiner-cli`, `joiner-mcp` | **Master Neurosymbolic Orchestrator:** Pulls ready tasks from `storypole`, routes via System 1 to `dado` patterns, constrains `sawhorse` with `batten` grammars to fill holes, verifies via `miter`, handles Oracle fallback, and records telemetry. |
| **8** | **`benchwork`** | `benchwork`, `benchwork-core`, `benchwork-cli` + TypeScript UI | **Modular Visual Workbench UI:** Single pluggable web workbench (Vite + TypeScript + Rust daemon) with 4 dynamic panels: Spec/`/grill-me` Studio, Live Backlog DAG Board, AST & Synthesis Inspector, and Model/Corpus Hub. |
| **9** | **`gaugeblock/rabbet`** | `rabbet`, `rabbet-core`, `rabbet-cli` | **Telemetry Corpus Hub & Foundry:** Cold-start OSS repository miner (using `miter` + `dado` in reverse), opt-in AST-anonymized telemetry ingestion pipeline (Bronze/Silver/Gold/Diamond tiers), and open-weight training foundry. |
| **10** | **`gaugeblock/outfeed`** | `outfeed`, `outfeed-core`, `outfeed-cli`, `outfeed-mcp` | **Packaging & Delivery Gate:** Topological crate packager, SemVer drift detector, changelog synthesizer, and crates.io publishing engine. |

---

## 3. End-to-End Neurosymbolic Dataflow

```text
[User Intent / Markdown Specs]
       │
       ▼
  ┌───────────┐    Decision Holes & Task DAG     ┌─────────────┐
  │ chalkline │ ───────────────────────────────► │  storypole  │ (SQLite + Git JSONL)
  └───────────┘                                  └──────┬──────┘
       ▲                                                │ Next Unblocked TaskNode
       │ Repo Symbols & Conventions                     ▼
  ┌────┴──────┐                                  ┌─────────────┐
  │   miter   │ ◄─────────────────────────────── │   joiner    │ ◄───► [benchwork UI]
  └────┬──────┘   1. Extract AST Slice & Scope   └──────┬──────┘
       │          5. Verify Compiled AST                │
       │                                  ┌─────────────┼─────────────┐
       │                                  ▼             ▼             ▼
       │                            ┌──────────┐  ┌──────────┐  ┌──────────┐
       │                            │   dado   │  │  batten  │  │ sawhorse │
       │                            │ (AST +   │  │ (Scope-> │  │ (3-Mode  │
       │                            │  Holes)  │  │  Grammar)│  │   LLM)   │
       │                            └──────────┘  └──────────┘  └─────▲────┘
       ▼                                                              │
  ┌───────────┐   Verified Anonymized Traces (Bronze/Silver/Gold)     │
  │  rabbet   │ ──────────────────────────────────────────────────────┘
  └───────────┘   Trains & Publishes Specialized Open Weights
```

---

## 4. Telemetry Tiers & Open-Weight Flywheel (`rabbet`)

Every synthesis loop in `joiner` can record an opt-in, AST-anonymized trace (where proprietary variable names and string literals are replaced with canonical placeholders like `sym_fn_1`, `sym_var_2` via `miter` before leaving the machine):

* **Bronze Trace:** Pattern selected + holes filled -> passed AST syntax and type-check on attempt #1.
* **Silver Trace:** Passed compilation + passed full unit/integration test suite on attempt #1.
* **Gold Trace:** Required self-repair or Oracle fallback, then passed tests -> yields a **Direct Preference Optimization (DPO)** pair `(rejected_ast, verified_ast)` or a newly extracted `dado` pattern candidate.
* **Diamond Trace:** Code survived unchanged in git `main` across subsequent commits without revert.

---

## 5. Verified Release & Delivery Pipeline (`outfeed`)

Once code modifications survive Tier 3 gates across the workspace, **`outfeed`** acts as the deterministic release gate:
* **AST Drift Inspection:** Verifies documentation and public API contracts against code before tagging.
* **Topological Sort Publishing:** Resolves member dependencies across workspaces to guarantee sub-crates (`*-core`, `*-mcp`) deploy prior to consumer CLIs and facade packages.
* **Changelog Synthesis:** Synthesizes `Keep a Changelog` records from Conventional Commits and Storypole tasks automatically.
