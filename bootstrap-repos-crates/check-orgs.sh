#!/usr/bin/env bash
set -euo pipefail

# Default organization candidates (or pass your own: ./check-orgs.sh my-org-1 my-org-2)
DEFAULT_ORGS=(
  "gaugeblock"
  "ruth-labs"
  "ruth-agency"
#   "highsteel"
  "joinery-rs"
  "joinery-hq"
#   "joinery-labs" # Taken
  "joinery-ai"
#   "joinery-dev" # Taken
  "millwork-rs"
  "millwork-hq"
  "millwork-labs"
  "woodshop-rs"
  "woodshop-labs"
#   "woodworks"
#   "woodwork"
  "woodwork-labs"
#   "woodshop"
#   "shopworks"
#   "benchcraft" # Taken
  "joinerwork"
  "truemiter"
#   "cleargrain" # Taken
  "truecut-labs"
#   "ironwood-labs" # Taken
#   "entailment"
  "entailment-labs"
  "entailment-hq"
#   "fixpoint"
#   "fixpoint-labs"
#   "nodelines"
#   "toolroom"
)

ORGS=("${@:-${DEFAULT_ORGS[@]}}")
UA="namespace-scanner/1.0"

echo "=========================================================================================="
echo " Checking Organization Handles across GitHub, Hugging Face, and crates.io"
echo " (404 = Available ✅ | 200 = Taken ❌)"
echo "=========================================================================================="
printf "%-18s | %-14s | %-16s | %-16s | %-16s\n" "CANDIDATE ORG" "GITHUB ORG" "HUGGING FACE" "CRATES.IO USER" "CRATES.IO CRATE"
echo "------------------------------------------------------------------------------------------"

for org in "${ORGS[@]}"; do
  # 1. GitHub (User or Org profile page)
  gh_status=$(curl -s -A "$UA" -o /dev/null -w "%{http_code}" "https://github.com/${org}")
  
  # 2. Hugging Face (Check both Organization API and User API/Page)
  # HF returns 404 on the profile URL if neither user nor org exists
  hf_status=$(curl -s -I -A "$UA" -o /dev/null -w "%{http_code}" "https://huggingface.co/${org}")

  # 3. crates.io User Account
  crates_user_status=$(curl -s -A "$UA" -o /dev/null -w "%{http_code}" "https://crates.io/api/v1/users/${org}")

  # 4. crates.io Umbrella Crate Name
  crates_pkg_status=$(curl -s -A "$UA" -o /dev/null -w "%{http_code}" "https://crates.io/api/v1/crates/${org}")

  # Format labels
  [[ "$gh_status" == "404" ]]          && gh_res="✅ FREE" || gh_res="❌ TAKEN ($gh_status)"
  [[ "$hf_status" == "404" ]]          && hf_res="✅ FREE" || hf_res="❌ TAKEN ($hf_status)"
  [[ "$crates_user_status" == "404" ]] && cu_res="✅ FREE" || cu_res="❌ TAKEN ($crates_user_status)"
  [[ "$crates_pkg_status" == "404" ]]  && cp_res="✅ FREE" || cp_res="❌ TAKEN ($crates_pkg_status)"

  printf "%-18s | %-15s | %-17s | %-17s | %-17s\n" "$org" "$gh_res" "$hf_res" "$cu_res" "$cp_res"
done

echo "=========================================================================================="