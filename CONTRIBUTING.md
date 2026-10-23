# Contributing to `gaugeblock`

> Standards for atomic commits, conventional commit messages, tiered verification, and semantic versioning across the 9 `gaugeblock` repositories.

---

## 1. Environment Setup & Dogfooding Workflow

The `gaugeblock` suite is designed to be dogfooded end-to-end using the installed CLI binaries and MCP servers.

1. **Install the Suite (or Profile):**
   Run `./scripts/install-suite.sh` (or with `--profile minimal` / `--profile core`) from the repository root to compile and install binaries into `~/.cargo/bin`. The script automatically detects installed tools and updates Antigravity's `mcp_config.json`.
2. **Prohibition on Target Directory Execution:**
   Do **not** invoke binaries directly from local `target/debug/` or `target/release/` paths during operational workflows or agent interactions. Binaries must be run from `PATH` or MCP. The local `target/` directory is strictly reserved for `cargo test` and compiler checks during active development.
3. **Out-of-Scope Defect Registration:**
   Never fix unrelated bugs or issues inline during an active task. Always defer them immediately into `storypole`:
   ```bash
   storypole defer --kind bug --symbol "<crate::path>" --title "<summary>"
   ```

---

## 2. Tiered Verification Matrix

To keep developer and agent velocity high while preventing build breakages, all code changes follow a 4-tier verification matrix. Run only the tier required for your current workflow stage.

| Tier | Gate | Scope | Commands (`cargo-nextest` preferred) | When to Run |
|---|---|---|---|---|
| **Tier 1** | **Inner Loop** | Active crate / file | `cargo check -p <crate>`<br>`cargo nextest run -p <crate> --lib <submodule_or_test>` | Rapid iteration while writing functions or tests (<2s). |
| **Tier 2** | **Commit Gate** | Affected crate(s) | `cargo fmt --check -p <crate>`<br>`cargo clippy -p <crate> --all-targets -- -D warnings`<br>`cargo nextest run -p <crate>` | **Mandatory before creating an atomic commit.** |
| **Tier 3** | **Task Gate** | Repository workspace | `cargo fmt --all -- --check`<br>`cargo clippy --workspace --all-targets -- -D warnings`<br>`cargo nextest run --workspace`<br>`cargo test --doc --workspace` | **Mandatory before closing a task or marking `Verified` in `storypole`.** |
| **Tier 4** | **Release Gate** | Cross-repo meta-harness | Workspace tests + E2E integration suites + `CONTRACTS.md` wire checks | **Mandatory before bumping versions or pushing `vX.Y.Z` git tags.** |

---

## 3. Atomic Commits & Bisect Invariance

A healthy git history enables reliable automated bisecting, clean reverts, and readable reviews.

1. **Single Logical Responsibility:**
   * Each commit must represent exactly one logical change (e.g. one bug fix, one refactoring step, one sub-crate addition, or one documentation update).
   * **Do not bundle unrelated changes.** If you refactor a trait while adding a new feature and fixing a typo in another crate, split them into three distinct commits.
2. **Bisect-Safe Invariant:**
   * Every commit must pass **Tier 2 verification** on the modified crate.
   * Never commit code that fails compilation or breaks existing unit tests.
3. **Staging Hygiene:**
   * Stage specific files intentionally (`git add crates/<name>-core/src/...`).
   * Avoid indiscriminate `git add .` or `git commit -a` to prevent accidental inclusion of scratch files, local keys, or untracked test fixtures.
   * Always verify `git diff --staged` before finalizing the commit.

---

## 4. Conventional Commit Specification

All commit messages in `gaugeblock` must adhere strictly to [Conventional Commits v1.0.0](https://www.conventionalcommits.org/en/v1.0.0/).

### Format

```text
<type>(<scope>): <short imperative summary>

[optional body: explain *why* this change is necessary and any context]

[optional footer(s): Task IDs, BREAKING CHANGES, Co-authors]
```

### Allowed Types

| Type | Description |
|---|---|
| `feat` | New feature or user-visible capability. |
| `fix` | Bug fix. |
| `refactor` | Code change that neither fixes a bug nor adds a feature. |
| `perf` | Code change that improves performance. |
| `test` | Adding missing tests or correcting existing tests. |
| `docs` | Documentation updates only. |
| `style` | Formatting, whitespace, or naming consistency (no functional changes). |
| `chore` | Maintenance tasks, workspace configs, toolchain tweaks, dependency updates. |
| `ci` | CI/CD pipelines, test runner configs, release scripts. |

### Scopes

Scopes must reflect the crate or harness boundary being modified:
* **Crate-level:** `(storypole-core)`, `(storypole-cli)`, `(storypole-mcp)`, `(miter-engine)`, `(sawhorse-core)`, etc.
* **Harness-level:** `(workspace)`, `(contracts)`, `(roadmap)`, `(deps)`.

### Subject Line Rules

* Use the imperative, present tense: `"add"`, `"fix"`, `"refactor"` (not `"added"`, `"fixing"`, `"fixes"`).
* Start with a lowercase character.
* Do not end with a period.
* Keep the entire subject line under 72 characters.

### Footers & Storypole Integration

When working against a `storypole` task or GitHub issue, include the key in the footer:

```text
feat(storypole-core): implement append-only ledger writer

Write new events to .storypole/ledger.jsonl with deterministic
JSON serialization and newline delimiters.

Task: SP-14
```

For breaking wire schema or trait changes:

```text
feat(contracts): add TicketKey sequential identifier to TaskNode

BREAKING CHANGE: TaskNode wire contract now requires ticket_key string.
```

---

## 5. Semantic Versioning & Release Tagging

`gaugeblock` repositories adhere to [Semantic Versioning 2.0.0](https://semver.org/) (`MAJOR.MINOR.PATCH[-PRERELEASE]`).

### Workspace Synchronization

In every repository, the root `Cargo.toml` acts as the single source of truth:

```toml
[workspace.package]
version = "0.0.1-alpha.1"
```

All member crates (`crates/<name>-core`, `crates/<name>-cli`, etc.) inherit the workspace version:

```toml
[package]
name = "<name>-core"
version.workspace = true
```

### Release Lifecycle

* `0.0.1-alpha.X`: Harness bootstrap & early pre-alpha iterations.
* `0.1.0-beta.X`: Active dogfooding phase per `ROADMAP.md`.
* `1.0.0`: Production-ready release with stable wire contracts.

### Git Tagging Format

Release tags must always follow the exact pattern `v<version>`:

```bash
git tag -a v0.0.1-alpha.1 -m "chore(release): release v0.0.1-alpha.1"
git push origin v0.0.1-alpha.1
```

### Version Bump Criteria

* **PATCH (`0.0.x`):** Backwards-compatible internal fixes, refactoring, or documentation improvements.
* **MINOR (`0.x.0`):** Backwards-compatible new features, traits, or additive contract fields.
* **MAJOR (`x.0.0`):** Incompatible breaking changes to traits or JSON wire contracts in `CONTRACTS.md`.
