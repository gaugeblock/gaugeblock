# System Architecture — `gaugeblock` Meta-Harness

> **Meta-Harness:** `gaugeblock` (`neurosymbolic-suite`)  
> **Topology:** 10 Autonomous Repositories + Shared Data Contracts  
> **Lifecycle:** `0.1.0-beta.X`

---

## 1. High-Level Ecosystem Topology

The `gaugeblock` meta-harness wrings together 10 independent repositories into an end-to-end neurosymbolic code synthesis loop. Every repository functions as a standalone CLI, library crate, and MCP server, while adhering to shared wire protocols defined in `CONTRACTS.md`.

```mermaid
flowchart TD
    subgraph Planning["1. Planning & Intent"]
        U["Developer / Agent"] -->|intent & spec| CL["chalkline (Spec Planner)"]
        CL -->|topological DAG & tasks| SP["storypole (Backlog & Leases)"]
    end

    subgraph Symbolic["2. Symbolic Analysis & Templates"]
        SP -->|next task| JN["joiner (Master Orchestrator)"]
        JN -->|query AST & scope| MT["miter (AST Slicer & Verifier)"]
        JN -->|fetch pattern sketch| DD["dado (AST Pattern & Holes)"]
        JN -->|compile scope to CFG| BT["batten (Grammar Compiler)"]
    end

    subgraph Neural["3. Constrained Inference"]
        BT -->|GBNF / Lark mask| SH["sawhorse (3-Mode LLM Runtime)"]
        DD -->|typed hole prompts| SH
        SH -->|tokens| JN
    end

    subgraph Verification["4. Verification & Gate"]
        JN -->|apply patch in worktree| MT
        MT -->|compiler diagnostic parsing| JN
        JN -->|task completion| SP
        JN -->|anonymized trace| RB["rabbet (Telemetry Hub)"]
        SP -->|release gate| OF["outfeed (Packager & Publisher)"]
    end

    subgraph VisualWorkbench["Cross-Cutting Workbench"]
        BW["benchwork (Visual Studio UI & Daemon)"] -.->|inspects| Planning
        BW -.->|inspects| Symbolic
        BW -.->|inspects| Verification
    end
```

---

## 2. Repository & Workspace Topology

The meta-harness organizes 11 standalone Git checkouts mapped via local `.cargo/config.toml` `[patch.crates-io]` for zero-friction local multi-repo development:

```text
neurosymbolic-suite/               # Root meta-harness & contract coordinator
├── .gaugeblock/                   # Shared config, Storypole ledger, docs policies
│   ├── config.toml                # Multi-tool unified configuration
│   ├── docs.toml                  # 9-Document architecture policies
│   └── storypole/                 # Append-only task and claim ledger
├── CONTRACTS.md                   # Formal shared wire types and schemas
├── common/                        # Shared wire contracts & foundation crates
├── miter/                         # AST slicing, scope indexing, redb engine
├── storypole/                     # Git-native SQLite/JSONL backlog & claim leases
├── sawhorse/                      # 3-Mode provider-agnostic LLM runtime
├── chalkline/                     # Spec planner, /grill-me, 9-doc manager
├── dado/                          # AST pattern templates & typed holes
├── batten/                        # Scope-to-grammar compiler & token masks
├── joiner/                        # Neurosymbolic synthesizer & repair loop
├── benchwork/                     # Multi-repo web CAD console & daemon
├── rabbet/                        # Telemetry corpus hub & training foundry
└── outfeed/                       # Release gate, SemVer bump, packager
```

---

## 3. Crate & Package Topology


### `gaugeblock-common`
- Path: `common/`
- Version: `0.1.0-beta.1`
- Description: Facade re-exporting the suite's shared wire contracts.

### `gaugeblock-contracts`
- Path: `common/crates/gaugeblock-contracts`
- Version: `0.1.0-beta.1`
- Description: Pure-serde wire types mirroring `CONTRACTS.md`, with no C dependencies or async runtime.

### `batten`
- Path: `batten/`
- Version: `0.1.0-beta.2`
- Description: Dynamic variable-scope to Context-Free Grammar (GBNF/Lark) compiler and token mask generator

### `batten-cli`
- Path: `batten/crates/batten-cli`
- Version: `0.1.0-beta.2`
- Description: Command-line interface and MCP server for batten

### `batten-core`
- Path: `batten/crates/batten-core`
- Version: `0.1.0-beta.2`
- Description: Core library, type normalizer, scope filter, and CFG emitters for batten

### `batten-mcp`
- Path: `batten/crates/batten-mcp`
- Version: `0.1.0-beta.2`
- Description: Model Context Protocol server for batten grammar compiler

### `benchwork`
- Path: `benchwork/`
- Version: `0.1.0-beta.4`
- Description: Modular visual workbench UI and local daemon for neurosymbolic code synthesis and DAG inspection

