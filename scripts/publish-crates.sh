#!/usr/bin/env bash
set -euo pipefail

# scripts/publish-crates.sh — Root harness wrapper to publish repository crates
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

target="${1:-}"

# If target is a known repo name or directory
if [[ -n "$target" && -d "${ROOT_DIR}/${target}" && -f "${ROOT_DIR}/${target}/scripts/publish.sh" ]]; then
  shift
  exec "${ROOT_DIR}/${target}/scripts/publish.sh" "$@"
elif [[ -f "./scripts/publish.sh" ]]; then
  exec "./scripts/publish.sh" "$@"
elif [[ -f "../scripts/publish.sh" ]]; then
  exec "../scripts/publish.sh" "$@"
else
  echo "Usage: $0 [storypole|sawhorse|miter|chalkline] [--dry-run]"
  echo ""
  echo "Or run directly inside any repository:"
  echo "  ./scripts/publish.sh [--dry-run]"
  exit 1
fi
