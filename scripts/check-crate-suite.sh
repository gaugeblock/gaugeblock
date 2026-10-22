#!/usr/bin/env bash
set -euo pipefail

# Optional: Set your target GitHub Org or Username to also verify GitHub repo availability
GH_OWNER="${1:-gaugeblock}"
UA="crate-suite-scanner/1.0"

# Primary 8 suite names + good backup joinery candidates in case you want to swap any
CANDIDATE_BASES=(
  # --- Primary 8 Suite ---
  "storypole"   # 2. Backlog, Task DAG & Agent Memory Store
  "sawhorse"    # 3. Provider-Agnostic 3-Mode LLM Runtime
  "chalkline"   # 4. Interactive Spec & Topological Planner (/grill-me)
  "dado"        # 5. AST Pattern & Typed Hole Engine
  "batten"      # 6. Scope-to-CFG Grammar Compiler
  "joiner"      # 7. Master Neurosymbolic Orchestrator
  "benchwork"   # 8. Modular Visual Workbench UI
  "rabbet"      # 9. Telemetry Corpus Hub & Training Foundry

  # --- Backup Joinery/Machining Candidates ---
  "batten"      # Backup for storypole
  "mandrel"     # Backup for sawhorse
  "trammel"     # Backup for chalkline
  "drawbore"    # Backup for joiner
  "benchdog"    # Backup for benchwork
  "millwork"    # Backup for rabbet
  "dado"        # General backup
  "chamfer"     # General backup
  "featherboard" # Backup for tenon (grammar guide)
)

# All sub-crate suffixes to verify for each base name
SUFFIXES=("" "-core" "-cli" "-mcp" "-engine")

echo "===================================================================================================="
echo " Checking Full Crate Suite on crates.io (and GitHub Repo under '${GH_OWNER}')"
echo "===================================================================================================="
printf "%-14s | %-11s | %-13s | %-15s | %-14s | %-14s | %-15s\n" \
  "BASE NAME" "GH REPO" "<name>" "<name>-core" "<name>-cli" "<name>-mcp" "<name>-engine"
echo "----------------------------------------------------------------------------------------------------"

for base in "${CANDIDATE_BASES[@]}"; do
  # Check if repo already exists under GH_OWNER
  gh_repo_status=$(curl -s -A "$UA" -o /dev/null -w "%{http_code}" "https://github.com/${GH_OWNER}/${base}")
  if [[ "$gh_repo_status" == "404" ]]; then
    gh_cell="✅ FREE"
  else
    gh_cell="❌ EXISTS"
  fi

  results=()
  all_crates_free=true

  for suffix in "${SUFFIXES[@]}"; do
    crate="${base}${suffix}"
    status=$(curl -s -A "$UA" -o /dev/null -w "%{http_code}" "https://crates.io/api/v1/crates/${crate}")
    if [[ "$status" == "404" ]]; then
      results+=("✅ FREE")
    else
      results+=("❌ TAKEN")
      all_crates_free=false
    fi
  done

  printf "%-14s | %-12s | %-14s | %-16s | %-15s | %-15s | %-16s" \
    "$base" "$gh_cell" "${results[0]}" "${results[1]}" "${results[2]}" "${results[3]}" "${results[4]}"

  if $all_crates_free; then
    echo "  🌟 CLEAN SUITE"
  else
    echo "  ⚠️  COLLISION"
  fi
done

echo "===================================================================================================="