### `benchwork-cli`
- Path: `benchwork/crates/benchwork-cli`
- Version: `0.1.0-beta.4`
- Description: Command-line interface and local daemon for benchwork

### `benchwork-core`
- Path: `benchwork/crates/benchwork-core`
- Version: `0.1.0-beta.4`
- Description: Core domain types, workspace aggregation, and multi-crate services for benchwork

### `benchwork-mcp`
- Path: `benchwork/crates/benchwork-mcp`
- Version: `0.1.0-beta.4`
- Description: Model Context Protocol stdio server for benchwork

### `chalkline`
- Path: `chalkline/`
- Version: `0.1.0-beta.2`
- Description: Interactive specification planner, ambiguity resolver, and topological task DAG compiler.

### `chalkline-cli`
- Path: `chalkline/crates/chalkline-cli`
- Version: `0.1.0-beta.2`
- Description: Command-line interface and entrypoint for chalkline

### `chalkline-core`
- Path: `chalkline/crates/chalkline-core`
- Version: `0.1.0-beta.2`
- Description: Core library, spec parser, recon engine, ambiguity griller, and DAG compiler for chalkline

### `chalkline-mcp`
- Path: `chalkline/crates/chalkline-mcp`
- Version: `0.1.0-beta.2`
- Description: Model Context Protocol (MCP) stdio server for chalkline

### `dado`
- Path: `dado/`
- Version: `0.1.0-beta.2`
- Description: Deterministic polyglot AST pattern & typed hole engine

### `dado-cli`
- Path: `dado/crates/dado-cli`
- Version: `0.1.0-beta.2`
- Description: CLI binary and entrypoints for dado

### `dado-core`
- Path: `dado/crates/dado-core`
- Version: `0.1.0-beta.2`
- Description: Core library, AST pattern engine, typed hole parser, and polyglot codegen for dado

### `dado-mcp`
- Path: `dado/crates/dado-mcp`
- Version: `0.1.0-beta.2`
- Description: Model Context Protocol (MCP) server for dado

### `joiner`
- Path: `joiner/`
- Version: `0.1.0-beta.2`
- Description: Master neurosymbolic synthesis orchestrator for the gaugeblock suite

### `joiner-cli`
- Path: `joiner/crates/joiner-cli`
- Version: `0.1.0-beta.2`
- Description: Command-line interface and daemon for joiner

### `joiner-core`
- Path: `joiner/crates/joiner-core`
- Version: `0.1.0-beta.2`
- Description: Core orchestration loop, System 1 router, hole filler, and verifier for joiner

### `joiner-mcp`
- Path: `joiner/crates/joiner-mcp`
- Version: `0.1.0-beta.2`
- Description: Model Context Protocol (MCP) server for joiner

### `miter-ast`
- Path: `miter/crates/ast_indexer`
- Version: `0.1.0-beta.1`
- Description: Tree-sitter AST ingestion: functions, inputs and return types with their provenance and nesting depth

### `miter-cli`
- Path: `miter/`
- Version: `0.1.0-beta.1`
- Description: Workspace member crate

### `miter-engine`
- Path: `miter/crates/engine`
- Version: `0.1.0-beta.1`
- Description: AST storage and analysis engine: polyglot model, hydration, audit, slices, clones, contracts and secret redaction

### `miter-harness`
- Path: `miter/crates/harness`
- Version: `0.1.0-beta.1`
- Description: Deterministic compiler verification: sandboxed git worktrees and diagnostic parsing for `miter verify`

### `miter-mcp`
- Path: `miter/crates/mcp`
- Version: `0.1.0-beta.1`
- Description: Model Context Protocol (MCP) stdio server exposing AST hydration and compiler verification

### `miter-storage`
- Path: `miter/crates/storage`
- Version: `0.1.0-beta.1`
- Description: Canonical redb tables, schema versioning and auto-purge recovery for the miter workspace database

### `outfeed`
- Path: `outfeed/`
- Version: `0.1.0-beta.2`
- Description: Neurosymbolic release gate, AST drift inspector, changelog synthesizer, and delivery orchestrator

### `outfeed-cli`
- Path: `outfeed/crates/outfeed-cli`
- Version: `0.1.0-beta.2`
- Description: Command-line interface and entrypoints for outfeed release and packaging

### `outfeed-core`
- Path: `outfeed/crates/outfeed-core`
- Version: `0.1.0-beta.2`
- Description: Core release planner, SemVer bump calculator, topological DAG resolver, and Keep a Changelog synthesizer

### `outfeed-mcp`
- Path: `outfeed/crates/outfeed-mcp`
- Version: `0.1.0-beta.2`
- Description: Model Context Protocol (MCP) stdio server for outfeed release management

### `rabbet`
- Path: `rabbet/`
- Version: `0.1.0-beta.2`
- Description: AST-anonymized telemetry corpus hub and open-weight micro-model training foundry

