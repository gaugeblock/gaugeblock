#!/usr/bin/env bash
# scripts/install-suite.sh — Deterministic builder & installer for the gaugeblock suite
#
# Supports profiles:
#   --profile all     (default) All 9 tools
#   --profile core    Core 7 agent synthesis tools (miter, storypole, sawhorse, chalkline, dado, batten, joiner)
#   --profile minimal Minimal bootstrap pair (miter, storypole)
#
# Specific tools can also be installed by name:
#   ./scripts/install-suite.sh miter dado
#
# Automatically syncs active MCP servers to Antigravity mcp_config.json.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

PROFILE="all"
BUILD_MODE="release"
PROFILE_FLAG=""
SYNC_MCP=true
FORCE=false
SELECTED_TOOLS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --debug)
      BUILD_MODE="debug"
      PROFILE_FLAG="--debug"
      shift
      ;;
    --force|-f)
      FORCE=true
      shift
      ;;
    --profile)
      PROFILE="$2"
      shift 2
      ;;
    --no-sync-mcp)
      SYNC_MCP=false
      shift
      ;;
    --help|-h)
      echo "Usage: $0 [OPTIONS] [TOOL_NAMES...]"
      echo ""
      echo "Options:"
      echo "  --profile <all|core|minimal>  Select tool preset (default: all)"
      echo "  --debug                       Build debug instead of release"
      echo "  --force, -f                   Force rebuild and install even if versions match"
      echo "  --no-sync-mcp                 Skip updating Antigravity mcp_config.json"
      echo "  -h, --help                    Print help"
      exit 0
      ;;
    *)
      SELECTED_TOOLS+=("$1")
      shift
      ;;
  esac
done

# Canonical tool map: name:relative_path:has_mcp
ALL_CRATES=(
  "miter:miter:yes"
  "storypole:storypole/crates/storypole-cli:yes"
  "sawhorse:sawhorse/crates/sawhorse-cli:no"
  "chalkline:chalkline/crates/chalkline-cli:yes"
  "dado:dado/crates/dado-cli:yes"
  "batten:batten/crates/batten-cli:yes"
  "joiner:joiner/crates/joiner-cli:yes"
  "benchwork:benchwork/crates/benchwork-cli:yes"
  "rabbet:rabbet/crates/rabbet-cli:no"
)

# Resolve target crates list
TARGET_CRATES=()
if [ ${#SELECTED_TOOLS[@]} -gt 0 ]; then
  for sel in "${SELECTED_TOOLS[@]}"; do
    matched=false
    for item in "${ALL_CRATES[@]}"; do
      bin_name="${item%%:*}"
      if [ "$bin_name" == "$sel" ]; then
        TARGET_CRATES+=("$item")
        matched=true
        break
      fi
    done
    if [ "$matched" = false ]; then
      echo "❌ Unknown tool: $sel. Available: miter storypole sawhorse chalkline dado batten joiner benchwork rabbet"
      exit 1
    fi
  done
else
  case "$PROFILE" in
    minimal)
      TARGET_CRATES=("${ALL_CRATES[0]}" "${ALL_CRATES[1]}")
      ;;
    core)
      TARGET_CRATES=("${ALL_CRATES[@]:0:7}")
      ;;
    all)
      TARGET_CRATES=("${ALL_CRATES[@]}")
      ;;
    *)
      echo "❌ Invalid profile '$PROFILE'. Choose from: minimal, core, all"
      exit 1
      ;;
  esac
fi

get_target_version() {
  local crate_dir="$1"
  python3 -c "
import os, tomllib
curr = os.path.abspath('$crate_dir')
with open(os.path.join(curr, 'Cargo.toml'), 'rb') as f:
    d = tomllib.load(f)
v = d.get('package', {}).get('version')
if isinstance(v, str):
    print(v)
    exit(0)
ws_v = d.get('workspace', {}).get('package', {}).get('version')
if ws_v:
    print(ws_v)
    exit(0)
p = os.path.dirname(os.path.dirname(curr))
p_manifest = os.path.join(p, 'Cargo.toml')
if os.path.exists(p_manifest):
    with open(p_manifest, 'rb') as f:
        pd = tomllib.load(f)
    ws_v = pd.get('workspace', {}).get('package', {}).get('version')
    if ws_v:
        print(ws_v)
        exit(0)
" 2>/dev/null || true
}

