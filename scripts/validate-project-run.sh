#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 1 ]; then
  echo 'Usage: bash scripts/validate-project-run.sh <workspace-dir>' >&2
  exit 1
fi

WORKSPACE_DIR="$1"
RUN_DIR="$WORKSPACE_DIR/output"
PROGRESS_JSON="$RUN_DIR/PROGRESS.json"

# Extract project ID from workspace basename
PROJECT_ID=$(basename "$WORKSPACE_DIR")

PASS_COUNT=0
WARN_COUNT=0
FAIL_COUNT=0

report() {
  local level="$1"
  local msg="$2"
  case "$level" in
    PASS) PASS_COUNT=$((PASS_COUNT + 1)); printf '  ✅ %s\n' "$msg" ;;
    WARN) WARN_COUNT=$((WARN_COUNT + 1)); printf '  ⚠️  %s\n' "$msg" ;;
    FAIL) FAIL_COUNT=$((FAIL_COUNT + 1)); printf '  ❌ %s\n' "$msg" ;;
  esac
}

echo "== Project workspace validation: $PROJECT_ID =="
echo ""

# 1. Project directory
if [ ! -d "$WORKSPACE_DIR" ]; then
  printf '❌ Workspace directory not found: %s\n' "$WORKSPACE_DIR"
  exit 1
fi
report PASS "Workspace directory exists"

# 2. PROGRESS.json
echo ""
echo "--- State tracking ---"
if [ -f "$PROGRESS_JSON" ]; then
  if python3 -c "import json; json.load(open('$PROGRESS_JSON'))" 2>/dev/null; then
    report PASS "PROGRESS.json exists and is valid JSON"
    CURRENT_PHASE=$(python3 -c "import json; d=json.load(open('$PROGRESS_JSON')); print(d.get('current_phase', 0))" 2>/dev/null || echo 0)
    PHASE_NAME=$(python3 -c "import json; d=json.load(open('$PROGRESS_JSON')); print(d.get('phase_name', 'unknown'))" 2>/dev/null || echo 'unknown')
    printf '  📍 Current phase: %s (%s)\n' "$CURRENT_PHASE" "$PHASE_NAME"
  else
    report FAIL "PROGRESS.json exists but is not valid JSON"
  fi
else
  report WARN "PROGRESS.json not found (state tracking disabled)"
fi

# 3. Core artifacts
echo ""
echo "--- Core artifacts ---"

check_artifact() {
  local path="$1"
  local name="$2"
  local required="$3"

  if [ -f "$path" ]; then
    SIZE=$(wc -c < "$path")
    TEMPLATE_SIZE=0
    # Check if file is effectively empty/template by counting non-whitespace non-comment lines
    CONTENT_LINES=$(grep -cE '^[^#>-].*[^ ]' "$path" 2>/dev/null || echo 0)
    if [ "$CONTENT_LINES" -le 3 ]; then
      report WARN "$name exists but appears to be an unfilled template ($CONTENT_LINES content lines)"
    else
      report PASS "$name exists ($CONTENT_LINES content lines)"
    fi
  elif [ "$required" = "required" ]; then
    report FAIL "$name missing"
  else
    report WARN "$name not yet created"
  fi
}

check_artifact "$RUN_DIR/00-NORMALIZATION-MANIFEST.md"             "00-NORMALIZATION-MANIFEST.md" "required"
check_artifact "$RUN_DIR/01-PROJECT-START.md"                       "01-PROJECT-START.md"          "required"
check_artifact "$RUN_DIR/02-TENDER-PARSE.md"                        "02-TENDER-PARSE.md"           "required"
check_artifact "$RUN_DIR/03-EVIDENCE-GAPS.md"                       "03-EVIDENCE-GAPS.md"          "required"
check_artifact "$RUN_DIR/04-SCORE-CHAPTER-EVIDENCE-MAPPING.md"      "04-SCORE-CHAPTER-EVIDENCE-MAPPING.md" "required"
check_artifact "$RUN_DIR/05-OUTLINE.md"                             "05-OUTLINE.md"                "required"
check_artifact "$RUN_DIR/06-REVIEW-CHECKLIST.md"                    "06-REVIEW-CHECKLIST.md"       "optional"

# 4. Normalization state
echo ""
echo "--- Normalization ---"

NORM_INDEX="$RUN_DIR/normalized/normalization-index.tsv"
if [ -f "$NORM_INDEX" ]; then
  TOTAL=$(tail -n +2 "$NORM_INDEX" | wc -l)
  SUCCESS=$(tail -n +2 "$NORM_INDEX" | awk -F'\t' '$5=="success"' | wc -l)
  WARNINGS=$(tail -n +2 "$NORM_INDEX" | awk -F'\t' '$5=="warning"' | wc -l)
  FAILURES=$(tail -n +2 "$NORM_INDEX" | awk -F'\t' '$5=="failed"' | wc -l)
  printf '  📦 Normalized files: %s total (%s success, %s warning, %s failed)\n' "$TOTAL" "$SUCCESS" "$WARNINGS" "$FAILURES"
  if [ "$FAILURES" -gt 0 ]; then
    report WARN "$FAILURES file(s) failed normalization"
  else
    report PASS "All normalized files succeeded or warned"
  fi
else
  report WARN "Normalization index not found (normalization not yet run?)"
fi

# 5. Subdirectories
echo ""
echo "--- Working directories ---"

for subdir in evidence drafts reviews final; do
  DIR_PATH="$RUN_DIR/$subdir"
  if [ -d "$DIR_PATH" ]; then
    COUNT=$(find "$DIR_PATH" -type f 2>/dev/null | wc -l)
    if [ "$COUNT" -gt 0 ]; then
      report PASS "$subdir/ — $COUNT file(s)"
    else
      report WARN "$subdir/ — empty"
    fi
  else
    report WARN "$subdir/ — missing"
  fi
done

# 6. Input folder
echo ""
echo "--- Project input ---"

INPUT_DIR="$WORKSPACE_DIR/inbox"
if [ -d "$INPUT_DIR" ]; then
  for subdir in tender addenda company-inputs vendor-inputs project-attachments notes; do
    if [ -d "$INPUT_DIR/$subdir" ]; then
      COUNT=$(find "$INPUT_DIR/$subdir" -type f 2>/dev/null | wc -l)
      printf '  📂 %s/ — %s file(s)\n' "$subdir" "$COUNT"
    fi
  done
  report PASS "Project input folder exists"
else
  report FAIL "Project input folder missing: %s" "$INPUT_DIR"
fi

# Summary
echo ""
echo "== Validation summary =="
printf '  ✅ Pass: %s\n' "$PASS_COUNT"
printf '  ⚠️  Warn: %s\n' "$WARN_COUNT"
printf '  ❌ Fail: %s\n' "$FAIL_COUNT"

if [ "$FAIL_COUNT" -gt 0 ]; then
  echo ""
  echo "Action required: fix the failed checks before proceeding."
  exit 1
fi
