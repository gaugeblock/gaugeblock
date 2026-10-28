#!/usr/bin/env bash
# Verify every repository that has a Cargo.toml also tracks Cargo.lock.
#
# All suite repositories ship binaries, so the lockfile is what makes a published
# build reproducible. A repository that silently stops tracking it re-resolves its
# dependency graph on every clone, which is how a gated build and a user's build
# quietly diverge (GB-150).
set -uo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
status=0
checked=0

for manifest in "$root"/*/Cargo.toml; do
  repo="$(basename "$(dirname "$manifest")")"
  [[ "$repo" == target ]] && continue
  git -C "$(dirname "$manifest")" rev-parse --git-dir >/dev/null 2>&1 || continue
  checked=$((checked + 1))

  if ! git -C "$(dirname "$manifest")" ls-files --error-unmatch Cargo.lock >/dev/null 2>&1; then
    printf 'MISSING  %-12s Cargo.lock is not tracked\n' "$repo"
    status=1
  elif ! (cd "$(dirname "$manifest")" && cargo metadata --locked --format-version 1 >/dev/null 2>&1); then
    printf 'STALE    %-12s Cargo.lock does not match the manifests\n' "$repo"
    status=1
  fi
done

echo ""
if [[ $status -eq 0 ]]; then
  echo "All $checked repositories track a fresh Cargo.lock."
else
  echo "Cargo.lock problems found (see above)."
fi
exit $status