echo "======================================================================"
echo " gaugeblock Suite Installer (${BUILD_MODE} profile)"
echo " Profile: ${PROFILE} | Tools: ${#TARGET_CRATES[@]}"
echo "======================================================================"

for item in "${TARGET_CRATES[@]}"; do
  IFS=":" read -r bin_name crate_rel_path has_mcp <<< "$item"
  crate_abs_path="${WORKSPACE_ROOT}/${crate_rel_path}"
  target_ver=$(get_target_version "${crate_abs_path}")

  if [ "$FORCE" = false ] && command -v "${bin_name}" >/dev/null 2>&1; then
    installed_ver=$({ "${bin_name}" --version 2>/dev/null || true; } | awk '{print $2}')
    if [ -n "${installed_ver}" ] && [ -n "${target_ver}" ] && [ "${installed_ver}" == "${target_ver}" ]; then
      echo "--> ${bin_name} (${installed_ver}) already installed and up to date. Skipping (pass --force to reinstall)."
      continue
    fi
  fi

  echo "--> Installing ${bin_name} (${target_ver:-unknown}) from ${crate_rel_path}..."
  if [ -n "${PROFILE_FLAG}" ]; then
    cargo install --path "${crate_abs_path}" --target-dir "${WORKSPACE_ROOT}/target" --force --debug
  else
    cargo install --path "${crate_abs_path}" --target-dir "${WORKSPACE_ROOT}/target" --force
  fi
done

echo ""
echo "======================================================================"
echo " Verifying Installed Binaries in PATH"
echo "======================================================================"
printf "%-14s | %-12s | %-40s\n" "BINARY" "STATUS" "VERSION"
echo "----------------------------------------------------------------------"

ALL_OK=true
for item in "${TARGET_CRATES[@]}"; do
  bin_name="${item%%:*}"
  if command -v "${bin_name}" >/dev/null 2>&1; then
    ver_output=$({ "${bin_name}" --version 2>/dev/null || true; } | head -n 1)
    if [ -z "$ver_output" ]; then
      ver_output="installed ($(which "${bin_name}"))"
    fi
    printf "%-14s | %-12s | %-40s\n" "${bin_name}" "✅ OK" "${ver_output}"
  else
    printf "%-14s | %-12s | %-40s\n" "${bin_name}" "❌ NOT FOUND" "Missing from PATH"
    ALL_OK=false
  fi
done
echo "----------------------------------------------------------------------"

if [ "$SYNC_MCP" = true ]; then
  echo ""
  echo "--> Syncing Antigravity MCP configs with installed tools..."
  MCP_JSON="{\n  \"mcpServers\": {\n"
  FIRST=true
  for item in "${ALL_CRATES[@]}"; do
    IFS=":" read -r bin_name crate_rel_path has_mcp <<< "$item"
    if [ "$has_mcp" == "yes" ] && command -v "${bin_name}" >/dev/null 2>&1; then
      if [ "$FIRST" = true ]; then
        FIRST=false
      else
        MCP_JSON="${MCP_JSON},\n"
      fi
      MCP_JSON="${MCP_JSON}    \"${bin_name}\": {\n      \"command\": \"${bin_name}\",\n      \"args\": [\"mcp\"]\n    }"
    fi
  done
  MCP_JSON="${MCP_JSON}\n  }\n}\n"

  # Write to global and workspace config locations
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

if [ "${ALL_OK}" = true ]; then
  echo ""
  echo "🎉 Selected gaugeblock tools successfully installed and verified!"
else
  echo ""
  echo "⚠️ Some binaries failed to install or are not in PATH (~/.cargo/bin)."
  exit 1
fi
