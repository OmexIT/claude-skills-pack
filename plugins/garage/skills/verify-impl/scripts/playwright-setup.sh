#!/usr/bin/env bash
# playwright-setup.sh - install Playwright browsers for verify-impl UI checks.
# Usage: playwright-setup.sh [--with-deps]   (--with-deps installs OS packages; needs approval)

set -euo pipefail

install_args=(install)
if [ "${1:-}" = "--with-deps" ]; then
  install_args+=(--with-deps)
elif [ "$#" -gt 0 ]; then
  echo "Usage: $0 [--with-deps]" >&2
  exit 2
fi

if [ ! -f package.json ]; then
  echo "No package.json found. Run this from the frontend project root." >&2
  exit 1
fi

if [ -f pnpm-lock.yaml ]; then
  pnpm exec playwright "${install_args[@]}"
elif [ -f yarn.lock ]; then
  yarn playwright "${install_args[@]}"
else
  npx playwright "${install_args[@]}"
fi
