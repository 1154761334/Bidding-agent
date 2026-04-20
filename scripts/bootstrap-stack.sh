#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
  echo 'Usage: bash scripts/bootstrap-stack.sh <workspace-dir> [project-id]' >&2
  exit 1
fi

WORKSPACE_DIR="$1"
PROJECT_ID="${2:-}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_TEMPLATE="$SCRIPT_DIR/../templates/ovp-vault.env.example"
ENV_PATH="$WORKSPACE_DIR/bid-vault/.env"
OVP_LOCAL_PATH_CHECK="${OVP_LOCAL_PATH:-/root/bid-stack/obsidian_vault_pipeline}"

bash "$SCRIPT_DIR/init-workspace.sh" "$WORKSPACE_DIR"

if [ -n "$PROJECT_ID" ]; then
  bash "$SCRIPT_DIR/new-project-inbox.sh" "$WORKSPACE_DIR" "$PROJECT_ID"
  bash "$SCRIPT_DIR/init-project-run.sh" "$WORKSPACE_DIR" "$PROJECT_ID"
fi

if [ ! -f "$ENV_PATH" ]; then
  cp "$ENV_TEMPLATE" "$ENV_PATH"
  ENV_STATUS='created from template'
else
  ENV_STATUS='already present'
fi

if command -v ovp >/dev/null 2>&1; then
  OVP_STATUS='installed'
elif [ -d "$OVP_LOCAL_PATH_CHECK/.git" ]; then
  OVP_STATUS="local checkout detected at $OVP_LOCAL_PATH_CHECK, install with: bash scripts/install-ovp.sh local"
else
  OVP_STATUS="not detected, clone your fork to $OVP_LOCAL_PATH_CHECK or set OVP_LOCAL_PATH"
fi

printf 'Stack workspace ready at %s\n' "$WORKSPACE_DIR"
printf 'Vault env: %s (%s)\n' "$ENV_PATH" "$ENV_STATUS"
printf 'OVP status: %s\n' "$OVP_STATUS"

if [ -n "$PROJECT_ID" ]; then
  PROJECT_DIR="$WORKSPACE_DIR/bid-vault/inbox/projects/$PROJECT_ID"
  RUN_DIR="$WORKSPACE_DIR/bid-vault/output/project-runs/$PROJECT_ID"
  printf 'Project folder: %s\n' "$PROJECT_DIR"
  printf 'Project run: %s\n' "$RUN_DIR"
  printf 'Next: place tender files under %s/tender/\n' "$PROJECT_DIR"
  printf 'Next: place addenda and clarifications under %s/addenda/\n' "$PROJECT_DIR"
  printf 'Next: place bidder files under %s/company-inputs/\n' "$PROJECT_DIR"
  printf 'Next: place vendor files under %s/vendor-inputs/\n' "$PROJECT_DIR"
  printf 'Next: place project-only attachments under %s/project-attachments/\n' "$PROJECT_DIR"
  printf 'Normalize: bash scripts/normalize-project-inputs.sh %s %s\n' "$WORKSPACE_DIR" "$PROJECT_ID"
  printf 'Check prompt only: bash scripts/start-bid-manager.sh %s %s --dry-run\n' "$WORKSPACE_DIR" "$PROJECT_ID"
  printf 'Start: bash scripts/start-bid-manager.sh %s %s\n' "$WORKSPACE_DIR" "$PROJECT_ID"
else
  printf 'Next: create a project folder with bash scripts/new-project-inbox.sh %s <project-id>\n' "$WORKSPACE_DIR"
fi
