#!/usr/bin/env bash
set -euo pipefail

# scripts/publish-crates.sh — Root harness wrapper to publish repository crates
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

SUITE=(
  "miter"
  "storypole"
  "sawhorse"
  "chalkline"
  "dado"
  "batten"
  "joiner"
)

target="${1:-}"

if [[ "$target" == "all" ]]; then
  shift
  echo "================================================================================"
  echo "🚀 Publishing entire gaugeblock suite in topological order"
  echo "================================================================================"
  for repo in "${SUITE[@]}"; do
    if [[ -f "${ROOT_DIR}/${repo}/scripts/publish.sh" ]]; then
      echo ""
      echo ">>> Executing ${repo}/scripts/publish.sh $@"
      "${ROOT_DIR}/${repo}/scripts/publish.sh" "$@"
    fi
  done
  echo ""
  echo "🎉 Entire gaugeblock suite publication sequence complete!"
  exit 0
fi

# If target is a known repo name or directory
if [[ -n "$target" && -d "${ROOT_DIR}/${target}" && -f "${ROOT_DIR}/${target}/scripts/publish.sh" ]]; then
  shift
  exec "${ROOT_DIR}/${target}/scripts/publish.sh" "$@"
elif [[ -f "./scripts/publish.sh" ]]; then
  exec "./scripts/publish.sh" "$@"
elif [[ -f "../scripts/publish.sh" ]]; then
  exec "../scripts/publish.sh" "$@"
else
  echo "Usage: $0 [miter|storypole|sawhorse|chalkline|dado|batten|joiner|all] [--dry-run]"
  echo ""
  echo "Or run directly inside any repository:"
  echo "  ./scripts/publish.sh [--dry-run]"
  exit 1
fi
