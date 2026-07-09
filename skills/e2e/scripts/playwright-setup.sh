#!/usr/bin/env bash
# playwright-setup.sh - install Playwright browser dependencies for e2e UI checks.

set -euo pipefail

if [ -f package.json ]; then
  if [ -f pnpm-lock.yaml ]; then
    pnpm exec playwright install --with-deps
  elif [ -f yarn.lock ]; then
    yarn playwright install --with-deps
  else
    npx playwright install --with-deps
  fi
else
  echo "No package.json found. Run this from the frontend project root." >&2
  exit 1
fi
