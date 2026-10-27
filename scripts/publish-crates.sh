#!/usr/bin/env bash
set -euo pipefail

# scripts/publish-crates.sh — Root harness wrapper to publish repository crates via outfeed
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

target="${1:-}"

if [[ "$target" == "all" || -z "$target" ]]; then
  if [[ "$target" == "all" ]]; then
    shift
  fi
  exec outfeed publish --all "$@"
fi

# If target is a specific repository name
if [[ -d "${ROOT_DIR}/${target}" ]]; then
  shift
  exec outfeed publish "${target}" "$@"
fi

echo "Usage: $0 [all|<repo-name>] [--dry-run] [--registry <name>] [--delay-secs <n>]"
exit 1
