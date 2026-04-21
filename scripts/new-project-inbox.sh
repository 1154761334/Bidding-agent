#!/usr/bin/env bash
set -euo pipefail

# This script is now a thin wrapper around bootstrap-stack.sh.
# Kept for backward compatibility.

if [ "$#" -lt 1 ]; then
  echo 'Usage: bash scripts/new-project-inbox.sh <workspace-dir>' >&2
  exit 1
fi

WORKSPACE_DIR="$1"

mkdir -p \
  "$WORKSPACE_DIR/inbox/tender" \
  "$WORKSPACE_DIR/inbox/addenda" \
  "$WORKSPACE_DIR/inbox/company-inputs" \
  "$WORKSPACE_DIR/inbox/vendor-inputs" \
  "$WORKSPACE_DIR/inbox/project-attachments" \
  "$WORKSPACE_DIR/inbox/notes"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_PATH="$SCRIPT_DIR/../templates/project-input-manifest.md"

if [ -f "$TEMPLATE_PATH" ] && [ ! -f "$WORKSPACE_DIR/inbox/PROJECT-INPUT.md" ]; then
  cp "$TEMPLATE_PATH" "$WORKSPACE_DIR/inbox/PROJECT-INPUT.md"
fi

printf 'Project inbox ready at %s/inbox/\n' "$WORKSPACE_DIR"
printf 'Place tender:   %s/inbox/tender/\n' "$WORKSPACE_DIR"
printf 'Place addenda:  %s/inbox/addenda/\n' "$WORKSPACE_DIR"
printf 'Place vendor:   %s/inbox/vendor-inputs/\n' "$WORKSPACE_DIR"
printf 'Compatibility helper only. Primary user entry: bash scripts/start-bid-manager.sh %s [--one-shot]\n' "$WORKSPACE_DIR"
