#!/bin/bash
set -euo pipefail

if [ -z "${TARGET_URL:-}" ]; then
  echo "ERROR: TARGET_URL environment variable is required" >&2
  exit 1
fi

AGENT="${AGENT:-claude}"

case "$AGENT" in
  claude)
    if [ -z "${ANTHROPIC_API_KEY:-}" ]; then
      echo "ERROR: ANTHROPIC_API_KEY environment variable is required for claude agent" >&2
      exit 1
    fi
    ;;
  rovo)
    if [ -z "${ATLASSIAN_EMAIL:-}" ] || [ -z "${ATLASSIAN_API_TOKEN:-}" ]; then
      echo "ERROR: ATLASSIAN_EMAIL and ATLASSIAN_API_TOKEN environment variables are required for rovo agent" >&2
      exit 1
    fi
    ;;
  *)
    echo "ERROR: Unknown agent '${AGENT}'. Supported agents: claude, rovo" >&2
    exit 1
    ;;
esac

mkdir -p /output

DEFAULT_PROMPT="Perform exploratory testing on ${TARGET_URL}"
PROMPT="${TEST_PROMPT:-$DEFAULT_PROMPT}"

cd /workspace

case "$AGENT" in
  claude)
    exec claude --print "${PROMPT}"
    ;;
  rovo)
    echo "${ATLASSIAN_API_TOKEN}" | acli rovodev auth login --email "${ATLASSIAN_EMAIL}" --token
    exec acli rovodev run --yolo "${PROMPT}"
    ;;
esac
