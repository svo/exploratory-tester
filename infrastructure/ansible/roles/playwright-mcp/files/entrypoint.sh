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
    if [ -z "${ATLASSIAN_SITE_URL:-}" ]; then
      echo "ERROR: ATLASSIAN_SITE_URL environment variable is required for rovo agent (e.g. https://your-site.atlassian.net)" >&2
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
    ROVODEV_CONFIG_DIR="${HOME}/.rovodev"
    mkdir -p "${ROVODEV_CONFIG_DIR}"

    PLAYWRIGHT_MCP_ARGS='"--headless", "--browser", "chromium", "--no-sandbox", "--viewport-size", "1280x720", "--output-dir", "/output", "--image-responses", "allow"'

    cat > "${ROVODEV_CONFIG_DIR}/mcp.json" <<MCPEOF
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp", ${PLAYWRIGHT_MCP_ARGS}],
      "transport": "stdio"
    }
  }
}
MCPEOF

    ALLOWED_SIG="stdio:npx:@playwright/mcp --headless --browser chromium --no-sandbox --viewport-size 1280x720 --output-dir /output --image-responses allow"

    cat > "${ROVODEV_CONFIG_DIR}/config.yml" <<EOF
version: 1
atlassianBillingSite:
  siteUrl: ${ATLASSIAN_SITE_URL}
mcp:
  mcpConfigPath: ${ROVODEV_CONFIG_DIR}/mcp.json
  allowedMcpServers:
    - "${ALLOWED_SIG}"
toolPermissions:
  default: allow
  bash:
    default: allow
  allowedExternalPaths:
    - /output
EOF

    echo "${ATLASSIAN_API_TOKEN}" | acli rovodev auth login --email "${ATLASSIAN_EMAIL}" --token
    exec acli rovodev run --yolo "${PROMPT}"
    ;;
esac
