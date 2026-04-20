#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 2 ]; then
  echo 'Usage: bash scripts/init-project-run.sh <workspace-dir> <project-id>' >&2
  exit 1
fi

WORKSPACE_DIR="$1"
PROJECT_ID="$2"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_INPUT_DIR="$WORKSPACE_DIR/bid-vault/inbox/projects/$PROJECT_ID"
RUN_DIR="$WORKSPACE_DIR/bid-vault/output/project-runs/$PROJECT_ID"

copy_if_missing() {
  local src="$1"
  local dst="$2"

  if [ ! -f "$dst" ]; then
    cp "$src" "$dst"
  fi
}

if [ ! -d "$WORKSPACE_DIR/bid-vault" ]; then
  echo "Workspace not initialized: $WORKSPACE_DIR/bid-vault" >&2
  echo 'Run bash scripts/init-workspace.sh <workspace-dir> first.' >&2
  exit 1
fi

if [ ! -d "$PROJECT_INPUT_DIR" ]; then
  echo "Project input folder not found: $PROJECT_INPUT_DIR" >&2
  echo 'Run bash scripts/new-project-inbox.sh <workspace-dir> <project-id> first.' >&2
  exit 1
fi

mkdir -p \
  "$RUN_DIR/normalized/tender" \
  "$RUN_DIR/normalized/addenda" \
  "$RUN_DIR/normalized/company-inputs" \
  "$RUN_DIR/normalized/vendor-inputs" \
  "$RUN_DIR/normalized/project-attachments" \
  "$RUN_DIR/normalized/notes" \
  "$RUN_DIR/evidence" \
  "$RUN_DIR/drafts" \
  "$RUN_DIR/reviews" \
  "$RUN_DIR/final"

copy_if_missing "$SCRIPT_DIR/../templates/normalization-manifest.md" "$RUN_DIR/00-NORMALIZATION-MANIFEST.md"
copy_if_missing "$SCRIPT_DIR/../templates/project-start-sheet.md" "$RUN_DIR/01-PROJECT-START.md"
copy_if_missing "$SCRIPT_DIR/../templates/tender-parse-template.md" "$RUN_DIR/02-TENDER-PARSE.md"
copy_if_missing "$SCRIPT_DIR/../templates/evidence-gap-report.md" "$RUN_DIR/03-EVIDENCE-GAPS.md"
copy_if_missing "$SCRIPT_DIR/../templates/score-chapter-evidence-mapping.md" "$RUN_DIR/04-SCORE-CHAPTER-EVIDENCE-MAPPING.md"
copy_if_missing "$SCRIPT_DIR/../templates/outline-template.md" "$RUN_DIR/05-OUTLINE.md"
copy_if_missing "$SCRIPT_DIR/../templates/review-checklist.md" "$RUN_DIR/06-REVIEW-CHECKLIST.md"

if [ ! -f "$RUN_DIR/README.md" ]; then
  cat > "$RUN_DIR/README.md" <<EOF
# Project run: $PROJECT_ID

## Boundary
- Current project input: \`bid-vault/inbox/projects/$PROJECT_ID/\`
- Reusable knowledge: \`bid-vault/raw/\` and promoted pages in \`bid-vault/wiki/\`
- This folder: working artifacts for the current project only

## Default V1 milestone
1. Normalize current project inputs into \`normalized/\`
2. Review \`00-NORMALIZATION-MANIFEST.md\`
3. Generate \`02-TENDER-PARSE.generated.md\`
4. Fill \`01-PROJECT-START.md\`
5. Review or copy into \`02-TENDER-PARSE.md\`
6. Record evidence gaps in \`03-EVIDENCE-GAPS.md\`
7. Build \`04-SCORE-CHAPTER-EVIDENCE-MAPPING.md\`
8. Confirm \`05-OUTLINE.md\`

Do not treat the tender package as long-term knowledge by default.
Do not start full chapter drafting before the outline is confirmed.
EOF
fi

printf 'Initialized project run at %s\n' "$RUN_DIR"
printf 'Current project input: %s\n' "$PROJECT_INPUT_DIR"
printf 'Next: run bash scripts/normalize-project-inputs.sh %s %s before parsing.\n' "$WORKSPACE_DIR" "$PROJECT_ID"
printf 'Then: run bash scripts/generate-parse-skeleton.sh %s %s to prefill the parse page.\n' "$WORKSPACE_DIR" "$PROJECT_ID"
