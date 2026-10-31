# AGENTS.md — Operational Directives for the `gaugeblock` Meta-Harness

> **Organization:** `gaugeblock` (`https://github.com/gaugeblock` | `https://gaugeblock.dev`)  
> **Ecosystem Suite:** `miter`, `storypole`, `sawhorse`, `chalkline`, `dado`, `batten`, `joiner`, `benchwork`, `rabbet`, `outfeed`  
> **Active Suite Lifecycle:** `0.1.0-beta.X` | Git tag format: `v<version>`

You are an autonomous systems engineering agent operating inside the **`gaugeblock`** multi-repository meta-harness. Every repository in this workspace is a standalone open-source project that wrings together deterministically with the rest of the suite via strict data contracts (`CONTRACTS.md`).

---

## 1. Non-Negotiable Engineering Laws

1. **Hard 250-Line File Limit:**
   * No `.rs`, `.ts`, or `.tsx` source file may exceed **250 lines of code** (including comments and tests).
   * If a file approaches 200 lines, split it immediately into clean submodules (`mod.rs` or `<module>/<submodule>.rs`) and move unit tests into a sibling `tests.rs` or `tests/` directory.
2. **Unix Philosophy & Standalone Value:**
   * Each of the 10 repositories MUST compile, pass tests, and provide a genuinely useful CLI/MCP/library experience completely on its own without requiring the entire stack to be running.
   * Cross-project coupling happens strictly through the shared schemas and traits defined in `CONTRACTS.md`.
3. **Zero Inline Scope Creep (Mandatory Deferral to `storypole`):**
   * While executing a task, if you discover an unrelated bug, edge case, missing AST pattern, or refactoring opportunity outside your immediate file scope, **DO NOT fix it inline**.
   * You MUST record the item immediately via `storypole defer --kind <tech-debt|bug> --symbols "<crate::path>" "<title>"` (or the `storypole_defer` MCP tool). The title is positional, `--symbols` is plural, and kinds are the task kinds (`bug`, `tech-debt`, `feature`, `refactor`, `epic`, `spike`) - a wrong spelling here fails the command rather than being corrected for you, which cost three attempts in one session.. Stay locked on your active task. Every discovered defect or out-of-scope requirement must be captured in `storypole` to ensure complete traceability.
4. **Tiered Verification Matrix (`cargo-nextest` preferred runner):**
   * To sustain high inner-loop velocity without compromising reliability, verifications are strictly tiered:
     * **Tier 1 (Inner Loop — Rapid Iteration):** Run targeted checks on the active crate/module during development:
       `cargo check -p <crate>` or `cargo nextest run -p <crate> --lib <submodule_or_test>` (fallback: `cargo test -p <crate> --lib <submodule_or_test>`)
     * **Tier 2 (Atomic Commit Gate):** Run on the affected crate before finalizing an atomic commit:
       `cargo fmt --check -p <crate>`, `cargo clippy -p <crate> --all-targets -- -D warnings`, `cargo nextest run -p <crate>` (fallback: `cargo test -p <crate>`), and `chalkline docs check -d <repo>` (enforcing 9-doc compliance and zero AST drift).
     * **Tier 3 (Task Completion Gate):** Full workspace verification before closing a task or marking `Verified` in `storypole`:
       `cargo fmt --all -- --check`, `cargo clippy --workspace --all-targets -- -D warnings`, `cargo nextest run --workspace`, `miter contracts`, `outfeed lockfiles` (every repository tracks a fresh `Cargo.lock`; `scripts/check-lockfiles.sh` is a wrapper over it), and `chalkline docs check --workspace` (certifying 100% documentation fidelity across all 11 workspace targets).
     * **Tier 4 (Release & Wire Gate):** Full cross-repo suite, integration tests, wire contract validation (`miter contracts`), and `chalkline docs check --workspace` before bumping versions or pushing release tags.
5. **Strict Error Handling & Observability:**
   * Library crates (`*-core`, `*-engine`) MUST use `thiserror` with strongly typed error enums. `.unwrap()` and `.expect()` are forbidden in production library paths (allowed only in tests or provably infallible static initializers with a `// SAFETY:` or `// INVARIANT:` comment). Enforced at compile time via `[workspace.lints.clippy]` (`unwrap_used = "deny"`, `expect_used = "deny"`).
   * Binary/CLI crates (`*-cli`, `*-mcp`) may use `anyhow::Result` at the top-level command boundary.
   * Use `tracing` for structured instrumentation; never pollute `stdout` when running in `--mcp` (JSON-RPC over stdio) or `--json` mode—all logs must route to `stderr` or a file sink.
