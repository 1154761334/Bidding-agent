#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 2 ]; then
  echo 'Usage: bash scripts/new-project-inbox.sh <workspace-dir> <project-id>' >&2
  exit 1
fi

WORKSPACE_DIR="$1"
PROJECT_ID="$2"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_PATH="$SCRIPT_DIR/../templates/project-input-manifest.md"
PROJECT_DIR="$WORKSPACE_DIR/bid-vault/inbox/projects/$PROJECT_ID"

if [ ! -d "$WORKSPACE_DIR/bid-vault" ]; then
  echo "Workspace not initialized: $WORKSPACE_DIR/bid-vault" >&2
  echo 'Run bash scripts/init-workspace.sh <workspace-dir> first.' >&2
  exit 1
fi

mkdir -p \
  "$PROJECT_DIR/tender" \
  "$PROJECT_DIR/company-inputs" \
  "$PROJECT_DIR/vendor-inputs" \
  "$PROJECT_DIR/notes"

if [ -f "$TEMPLATE_PATH" ] && [ ! -f "$PROJECT_DIR/PROJECT-INPUT.md" ]; then
  cp "$TEMPLATE_PATH" "$PROJECT_DIR/PROJECT-INPUT.md"
fi

printf 'Created project input folder at %s\n' "$PROJECT_DIR"
printf 'Place the tender package under %s/tender/\n' "$PROJECT_DIR"
printf 'Place project-specific bidder material under %s/company-inputs/\n' "$PROJECT_DIR"
printf 'Place project-specific vendor material under %s/vendor-inputs/\n' "$PROJECT_DIR"
