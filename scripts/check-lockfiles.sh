#!/usr/bin/env bash
# Thin wrapper: lockfile hygiene is owned by outfeed (GB-152).
#
# The check itself — tracked and fresh Cargo.lock in every standalone repository —
# lives in `outfeed-core` so it ships with the delivery engine instead of being a
# script that has to be kept in sync with it.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
exec outfeed lockfiles "$root" "$@"
