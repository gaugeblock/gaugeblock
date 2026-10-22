# AGENTS.md — Operational Directives for the `gaugeblock` Meta-Harness

> **Organization:** `gaugeblock` (`[https://github.com/gaugeblock](https://github.com/gaugeblock)` | `[https://gaugeblock.dev](https://gaugeblock.dev)`)  
> **Ecosystem Suite:** `miter`, `storypole`, `sawhorse`, `chalkline`, `dado`, `batten`, `joiner`, `benchwork`, `rabbet`  
> **Default Crate Version:** `0.0.1-alpha.1` (Git tag format: `v0.0.1-alpha.1`)

You are an autonomous systems engineering agent operating inside the **`gaugeblock`** multi-repository meta-harness. Every repository in this workspace is a standalone open-source project that wrings together deterministically with the rest of the suite via strict data contracts (`CONTRACTS.md`).

---

## 1. Non-Negotiable Engineering Laws

1. **Hard 250-Line File Limit:**
   * No `.rs`, `.ts`, or `.tsx` source file may exceed **250 lines of code** (including comments and tests).
   * If a file approaches 200 lines, split it immediately into clean submodules (`mod.rs` or `<module>/<submodule>.rs`) and move unit tests into a sibling `tests.rs` or `tests/` directory.
2. **Unix Philosophy & Standalone Value:**
   * Each of the 9 repositories MUST compile, pass tests, and provide a genuinely useful CLI/MCP/library experience completely on its own without requiring the entire stack to be running.
   * Cross-project coupling happens strictly through the shared schemas and traits defined in `CONTRACTS.md`.
3. **Zero Inline Scope Creep (Asynchronous Deferral via `storypole`):**
   * While executing a task, if you discover an unrelated bug, edge case, missing AST pattern, or refactoring opportunity outside your immediate file scope, **DO NOT fix it inline**.
   * Once `storypole` is online, record the item immediately via `storypole defer --kind <tech-debt|bug|enhancement> --symbol "<crate::path>" --title "..."` (or append to `.storypole/ledger.jsonl`) and stay locked on your active task.
4. **Deterministic Verification Before Completion:**
   * No task is complete until all of the following pass with zero warnings inside the target repository's workspace (`cd <repo>`):
     * `cargo fmt --all -- --check`
     * `cargo clippy --workspace --all-targets -- -D warnings`
     * `cargo test --workspace`
5. **Strict Error Handling & Observability:**
   * Library crates (`*-core`, `*-engine`) MUST use `thiserror` with strongly typed error enums. `.unwrap()` and `.expect()` are forbidden in production library paths (allowed only in tests or provably infallible static initializers with a `// SAFETY:` or `// INVARIANT:` comment). Enforced at compile time via `[workspace.lints.clippy]` (`unwrap_used = "deny"`, `expect_used = "deny"`).
   * Binary/CLI crates (`*-cli`, `*-mcp`) may use `anyhow::Result` at the top-level command boundary.
   * Use `tracing` for structured instrumentation; never pollute `stdout` when running in `--mcp` (JSON-RPC over stdio) or `--json` mode—all logs must route to `stderr` or a file sink.

---

## 2. Repository Layout & Rust 2024 Sub-Crate Conventions

Every Rust repository under `gaugeblock/<name>` follows a uniform Rust 2024 workspace layout:

```text
<name>/
├── Cargo.toml                 # Root workspace & facade crate (`<name>`)
├── README.md                  # Standalone usage, architecture, and gaugeblock.dev link
├── .gitignore                 # Must ignore `target/` and `**/target/` at all depths
├── src/
│   └── lib.rs                 # Re-exports `<name>-core` for ergonomics
└── crates/
    ├── <name>-core/           # Pure domain types, traits, and deterministic engines
    │   ├── Cargo.toml
    │   └── src/lib.rs
    ├── <name>-cli/            # Clap CLI binary + JSON/Daemon/MCP entrypoints
    │   ├── Cargo.toml
    │   └── src/main.rs
    └── <name>-mcp/            # (Optional) Dedicated Model Context Protocol stdio/SSE server
        ├── Cargo.toml
        └── src/lib.rs
```

*(Note: In `gaugeblock/miter`, the AST indexing and analysis engine is modularized across `crates/engine` as `miter-engine`, `crates/ast_indexer` as `miter-ast`, `crates/storage` as `miter-storage`, and the root binary/lib as `miter-cli` / `miter`.)*

### Canonical Root `Cargo.toml` Template (Rust 2024)

Every repository root `Cargo.toml` defines the workspace, common metadata, shared dependencies, and workspace-wide lints:

```toml
[workspace]
resolver = "3"
members = [
    ".",
    "crates/*",
]

[workspace.package]
version = "0.0.1-alpha.1"
edition = "2024"
authors = ["Colin Wolff <1562545+colinwolff@users.noreply.github.com>"]
license = "Apache-2.0"
repository = "https://github.com/gaugeblock/<name>"
homepage = "https://gaugeblock.dev"
readme = "README.md"
keywords = ["ast", "neurosymbolic", "codegen", "llm", "compiler"]
categories = ["development-tools", "compilers", "command-line-utilities"]

[workspace.lints.rust]
unsafe_code = "deny"
missing_debug_implementations = "warn"

[workspace.lints.clippy]
unwrap_used = "deny"
expect_used = "deny"

[package]
name = "<name>"
version.workspace = true
edition.workspace = true
authors.workspace = true
license.workspace = true
repository.workspace = true
readme = "README.md"
description = "..."

[lints]
workspace = true
```

Member crates (`crates/<name>-core/Cargo.toml`, etc.) inherit package metadata and lints cleanly:

```toml
[package]
name = "<name>-core"
version.workspace = true
edition.workspace = true
authors.workspace = true
license.workspace = true
repository.workspace = true
description = "Core library and traits for <name>"

[lints]
workspace = true
```

### Local Cross-Repo Development (`[patch.crates-io]`)
During multi-repo development inside the root meta-harness, root `.cargo/config.toml` maps published dependencies (`miter-engine`, `storypole-core`, `sawhorse-core`, etc.) to local sibling checkouts so cross-repo changes are tested end-to-end before publishing new versions.

---

## 3. Agent Execution Loop

For every assigned task:
1. **Read Context First:** Inspect `CONTRACTS.md`, the active phase in `ROADMAP.md`, and the target repository's `Cargo.toml`.
2. **Slice Minimal Context:** Use `miter` (when inspecting existing modules) to extract signatures and AST slices rather than dumping entire repositories into context.
3. **Implement Modularly:** Write small, single-purpose files (under 250 LOC) with explicit doc comments (`///`) on every public struct, enum, and trait method.
4. **Verify & Record:** Run fmt, clippy, and tests. Update the task status in `storypole` (`ROADMAP.md` during Phase 1 bootstrap).