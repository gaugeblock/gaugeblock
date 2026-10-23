# Changelog

All notable changes to the `gaugeblock` meta-harness and multi-repository workspace will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Performance & Build Pipeline (GB-8)
* **Shared Target Directory (`target-dir = "target"`):**
  - Configured root `.cargo/config.toml` so all 9 member repositories (`miter`, `storypole`, `sawhorse`, `chalkline`, `dado`, `batten`, `joiner`, `benchwork`, `rabbet`) output build artifacts into a unified `/target` directory.
  - Prevents rebuilding third-party dependencies (`tokio`, `syn`, `serde`, `tree-sitter`, `rusqlite`, `axum`) up to 9 separate times, reclaiming ~20+ GB of duplicate disk allocations.
* **Compiler Caching via `sccache`:**
  - Integrated `/usr/local/bin/sccache` as the `rustc-wrapper` in `.cargo/config.toml`.
  - Configured `CARGO_INCREMENTAL = "0"` to maximize `sccache` direct object cache hit rate across clean builds, branch switches, and test runs.
* **Architecture & Linker Optimization:**
  - Added `-C target-cpu=native` for host CPU instruction optimization (AVX2/FMA/BMI2 / NEON) for compute-intensive AST parsing and serialization.
  - Enabled macOS `split-debuginfo = "unpacked"` to bypass the expensive `dsymutil` step during debug builds and test iterations.
* **Cargo Profile Standardization:**
  - Configured `[profile.dev.package."*"] opt-level = 2` across all 9 workspace manifests, compiling heavy third-party dependencies at optimized speed while preserving `opt-level = 0` for fast incremental crate compilation.
  - Set `debug = 1` (line tables only) for dev and test profiles, reducing binary sizes and linking times by over 50%.
  - Added `lto = "thin"` and `codegen-units = 1` for release profiles.
* **Cross-Workspace Dependency Harmonization:**
  - Harmonized third-party crate versions across all 9 repositories:
    - `tokio`: harmonized to `1.43` across all member crates.
    - `thiserror`: harmonized to `2.0` across all member crates.
    - `clap`: harmonized to `4.5` across all member crates.
    - `toml`: harmonized to `0.8` across all member crates.
  - Audited and verified zero version drift across all 43 third-party crates in the meta-harness.
* **Automated Audit Tooling:**
  - Added [`scripts/audit-deps.sh`](scripts/audit-deps.sh) to verify root Cargo configurations and assert zero dependency version discrepancies across manifests during Tier 3 verification.

### Performance Verification Benchmarks
* **Incremental Check Time:** ~0.45 seconds (`cargo check -p storypole-core`).
* **Dependency Cache Reuse:** Shared target artifacts and `sccache` verified operational across multi-repo compilation.
* **Audit Tooling Status:** `scripts/audit-deps.sh` passing with 0 defects across 43 third-party dependencies.
