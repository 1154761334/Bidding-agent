#!/usr/bin/env bash
set -euo pipefail

# init-project-run.sh is now absorbed into bootstrap-stack.sh.
# This script is kept as a compatibility shim.

if [ "$#" -lt 1 ]; then
  echo 'Usage: bash scripts/init-project-run.sh <workspace-dir>' >&2
  exit 1
fi

WORKSPACE_DIR="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ ! -d "$WORKSPACE_DIR/inbox" ]; then
  echo "Workspace not initialized: $WORKSPACE_DIR/inbox not found" >&2
  echo "Run bash scripts/start-bid-manager.sh $WORKSPACE_DIR --dry-run once, or bootstrap the workspace manually." >&2
  exit 1
fi

mkdir -p \
  "$WORKSPACE_DIR/output/normalized/tender" \
  "$WORKSPACE_DIR/output/normalized/addenda" \
  "$WORKSPACE_DIR/output/normalized/company-inputs" \
  "$WORKSPACE_DIR/output/normalized/vendor-inputs" \
  "$WORKSPACE_DIR/output/normalized/project-attachments" \
  "$WORKSPACE_DIR/output/normalized/notes" \
  "$WORKSPACE_DIR/output/evidence" \
  "$WORKSPACE_DIR/output/drafts" \
  "$WORKSPACE_DIR/output/reviews" \
  "$WORKSPACE_DIR/output/final"

copy_if_missing() {
  local src="$1"
  local dst="$2"
  if [ -f "$src" ] && [ ! -f "$dst" ]; then
    cp "$src" "$dst"
  fi
}

TEMPLATE_DIR="$SCRIPT_DIR/../templates"
copy_if_missing "$TEMPLATE_DIR/normalization-manifest.md" "$WORKSPACE_DIR/output/00-NORMALIZATION-MANIFEST.md"
copy_if_missing "$TEMPLATE_DIR/project-start-sheet.md" "$WORKSPACE_DIR/output/01-PROJECT-START.md"
copy_if_missing "$TEMPLATE_DIR/tender-parse-template.md" "$WORKSPACE_DIR/output/02-TENDER-PARSE.md"
copy_if_missing "$TEMPLATE_DIR/evidence-gap-report.md" "$WORKSPACE_DIR/output/03-EVIDENCE-GAPS.md"
copy_if_missing "$TEMPLATE_DIR/score-chapter-evidence-mapping.md" "$WORKSPACE_DIR/output/04-SCORE-CHAPTER-EVIDENCE-MAPPING.md"
copy_if_missing "$TEMPLATE_DIR/outline-template.md" "$WORKSPACE_DIR/output/05-OUTLINE.md"
copy_if_missing "$TEMPLATE_DIR/review-checklist.md" "$WORKSPACE_DIR/output/06-REVIEW-CHECKLIST.md"

printf 'Project run initialized at %s/output/\n' "$WORKSPACE_DIR"
printf 'Compatibility helper only. Primary user entry: bash scripts/start-bid-manager.sh %s [--one-shot]\n' "$WORKSPACE_DIR"
