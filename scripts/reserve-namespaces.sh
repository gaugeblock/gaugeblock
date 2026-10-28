#!/usr/bin/env bash
set -euo pipefail

GH_OWNER="gaugeblock"
AUTHOR="Colin Wolff"
AUTHOR_EMAIL="1562545+colinwolff@users.noreply.github.com"
LICENSE="Apache-2.0"
UA="gaugeblock-reservations/0.1 (https://gaugeblock.dev)"

PROJECTS=(
  "storypole|Git-native SQLite and JSONL backlog, task DAG, and MCP memory store for AI coding agents."
  "sawhorse|Provider-agnostic nimble LLM runtime supporting embedded Candle, local GGUF, and OpenAI-compatible APIs."
  "chalkline|Interactive specification planner, ambiguity resolver, and topological task DAG compiler."
  "dado|Deterministic polyglot AST pattern engine with composable Typed Holes."
  "batten|Dynamic variable-scope to Context-Free Grammar (GBNF/Lark) compiler and token mask generator."
  "joiner|Neurosymbolic code synthesis orchestrator uniting deterministic AST templates with constrained LLMs."
  "benchwork|Modular visual workbench UI and local daemon for neurosymbolic code synthesis and DAG inspection."
  "rabbet|AST-anonymized telemetry corpus hub and open-weight micro-model training foundry."
  "outfeed|Neurosymbolic release gate, AST drift inspector, and changelog synthesizer for the gaugeblock suite."
)

SUFFIXES=("" "-core" "-cli" "-mcp")
cmd="${1:-check}"
extra_flag="${2:-}"

# Helper function to check if a specific crate is already on crates.io
crate_exists() {
  local crate_name="$1"
  local code
  code=$(curl -s -A "$UA" -o /dev/null -w "%{http_code}" "https://crates.io/api/v1/crates/${crate_name}")
  [[ "$code" == "200" ]]
}

# Helper function to extract wait seconds from a crates.io 429 response
parse_429_wait_seconds() {
  local output="$1"
  python3 -c "
import sys, re, time
from email.utils import parsedate_to_datetime
from datetime import datetime

text = sys.stdin.read()
now = time.time()

# 1. Match RFC 2822 date from crates.io (e.g. 'try again after Thu, 22 Oct 2026 03:50:25 GMT and see...')
m = re.search(r'try again after\s+([A-Za-z]{3},\s+\d{1,2}\s+[A-Za-z]{3}\s+\d{4}\s+\d{2}:\d{2}:\d{2}\s+[A-Za-z0-9_+]+)', text, re.I)
if m:
    try:
        dt = parsedate_to_datetime(m.group(1))
        diff = int(dt.timestamp() - now)
        print(max(diff + 5, 5))
        sys.exit(0)
    except Exception:
        pass

# 2. Match seconds/minutes directly (e.g. 'try again after 120 seconds')
m = re.search(r'try again after\s+(\d+)\s*(s|sec|second|seconds)', text, re.I)
if m:
    print(int(m.group(1)) + 5)
    sys.exit(0)
m = re.search(r'try again after\s+(\d+)\s*(m|min|minute|minutes)', text, re.I)
if m:
    print(int(m.group(1)) * 60 + 5)
    sys.exit(0)

# 3. Match generic date format before 'and see', 'or email', '.', newline, etc.
m = re.search(r'try again after\s+(.+?)(?:\s+(?:and|or)\b|\.|\n|$)', text, re.I)
if m:
    date_str = m.group(1).strip()
    try:
        dt = parsedate_to_datetime(date_str)
        diff = int(dt.timestamp() - now)
        print(max(diff + 5, 5))
        sys.exit(0)
    except Exception:
        pass
    try:
        dt = datetime.fromisoformat(date_str.replace('Z', '+00:00'))
        diff = int(dt.timestamp() - now)
        print(max(diff + 5, 5))
        sys.exit(0)
    except Exception:
        pass

# Fallback for 429 rate limit: 305s (5 min + 5s buffer)
print(305)
" <<< "$output"
}

