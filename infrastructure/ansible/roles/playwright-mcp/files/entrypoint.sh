#!/bin/bash
set -euo pipefail

if [ -z "${TARGET_URL:-}" ]; then
  echo "ERROR: TARGET_URL environment variable is required" >&2
  exit 1
fi

if [ -z "${ANTHROPIC_API_KEY:-}" ]; then
  echo "ERROR: ANTHROPIC_API_KEY environment variable is required" >&2
  exit 1
fi

mkdir -p /output

DEFAULT_PROMPT="Perform exploratory testing on ${TARGET_URL}"
PROMPT="${TEST_PROMPT:-$DEFAULT_PROMPT}"

cd /workspace
exec claude --print "${PROMPT}" --allowedTools "mcp__playwright__*"
