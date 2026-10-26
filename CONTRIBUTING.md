# Contributing to `gaugeblock`

> Standards for atomic commits, conventional commit messages, tiered verification, and semantic versioning across the 10 `gaugeblock` repositories.

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

`gaugeblock` repositories adhere strictly to [Semantic Versioning 2.0.0](https://semver.org/) (`MAJOR.MINOR.PATCH[-PRERELEASE]`).

### Workspace Synchronization vs. Meta-Harness Independence

The `gaugeblock` ecosystem uses a **federated independent repository model**:
1. **Intra-Repository Lockstep:** In every individual repository (`miter`, `storypole`, `benchwork`, etc.), its root `Cargo.toml` acts as the single source of truth for all member crates:
   ```toml
   [workspace.package]
   version = "0.1.0-beta.2"
   ```
   All member crates (`crates/<name>-core`, `crates/<name>-cli`, `crates/<name>-mcp`, etc.) inherit this version via `version.workspace = true`.
2. **Meta-Harness Independence:** Repositories evolve and release on their own cadence. For example, `storypole` may advance to `0.1.0-beta.11` while `benchwork` is on `0.1.0-beta.3` and `miter` is on `0.1.0-alpha.2`.
3. **Cross-Repository Dependencies:** Downstream crates declare minimum required version constraints (e.g., `storypole-core = ">=0.1.0-beta.1, <0.2.0"` or `^0.1.0-beta.1`). They only bump this constraint when upgrading to consume newly introduced APIs or schemas.

Whenever an individual repository's workspace version is incremented:
1. **Internal Inter-Crate Dependencies:** Update all sibling path dependency requirements (e.g. `<name>-core = { path = "...", version = "0.1.0-beta.2" }`) in member `Cargo.toml` files in tandem.
2. **Web Frontends & Badges:** Update `web/package.json` and any user-facing version badges (such as in visual headers) in lockstep with the Rust manifests.
3. **Lockfile Generation:** Run `cargo check --workspace` inside the repository to regenerate `Cargo.lock` with the synchronized versions.

### Release Lifecycle & Pre-Release Increments

* `0.0.1-alpha.X`: Early pre-alpha iterations (`miter`).
* `0.1.0-beta.X`: Active dogfooding phase per `ROADMAP.md`.
  * During the pre-release development phase, backwards-compatible fixes, additions, and enhancements increment the pre-release patch number (`0.1.0-beta.1` -> `0.1.0-beta.2` -> `0.1.0-beta.3`).
  * Additive schema or trait modifications that stay within the beta phase bump the pre-release identifier.
  * Incompatible breaking changes to traits or JSON wire contracts in `CONTRACTS.md` require bumping that repository's minor base (`0.2.0-beta.1`). Consumer crates bump their versions independently when adopting the updated contract.
* `1.0.0`: Production-ready release with stable wire contracts.

### Git Tagging & Release Format

* **Per-Repository Tags:** Individual repositories tag releases in their local Git history using annotated tags matching their package version:
  ```bash
  git commit -m "chore(release): release v0.1.0-beta.2"
  git tag -a v0.1.0-beta.2 -m "v0.1.0-beta.2"
  git push origin main --tags
  ```
* **Meta-Harness Snapshot Tags:** The root meta-harness (`neurosymbolic-suite`) has no Cargo package version; it tags certified ecosystem integration passes:
  ```bash
  git tag -a suite-v0.1.0-beta.1 -m "suite-v0.1.0-beta.1 ecosystem release"
  ```

### Changelog Architecture

* **Per-Repository Changelogs:** Each repository maintains its own `CHANGELOG.md` detailing crate-level changes per release (`v<version>`).
* **Meta-Harness Changelog:** The root `CHANGELOG.md` records suite-level milestones, cross-cutting contract evolution, and ecosystem compatibility matrices.

### Post-1.0 Version Bump Criteria

* **PATCH (`1.0.x`):** Backwards-compatible internal fixes, refactoring, or documentation improvements.
* **MINOR (`1.x.0`):** Backwards-compatible new features, traits, or additive contract fields.
* **MAJOR (`x.0.0`):** Incompatible breaking changes to traits or JSON wire contracts in `CONTRACTS.md`.