# Helper function for live countdown during 429 cooldown
wait_for_cooldown() {
  local secs="$1"
  local remaining="$secs"
  while [ "$remaining" -gt 0 ]; do
    local mins=$(( (remaining + 59) / 60 ))
    echo "⏳ Rate limit cooldown: ~${mins}m remaining (${remaining}s)..."
    if [ "$remaining" -gt 30 ]; then
      sleep 30
      remaining=$(( remaining - 30 ))
    else
      sleep "$remaining"
      remaining=0
    fi
  done
}

if [[ "$cmd" == "check" ]]; then
  echo "🔍 Verifying crates.io availability across all 8 project families..."
  echo "--------------------------------------------------------------------------------"
  for entry in "${PROJECTS[@]}"; do
    IFS='|' read -r base desc <<< "$entry"
    printf "%-12s : " "$base"
    for suffix in "${SUFFIXES[@]}"; do
      crate="${base}${suffix}"
      if crate_exists "$crate"; then
        printf "❌ %s (TAKEN)  " "$crate"
      else
        printf "✅ %s (FREE)   " "$crate"
      fi
    done
    echo ""
  done
  echo "--------------------------------------------------------------------------------"
  echo "Next step: Run './reserve-namespaces.sh scaffold' then './reserve-namespaces.sh publish'"

elif [[ "$cmd" == "scaffold" ]]; then
  mkdir -p ./reserve-staging
  for entry in "${PROJECTS[@]}"; do
    IFS='|' read -r base desc <<< "$entry"
    repo_dir="./reserve-staging/${base}"
    echo "📦 Scaffolding ${base} (${base}, ${base}-core, ${base}-cli)..."

    mkdir -p "${repo_dir}/crates/${base}-core/src"
    mkdir -p "${repo_dir}/crates/${base}-mcp/src"
    mkdir -p "${repo_dir}/crates/${base}-cli/src"
    mkdir -p "${repo_dir}/src"

    # 1. Write comprehensive .gitignore to prevent target or temporary build artifacts
    cat << 'EOF' > "${repo_dir}/.gitignore"
# Rust build artifacts
target/
**/target/
Cargo.lock

# IDE & Editors
.vscode/
.idea/
*.iml
*.swp
*.swo

# OS artifacts
.DS_Store
Thumbs.db

# Environment & Logs
.env
.env.*
*.log
*.rs.bk
EOF

    # 2. Root README.md
    cat << EOF > "${repo_dir}/README.md"
# ${base}

> ${desc}