6. **Atomic Commits & Bisect Invariance:**
   * Every commit MUST represent a single logical unit of work (one bug fix, one discrete refactoring, or one sub-crate capability). Never bundle unrelated edits across disparate domains.
   * Every commit MUST pass Tier 2 verification. Never commit broken intermediate states that break `git bisect`.
   * Staging hygiene: Never use `git add .` blindly. Inspect `git diff --staged` before creating a commit.
   * **An ignored path aborts the whole `git add`.** `git add -A <dir> Cargo.lock` in a repository that ignored `Cargo.lock` staged *nothing* and exited non-zero, and a following `git commit -q` then failed with no output — silently producing a no-op merge (GB-150). Stage explicit paths that are known to be tracked, and confirm the commit landed with `git log --oneline -1`.
7. **Conventional Commits Specification:**
   * Commit messages MUST follow Conventional Commits v1.0.0: `<type>(<scope>): <summary>`
   * Allowed types: `feat`, `fix`, `refactor`, `perf`, `test`, `docs`, `style`, `chore`, `ci`, `build`.
   * Scopes MUST specify the affected crate (e.g., `storypole-core`, `storypole-cli`) or harness domain (e.g., `workspace`, `contracts`, `roadmap`, `deps`).
   * Subject line: imperative mood ("add", "fix", not "added", "fixes"), lowercase start, no trailing period, maximum 72 characters.
   * Footers: Reference task keys when applicable (e.g., `Task: SP-14`, `Closes: SP-14`). Breaking changes require `BREAKING CHANGE: <description>`.
8. **Semantic Versioning & Git Tagging:**
   * **Intra-Repo Lockstep vs. Meta-Harness Independence:**
     * Each of the 10 repositories (`gaugeblock/<name>`) is an independent Git repository and Cargo workspace.
     * Member crates within a repository (`*-core`, `*-cli`, `*-mcp`, and the root facade) lockstep together via the repository root `Cargo.toml` (`[workspace.package] version = "..."`) using `version.workspace = true`.
     * Across the meta-harness, repositories evolve and version independently (e.g., `benchwork` may be `0.1.0-beta.3` while `storypole` is `0.1.0-beta.11` and `miter` is `0.1.0-alpha.2`).
   * **Cross-Repo Dependencies:**
     * Dependencies across suite crates declare minimum required version constraints (e.g. `storypole-core = ">=0.1.0-beta.1, <0.2.0"` or `^0.1.0-beta.1`). Bump dependency constraints only when consuming newly introduced upstream APIs or updated schemas.
     * Local multi-repo development is mapped via `.cargo/config.toml` `[patch.crates-io]` to sibling paths.
   * **Pre-Release Increments & Breaking Changes:**
     * During active beta, backwards-compatible fixes, features, and refinements increment the pre-release patch sequence (`0.1.0-beta.1` -> `0.1.0-beta.2`).
     * Breaking API or schema changes in a crate bump that crate's minor base (e.g., `storypole` to `0.2.0-beta.1`). Consuming repositories bump their own versions independently as normal when updating dependencies to adopt the new version.
     * **Namespace reservations publish at `0.1.0-alpha.1`.** A placeholder that only claims a crates.io name is never a `beta`: the crate moves to `0.1.0-beta.1` on its first real, dogfood-ready build (see `GB-127`).
   * **Git Tagging & Release Management:**
     * Individual repositories tag their own releases in their local Git history using annotated tags `v<version>` (e.g., `git tag -a v0.1.0-beta.2 -m "v0.1.0-beta.2"`).
     * The root meta-harness (`neurosymbolic-suite`) has no package version in `Cargo.toml`; it cuts annotated snapshot tags on certified ecosystem milestone passes: `suite-v<version>` (e.g., `suite-v0.1.0-beta.1`).
   * **Distributed Changelogs:**
     * Each repository maintains its own `CHANGELOG.md` detailing crate-level changes per release.
     * Root `CHANGELOG.md` aggregates suite-wide milestones, cross-cutting contract evolution, and ecosystem compatibility.
9. **Mandatory Dogfooding & Target Directory Prohibition:**
   * All agent workflows and operations MUST utilize the globally installed CLI suite (`miter`, `storypole`, `sawhorse`, `chalkline`, `dado`, `batten`, `joiner`, `benchwork`, `rabbet`, `outfeed`) from `PATH` or their registered MCP servers.
   * Agents are strictly forbidden from executing binaries directly from local `target/debug/` or `target/release/` directories for operational workflows.
   * The `target/` directories are reserved exclusively for automated testing (`cargo test`) and compiler checks during active crate development. Use `outfeed install --all` or `scripts/install-suite.sh` to compile and install updated binaries into `~/.cargo/bin`.
