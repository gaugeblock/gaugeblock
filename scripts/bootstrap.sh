#!/usr/bin/env bash
# scripts/bootstrap.sh — Meta-harness developer environment bootstrap
#
# Clones suite repositories, resolves dependencies, compiles and installs
# binaries to ~/.cargo/bin, and synchronizes Antigravity MCP server configs.
#
# Usage:
#   ./scripts/bootstrap.sh [OPTIONS]
#
# Options:
#   --protocol <ssh|https>   Git protocol for cloning remotes (default: ssh)
#   --locked                 Align repositories to commits pinned in suite.lock
#   --no-install             Clone repositories without compiling/installing suite binaries
#   --no-sync-mcp            Skip syncing Antigravity MCP server configs
#   --dry-run                Simulate clone and bootstrap operations without executing
#   --json                   Emit structured JSON output
#   -h, --help               Show this help message

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

show_help() {
  cat <<'EOF'
gaugeblock Meta-Harness Bootstrap

Usage:
  ./scripts/bootstrap.sh [OPTIONS]

Options:
  --protocol <ssh|https>   Git remote protocol (default: ssh)
  --locked                 Pin checkouts to exact commits in suite.lock
  --no-install             Skip compiling and installing suite binaries
  --no-sync-mcp            Skip synchronizing Antigravity MCP server configuration
  --dry-run                Simulate cloning and installation without touching disk
  --json                   Output machine-readable JSON
  -h, --help               Display this help message

EOF
}

# Parse CLI options
PROTOCOL="ssh"
LOCKED=false
INSTALL=true
SYNC_MCP=true
DRY_RUN=false
JSON=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --protocol)
      PROTOCOL="$2"
      shift 2
      ;;
    --locked)
      LOCKED=true
      shift
      ;;
    --no-install)
      INSTALL=false
      shift
      ;;
    --no-sync-mcp)
      SYNC_MCP=false
      shift
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --json)
      JSON=true
      shift
      ;;
    -h|--help)
      show_help
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      show_help
      exit 1
      ;;
  esac
done

# Verify prerequisites
if ! command -v git >/dev/null 2>&1; then
  echo "Error: git is required but not found in PATH." >&2
  exit 1
fi

if ! command -v cargo >/dev/null 2>&1; then
  echo "Error: cargo is required but not found in PATH. Install Rust from https://rustup.rs" >&2
  exit 1
fi

# Ensure seed outfeed CLI binary is available
if ! command -v outfeed >/dev/null 2>&1; then
  echo "==> Bootstrapping seed outfeed binary..."
  if [ -d "${WORKSPACE_ROOT}/outfeed" ]; then
    cargo install --path "${WORKSPACE_ROOT}/outfeed/crates/outfeed-cli" \
      --target-dir "${WORKSPACE_ROOT}/target" --force
  else
    echo "Error: outfeed directory not found at ${WORKSPACE_ROOT}/outfeed" >&2
    exit 1
  fi
fi

# Assemble outfeed clone arguments
CLONE_ARGS=("--all" "--protocol" "${PROTOCOL}")

if [ "$LOCKED" = true ]; then
  CLONE_ARGS+=("--locked")
fi

if [ "$INSTALL" = true ]; then
  CLONE_ARGS+=("--install")
fi

if [ "$SYNC_MCP" = true ]; then
  CLONE_ARGS+=("--sync-mcp")
fi

if [ "$DRY_RUN" = true ]; then
  CLONE_ARGS+=("--dry-run")
fi

if [ "$JSON" = true ]; then
  CLONE_ARGS+=("--json")
fi

# Execute clone and setup orchestration via outfeed
if [ "$JSON" = false ]; then
  echo "==> Delegating workspace orchestration to outfeed clone..."
fi

outfeed clone "${CLONE_ARGS[@]}"

if [ "$JSON" = false ] && [ "$DRY_RUN" = false ]; then
  echo ""
  echo "🎉 gaugeblock meta-harness bootstrap complete!"
  echo "Next steps:"
  echo "  - Run 'outfeed sync --status' to inspect workspace health."
  echo "  - Run 'benchwork' to launch the local AI engineering environment."
fi
