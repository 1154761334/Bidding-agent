#!/usr/bin/env bash
set -euo pipefail

# Initialize a project workspace.
# A workspace is a lightweight drafting sandbox for one bid project.
# It does NOT contain company knowledge — that lives in the vault.

TARGET_DIR="${1:-$(pwd)}"

mkdir -p \
  "$TARGET_DIR/inbox/tender" \
  "$TARGET_DIR/inbox/addenda" \
  "$TARGET_DIR/inbox/company-inputs" \
  "$TARGET_DIR/inbox/vendor-inputs" \
  "$TARGET_DIR/inbox/project-attachments" \
  "$TARGET_DIR/inbox/notes" \
  "$TARGET_DIR/output/normalized/tender" \
  "$TARGET_DIR/output/normalized/addenda" \
  "$TARGET_DIR/output/normalized/company-inputs" \
  "$TARGET_DIR/output/normalized/vendor-inputs" \
  "$TARGET_DIR/output/normalized/project-attachments" \
  "$TARGET_DIR/output/normalized/notes" \
  "$TARGET_DIR/output/evidence" \
  "$TARGET_DIR/output/drafts" \
  "$TARGET_DIR/output/reviews" \
  "$TARGET_DIR/output/final" \
  "$TARGET_DIR/logs/lint-reports"

printf 'Initialized project workspace at %s\n' "$TARGET_DIR"