Part of the **gaugeblock** neurosymbolic code synthesis ecosystem. Visit [gaugeblock.dev](https://gaugeblock.dev).

*Status: v0.1.0-alpha.1 namespace reservation — active development in progress.*
EOF

    # 3. Root crate Cargo.toml with workspace membership and Rust 2024 inheritance
    cat << EOF > "${repo_dir}/Cargo.toml"
[workspace]
resolver = "3"
members = [
    ".",
    "crates/*",
]

[workspace.package]
version = "0.1.0-alpha.1"
edition = "2024"
authors = ["${AUTHOR} <${AUTHOR_EMAIL}>"]
license = "${LICENSE}"
repository = "https://github.com/${GH_OWNER}/${base}"
homepage = "https://gaugeblock.dev"
keywords = ["ast", "neurosymbolic", "codegen", "llm", "compiler"]
categories = ["development-tools", "compilers", "command-line-utilities"]

[workspace.lints.rust]
unsafe_code = "deny"
missing_debug_implementations = "warn"

[workspace.lints.clippy]
unwrap_used = "deny"
expect_used = "deny"

[package]
name = "${base}"
version.workspace = true
edition.workspace = true
authors.workspace = true
license.workspace = true
repository.workspace = true
homepage.workspace = true
keywords.workspace = true
categories.workspace = true
readme = "README.md"
description = "${desc}"

[lints]
workspace = true
EOF

    cat << EOF > "${repo_dir}/src/lib.rs"
//! # ${base}
//!
//! ${desc}
pub const VERSION: &str = env!("CARGO_PKG_VERSION");
EOF

    # 4. -core crate Cargo.toml
    cat << EOF > "${repo_dir}/crates/${base}-core/Cargo.toml"
[package]
name = "${base}-core"
version.workspace = true
edition.workspace = true
authors.workspace = true
license.workspace = true
repository.workspace = true
homepage.workspace = true
keywords.workspace = true
categories.workspace = true
description = "Core library and traits for ${base}: ${desc}"
readme = "../../README.md"

[lints]
workspace = true
EOF

    cat << EOF > "${repo_dir}/crates/${base}-core/src/lib.rs"
//! Core traits and data structures for \`${base}\`.
pub const VERSION: &str = env!("CARGO_PKG_VERSION");
EOF

    # 5. -mcp crate Cargo.toml
    cat << EOF > "${repo_dir}/crates/${base}-mcp/Cargo.toml"
[package]
name = "${base}-mcp"
version.workspace = true
edition.workspace = true
authors.workspace = true
license.workspace = true
repository.workspace = true
homepage.workspace = true
keywords.workspace = true
categories.workspace = true
description = "Model Context Protocol (MCP) stdio server for ${base}"
readme = "../../README.md"

[lints]
workspace = true
EOF

    cat << EOF > "${repo_dir}/crates/${base}-mcp/src/lib.rs"
//! Model Context Protocol (MCP) server for \`${base}\`.
pub const VERSION: &str = env!("CARGO_PKG_VERSION");
EOF

    # 6. -cli crate Cargo.toml
    cat << EOF > "${repo_dir}/crates/${base}-cli/Cargo.toml"
[package]
name = "${base}-cli"
version.workspace = true
edition.workspace = true
authors.workspace = true
license.workspace = true
repository.workspace = true
homepage.workspace = true
keywords.workspace = true
categories.workspace = true
description = "Command-line interface and MCP server for ${base}: ${desc}"
readme = "../../README.md"

[[bin]]
name = "${base}"
path = "src/main.rs"

[lints]
workspace = true
EOF

    cat << EOF > "${repo_dir}/crates/${base}-cli/src/main.rs"
fn main() {
    println!("${base} v{} (initialization stub)", env!("CARGO_PKG_VERSION"));
}
EOF
  done
  echo "✅ All 8 repositories and 24 crate stubs scaffolded in ./reserve-staging/"

elif [[ "$cmd" == "publish" ]]; then
  dry_run_args=()
  if [[ "$extra_flag" == "--dry-run" ]]; then
    dry_run_args=("--dry-run")
    echo "🧪 Running in DRY-RUN mode (crates will be verified and packaged but not published)..."
  fi

  echo "🚀 Publishing v0.1.0-alpha.1 stubs to crates.io (skipping already reserved)..."
  for entry in "${PROJECTS[@]}"; do
    IFS='|' read -r base desc <<< "$entry"
    repo_dir="./reserve-staging/${base}"

    if [[ ! -d "$repo_dir" ]]; then
      echo "⚠️  Staging directory for ${base} not found. Run './reserve-namespaces.sh scaffold' first."
      continue
    fi

    pushd "${repo_dir}" > /dev/null

    # Git management: initialize only if .git does not exist
    if [[ ! -d ".git" ]]; then
      git init -b main
      git add -A
      GIT_AUTHOR_NAME="$AUTHOR" \
      GIT_AUTHOR_EMAIL="$AUTHOR_EMAIL" \
      GIT_COMMITTER_NAME="$AUTHOR" \
      GIT_COMMITTER_EMAIL="$AUTHOR_EMAIL" \
      git commit -m "chore: initial v0.1.0-alpha.1 namespace reservation for ${base}"

      if command -v gh &> /dev/null; then
        if ! gh repo view "${GH_OWNER}/${base}" &> /dev/null; then
          gh repo create "${GH_OWNER}/${base}" --public --description "${desc}" --source=. --push || true
        else
          git remote add origin "git@github.com:${GH_OWNER}/${base}.git" 2>/dev/null || true
          git push -u origin main || true
        fi
      fi
    else
      # Ensure remote origin is configured
      git remote add origin "git@github.com:${GH_OWNER}/${base}.git" 2>/dev/null || true
    fi

    # Helper function to publish one crate with automatic 429 rate limit backoff and retry
    publish_crate() {
      local manifest_path="$1"
      local name="$2"

      if crate_exists "$name"; then
        echo "⏩ Skipping ${name} (already on crates.io)"
        return 0
      fi

      local max_retries=10
      local attempt=1

      while [ "$attempt" -le "$max_retries" ]; do
        echo "📦 Publishing ${name} (attempt ${attempt}/${max_retries})..."
        local output
        local exit_code=0
        
        output=$(cargo publish --manifest-path "$manifest_path" ${dry_run_args[@]+"${dry_run_args[@]}"} 2>&1) || exit_code=$?

        echo "$output"

        if [ "$exit_code" -eq 0 ]; then
          echo "✅ ${name} published successfully."
          if [[ ${#dry_run_args[@]} -eq 0 ]]; then
            echo "⏳ Waiting 15s for crates.io index propagation..."
            sleep 15
          fi
          return 0
        fi

        # Check if failure is due to HTTP 429 Too Many Requests
        if echo "$output" | grep -qiE "429 Too Many Requests|published too many crates"; then
          local wait_secs
          wait_secs=$(parse_429_wait_seconds "$output")
          local wait_min=$(( (wait_secs + 59) / 60 ))
          echo ""
          echo "🛑 Crates.io rate limit reached (HTTP 429)."
          echo "⏳ Server cooldown required: ${wait_secs}s (~${wait_min}m)."
          wait_for_cooldown "$wait_secs"
          echo "🔄 Cooldown complete! Retrying ${name} now..."
          echo ""
          attempt=$(( attempt + 1 ))
        else
          echo "⚠️  Failed to publish ${name} (non-429 error). Skipping..."
          return 1
        fi
      done

      echo "❌ Exceeded maximum retries (${max_retries}) for ${name}."
      return 1
    }

    # Publish in dependency order: -core first, -mcp second, -cli third, root last
    publish_crate "crates/${base}-core/Cargo.toml" "${base}-core"
    publish_crate "crates/${base}-mcp/Cargo.toml" "${base}-mcp"
    publish_crate "crates/${base}-cli/Cargo.toml" "${base}-cli"
    publish_crate "Cargo.toml" "${base}"

    # Clean target directory on disk to keep repository clean
    rm -rf target crates/*/target

    popd > /dev/null
  done
  echo "🎉 Namespace reservation run complete!"

elif [[ "$cmd" == "help" || "$cmd" == "--help" || "$cmd" == "-h" ]]; then
  echo "Usage: $0 [check|scaffold|publish] [--dry-run]"
  echo ""
  echo "Commands:"
  echo "  check               Check crates.io availability for all 24 crates (default)"
  echo "  scaffold            Scaffold/update all 8 repos and crate stubs in ./reserve-staging/"
  echo "  publish [--dry-run] Publish unreserved crates to crates.io (skips existing crates)"
  exit 0
else
  echo "Usage: $0 [check|scaffold|publish] [--dry-run]"
  echo ""
  echo "Commands:"
  echo "  check               Check crates.io availability for all 24 crates (default)"
  echo "  scaffold            Scaffold/update all 8 repos and crate stubs in ./reserve-staging/"
  echo "  publish [--dry-run] Publish unreserved crates to crates.io (skips existing crates)"
  exit 1
fi
