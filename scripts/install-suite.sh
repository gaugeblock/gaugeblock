#!/usr/bin/env bash
# scripts/install-suite.sh — Deterministic builder & installer for the gaugeblock suite
# Delegates to `outfeed install` with bootstrap fallback and Antigravity MCP sync.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Show help if requested
for arg in "$@"; do
  if [ "$arg" == "-h" ] || [ "$arg" == "--help" ]; then
    if command -v outfeed >/dev/null 2>&1; then
      outfeed install --help
    else
      echo "scripts/install-suite.sh — Delegates to outfeed install --all"
      echo "Run with --force to force reinstall, or --no-sync-mcp to skip MCP config sync."
    fi
    exit 0
  fi
done

# Bootstrap outfeed if not yet in PATH
if ! command -v outfeed >/dev/null 2>&1; then
  echo "--> Bootstrapping outfeed from ${WORKSPACE_ROOT}/outfeed/crates/outfeed-cli..."
  cargo install --path "${WORKSPACE_ROOT}/outfeed/crates/outfeed-cli" --target-dir "${WORKSPACE_ROOT}/target" --force
fi

# Delegate installation to outfeed
echo "--> Delegating suite installation to outfeed..."
outfeed install --all "$@"

# Sync Antigravity MCP config
SYNC_MCP=true
for arg in "$@"; do
  if [ "$arg" == "--no-sync-mcp" ]; then
    SYNC_MCP=false
    break
  fi
done

if [ "$SYNC_MCP" = true ]; then
  echo ""
  echo "--> Syncing Antigravity MCP configs with installed tools..."
  MCP_TOOLS=("miter" "storypole" "chalkline" "dado" "batten" "joiner" "benchwork" "outfeed")
  MCP_JSON="{\n  \"mcpServers\": {\n"
  FIRST=true
  for bin_name in "${MCP_TOOLS[@]}"; do
    if command -v "${bin_name}" >/dev/null 2>&1; then
      if [ "$FIRST" = true ]; then
        FIRST=false
      else
        MCP_JSON="${MCP_JSON},\n"
      fi
      MCP_JSON="${MCP_JSON}    \"${bin_name}\": {\n      \"command\": \"${bin_name}\",\n      \"args\": [\"mcp\"]\n    }"
    fi
  done
  MCP_JSON="${MCP_JSON}\n  }\n}\n"

  CONFIG_TARGETS=(
    "${HOME}/.gemini/antigravity/mcp_config.json"
    "${HOME}/.gemini/config/mcp_config.json"
    "${WORKSPACE_ROOT}/.agents/mcp_config.json"
  )
  for target in "${CONFIG_TARGETS[@]}"; do
    mkdir -p "$(dirname "$target")"
    printf "%b" "$MCP_JSON" > "$target"
    echo "  Updated $target"
  done
fi

echo ""
echo "🎉 gaugeblock suite installation and MCP sync complete!"
