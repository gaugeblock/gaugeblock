#!/usr/bin/env bash
set -euo pipefail

# scripts/audit-deps.sh — Cross-workspace dependency harmonization and cargo config auditor
# Enforces that all 9 gaugeblock repositories share consistent third-party crate versions.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "================================================================================"
echo " [gaugeblock] Cross-Workspace Dependency & Cargo Cache Auditor"
echo "================================================================================"

export ROOT_DIR

python3 - <<'EOF'
import sys
import glob
import tomllib
import os

root_dir = os.environ.get("ROOT_DIR", ".")

# 1. Verify root .cargo/config.toml
cargo_config_path = os.path.join(root_dir, ".cargo", "config.toml")
if not os.path.exists(cargo_config_path):
    print("❌ FAIL: Root .cargo/config.toml is missing!")
    sys.exit(1)

with open(cargo_config_path, "rb") as f:
    cfg = tomllib.load(f)

build_cfg = cfg.get("build", {})
env_cfg = cfg.get("env", {})

errors = []
if build_cfg.get("target-dir") != "target":
    errors.append("build.target-dir is not set to 'target'")
if build_cfg.get("rustc-wrapper") != "sccache":
    errors.append("build.rustc-wrapper is not set to 'sccache'")
if env_cfg.get("CARGO_INCREMENTAL") != "0":
    errors.append("env.CARGO_INCREMENTAL is not set to '0'")

if errors:
    print("❌ Cargo configuration defects detected in .cargo/config.toml:")
    for err in errors:
        print(f"   - {err}")
    sys.exit(1)

print("✅ Root .cargo/config.toml verification passed (sccache, shared target-dir, incremental=0)")

# 2. Audit all Cargo.toml files for dependency version drift
suite_prefixes = (
    "miter", "storypole", "sawhorse", "chalkline", "dado",
    "batten", "joiner", "benchwork", "rabbet", "outfeed"
)

deps = {}
all_cargo_files = sorted(glob.glob(os.path.join(root_dir, "**/Cargo.toml"), recursive=True))

for path in all_cargo_files:
    if "/target/" in path or "/reserve-staging/" in path:
        continue
    rel_path = os.path.relpath(path, root_dir)
    try:
        with open(path, "rb") as f:
            data = tomllib.load(f)
    except Exception as e:
        print(f"❌ Failed to parse {rel_path}: {e}")
        sys.exit(1)

    all_d = {}
    if "dependencies" in data:
        all_d.update(data["dependencies"])
    if "workspace" in data and "dependencies" in data["workspace"]:
        all_d.update(data["workspace"]["dependencies"])

    for crate_name, spec in all_d.items():
        if any(crate_name.startswith(p) for p in suite_prefixes):
            continue
        if isinstance(spec, str):
            ver = spec
        elif isinstance(spec, dict):
            ver = spec.get("version", "workspace" if spec.get("workspace") else "unknown")
        else:
            ver = str(spec)
        deps.setdefault(crate_name, {}).setdefault(ver, []).append(rel_path)

discrepancies = {}
for crate_name, versions in sorted(deps.items()):
    explicit_versions = {ver: paths for ver, paths in versions.items() if ver != "workspace"}
    if len(explicit_versions) > 1:
        discrepancies[crate_name] = explicit_versions

if discrepancies:
    print(f"\n❌ FAIL: Found {len(discrepancies)} crates with version discrepancies:")
    for crate_name, versions in discrepancies.items():
        print(f"   • Crate '{crate_name}':")
        for ver, paths in versions.items():
            print(f"       version {ver:<6} -> {len(paths)} manifest(s) (e.g. {paths[0]})")
    sys.exit(1)

print(f"✅ All {len(deps)} third-party dependencies are cleanly harmonized across all 9 workspaces.")
print("================================================================================")
print(" All build optimization gates PASSED.")
print("================================================================================")
EOF
