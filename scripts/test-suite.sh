#!/usr/bin/env bash
set -euo pipefail

# scripts/test-suite.sh — Suite-wide verification test runner for gaugeblock
# Runs nextest across all 9 member repositories with doc-tests.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

REPOS=(
  "storypole"
  "sawhorse"
  "chalkline"
  "dado"
  "batten"
  "joiner"
  "benchwork"
  "rabbet"
  "miter"
)

target_repo="${1:-all}"

runner="cargo"
if command -v cargo-nextest >/dev/null 2>&1; then
  runner="nextest"
fi

echo "================================================================================"
echo " [gaugeblock] Test Suite Runner (runner: ${runner})"
echo "================================================================================"

run_repo_tests() {
  local repo="$1"
  local dir="${ROOT_DIR}/${repo}"

  if [[ ! -d "$dir" ]]; then
    echo "⚠️  Skipping ${repo} (directory not found)"
    return 0
  fi

  echo "--------------------------------------------------------------------------------"
  echo " Testing: ${repo} ..."
  echo "--------------------------------------------------------------------------------"

  pushd "$dir" >/dev/null

  if [[ "$runner" == "nextest" ]]; then
    # Nextest execution
    cargo nextest run --workspace --all-targets --no-tests pass
    # Doc tests (nextest skips doctests by design)
    cargo test --doc --workspace
  else
    cargo test --workspace --all-targets
    cargo test --doc --workspace
  fi

  popd >/dev/null
  echo "✅ ${repo} tests passed"
}

if [[ "$target_repo" == "all" ]]; then
  for repo in "${REPOS[@]}"; do
    run_repo_tests "$repo"
  done
else
  run_repo_tests "$target_repo"
fi

echo "================================================================================"
echo " ✅ All requested test suites passed successfully!"
echo "================================================================================"