### `rabbet-cli`
- Path: `rabbet/crates/rabbet-cli`
- Version: `0.1.0-beta.2`
- Description: Command-line interface, ingestion daemon, and maintainer admin console for rabbet

### `rabbet-core`
- Path: `rabbet/crates/rabbet-core`
- Version: `0.1.0-beta.2`
- Description: Core domain types, SQLite master store, Parquet exporter, and miners for rabbet

### `sawhorse`
- Path: `sawhorse/`
- Version: `0.1.0-beta.3`
- Description: Provider-agnostic 3-mode LLM runtime for deterministic neurosymbolic code synthesis.

### `sawhorse-cli`
- Path: `sawhorse/crates/sawhorse-cli`
- Version: `0.1.0-beta.3`
- Description: Command-line interface and diagnostic tooling for sawhorse

### `sawhorse-core`
- Path: `sawhorse/crates/sawhorse-core`
- Version: `0.1.0-beta.3`
- Description: Core library, contracts, routing, and provider adapters for sawhorse

### `storypole`
- Path: `storypole/`
- Version: `0.1.0-beta.2`
- Description: Git-native SQLite and JSONL backlog, task DAG, and MCP memory store for AI coding agents.

### `storypole-cli`
- Path: `storypole/crates/storypole-cli`
- Version: `0.1.0-beta.2`
- Description: Command-line interface and entrypoint for storypole

### `storypole-core`
- Path: `storypole/crates/storypole-core`
- Version: `0.1.0-beta.2`
- Description: Core library, models, ledger, and DAG engine for storypole

### `storypole-mcp`
- Path: `storypole/crates/storypole-mcp`
- Version: `0.1.0-beta.2`
- Description: Model Context Protocol (MCP) stdio server for storypole


---

## Crate & file audit (measured)

The suite is audited from the meta-harness root, not repo by repo, because a plain walk from the root
honours the `.gitignore` that excludes every member checkout (`GB-194`). Three commands, re-runnable:

```bash
miter audit --path . --threshold 250   # the hard ceiling; exits non-zero on a violation
miter audit --path . --threshold 200   # the band AGENTS.md says to split in
miter deps  --path .                   # crate edges + declared-but-unreferenced dependencies
```

Measured on 2026-10-29 (miter 0.1.0-beta.4, all eleven members present):

| Question | Result |
|:---|:---|
| Files over the hard 250-line ceiling | **0** - `GB-191`, `GB-192`, `GB-193` closed the last three |
| Files in the 200-250 band | **70** - miter 34, benchwork 14, storypole 8, outfeed 4, joiner 3, chalkline 3, common 2, sawhorse 1, rabbet 1 (`GB-195`) |
| Workspace crates and import edges | **42 crates, 132 crate-to-crate edges**, every edge into `gaugeblock-contracts` inbound |
| Declared dependencies no source references | **59** - batten 9, dado 9, rabbet 9, benchwork 7, chalkline 7, joiner 5, outfeed 5, sawhorse 4, storypole 3 |
| Structural clones at 0.90 similarity | **100 pairs (17 cross-crate)**, and the cross-crate ones spot-check to *shape only*, not shared meaning (`GB-197`) |

What the numbers say about boundaries:

1. **The file half is closed.** No ceiling violations anywhere, so the remaining 70 files are a
   mechanical sweep, not a design problem.
2. **The duplication that matters is at the wrapper level**, not the function level: a 6-line
   `Command::new("git")...output()` appears **66 times across 24 files in three repos** (outfeed 44,
   miter 12, storypole 10), which sits below `miter clones`' 15-line floor. That is the measured case
   for `gaugeblock-git` (`GB-131`), and `.gaugeblock` path derivation spread over ~10 storypole files
   plus chalkline, dado and joiner is the same case for `gaugeblock-workspace` (`GB-189`).
3. **Dead declarations are diffuse**: 59 across nine repos with no repo holding a majority, so the fix
   is a sweep per repo rather than one refactor.
4. **`miter clones` cannot yet drive a boundary decision** - it reports structure, and two functions
   that share a shape while operating on different data score 1.000. Content overlap is required
   before its count means "duplication" (`GB-197`).

### From measurement to plan

The program that acts on these numbers is **Staged B** (`GB-200`); its phases and exit criteria live in
`.gaugeblock/storypole/plans/GB-200.md`. In order: make the dependency numbers trustworthy (`GB-199`),
purge the 59 dead declarations (`GB-201`), freeze the mesh behind a layer gate seeded with the six
existing lateral edges (`GB-202`), land `gaugeblock-git` + `gaugeblock-workspace` and settle
`gaugeblock-mcp` (`GB-131`, `GB-189`, `GB-130`), split `miter-engine` into polyglot / inventory /
analysis with the engine as facade (`GB-203`), then burn the six lateral edges to zero (`GB-204`).

Law 2 holds: none of it consolidates repositories, and no phase may make one member's build depend on
another's checkout.