10. **Branch Isolation & Feature Branching:**
   * All non-trivial tickets (`Kind != Chore` or changes spanning multiple files) MUST be developed on dedicated Git branches (`feat/<ticket-or-slug>`, `fix/<ticket-or-slug>`).
   * Agents MUST NEVER make unchecked changes directly on `main`.
   * When claiming a task via `storypole claim <KEY> <AGENT_ID> [--branch <BRANCH>]`, the current branch and base commit SHA are recorded in the task claim lease.
11. **Plan Persistence & Specification Fidelity:**
   * Every non-trivial task (`P1`/`P2` or multi-step feature) MUST have an attached `TaskPlan` (`storypole plan set`) and its unabridged design markdown saved under `.storypole/plans/<KEY>.md`.
   * Design markdown files under `.storypole/plans/` are first-class versioned repository assets and MUST be committed to Git alongside ledger events.
   * Discovered design invariants, boundary taxonomy, TOML schemas, and execution steps MUST be recorded in the task plan before executing code modifications.
12. **Performance Claims Must Be Measured, And The Measurement Must Persist:**
   * No change may be described as faster, lighter, or cheaper without a before/after measurement taken on the same machine, in the same order, with the same inputs. Run timed phases sequentially; parallel runs contend for CPU and produce noise (`GB-71` produced a bogus 30 s build this way before being re-measured).
   * Record the numbers in three places: the commit message that makes the claim, the `storypole` task description or acceptance criteria, and a durable document in the repository that owns the change (`CONTRIBUTING.md`, `PERF.md`, or the relevant `SPEC.md`). A figure that lives only in chat has not been recorded.
   * State the environment with the number: platform, tool versions, cache state, and whether the measurement is a cold or warm run. Report regressions as plainly as wins - a slower build is a result, not something to omit.
   * When a benchmark informs a decision with no code change (a migration already made, a design chosen), measure it retroactively and backfill the task. `GB-71` shipped its migration before any timing existed and the gap had to be closed afterwards.

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
version = "0.1.0-beta.1"
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

## 3. Agent Execution Loop & Dogfooding Workflow

For every assigned task:
1. **Task Briefing & Lease:** Use `storypole list` and `storypole claim <KEY> <AGENT_ID>` (or MCP `storypole_claim`) to lease the task.
2. **Context Slicing with `miter`:** Use installed `miter lookup`, `miter skeleton`, and `miter impact` to inspect AST signatures and blast radii rather than dumping entire repositories into context.
3. **Plan & Spec with `chalkline`:** Use installed `chalkline recon` and `chalkline grill` to auto-resolve conventions and identify decision boundaries.
4. **Synthesize & Patch with `dado` & `batten`:** Compose deterministic AST patterns with `dado render` and validate grammatical constraints with `batten validate`.
5. **Dogfood the synthesis loop where it is deterministic:** the suite exists to generate and verify code, so feature work feeds it back.
   * New wire types and DTOs SHOULD be emitted with `dado contract` rather than hand-written, so the pattern library grows from real use.
   * Rendered batches SHOULD pass `batten validate` before they are committed; a fill the grammar rejects is a failed synthesis, and that verdict belongs in the loop rather than in review.
   * `storypole verify` captures one `Silver` trace per verified head into `<canonical .gaugeblock>/spool/outbox.jsonl`, keyed on `(task_key, head_commit_sha)`. Do not write traces from `outfeed gate`: it is a repeatable check, so writing there duplicates traces for unfinished work.
   * `joiner fill` (GB-167) is the path to `Gold` DPO pairs; it is opt-in because it spends inference tokens.

6. **Implement Modularly (Tier 1 Iteration):** Write small, single-purpose files (strictly under 250 LOC) with explicit doc comments (`///`). Use Tier 1 checks (`cargo check -p <crate>`) for rapid iteration.
7. **Capture Unrelated Findings in `storypole`:** If you uncover an out-of-scope bug, edge case, or debt, defer it immediately via `storypole defer`.
8. **Commit Atomically (Tier 2 Gate):** Verify affected crate (`cargo fmt --check -p <crate>`, `cargo clippy -p <crate>`, `cargo nextest run -p <crate>`). Commit with Conventional Commits (`<type>(<scope>): <summary>`).
9. **Verify & Close Task (Tier 3 Gate):** Run full workspace verification (`cargo nextest run --workspace` + `cargo test --doc --workspace`). Release lease and certify completion with `storypole verify <KEY>` or `storypole handoff`.
