#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
  echo 'Usage: bash scripts/normalize-project-inputs.sh <workspace-dir> [category]' >&2
  exit 1
fi

WORKSPACE_DIR="$1"
ONLY_CATEGORY="${2:-}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_INPUT_DIR="$WORKSPACE_DIR/inbox"
RUN_DIR="$WORKSPACE_DIR/output"
NORMALIZED_DIR="$RUN_DIR/normalized"
INDEX_PATH="$NORMALIZED_DIR/normalization-index.tsv"
TMP_SUMMARY="$(mktemp)"

CATEGORIES=(
  "tender"
  "addenda"
  "company-inputs"
  "vendor-inputs"
  "project-attachments"
  "notes"
)

STRICT=0
if [ "${ONLY_CATEGORY:-}" = "--strict" ]; then
  STRICT=1
  ONLY_CATEGORY=""
fi

SUCCESS_COUNT=0
WARNING_COUNT=0
FAIL_COUNT=0

cleanup() {
  rm -f "$TMP_SUMMARY"
}
trap cleanup EXIT

read_summary_value() {
  local key="$1"
  local file="$2"
  awk -F '\t' -v key="$key" '$1 == key {print substr($0, index($0,$2))}' "$file"
}

if [ ! -d "$PROJECT_INPUT_DIR" ]; then
  echo "Project input folder not found: $PROJECT_INPUT_DIR" >&2
  echo "Run bash scripts/start-bid-manager.sh $WORKSPACE_DIR --dry-run once, or bootstrap the workspace manually." >&2
  exit 1
fi

if [ ! -d "$RUN_DIR" ]; then
  echo "Project output folder not found: $RUN_DIR" >&2
  echo "Run bash scripts/start-bid-manager.sh $WORKSPACE_DIR --dry-run once, or bootstrap the workspace manually." >&2
  exit 1
fi

mkdir -p "$NORMALIZED_DIR"
printf 'input_category\tinput_file\tbundle_dir\tadapter\tstatus\tnotes\n' > "$INDEX_PATH"

for category in "${CATEGORIES[@]}"; do
  if [ -n "$ONLY_CATEGORY" ] && [ "$category" != "$ONLY_CATEGORY" ]; then
    continue
  fi

  CATEGORY_DIR="$PROJECT_INPUT_DIR/$category"
  [ -d "$CATEGORY_DIR" ] || continue

  while IFS= read -r -d '' input_file; do
    relative_path="${input_file#$CATEGORY_DIR/}"
    bundle_dir="$NORMALIZED_DIR/$category/$relative_path"

    rm -rf "$bundle_dir"
    mkdir -p "$(dirname "$bundle_dir")"

    if bash "$SCRIPT_DIR/normalize-document.sh" "$input_file" "$bundle_dir" "$category" >"$TMP_SUMMARY"; then
      :
    else
      :
    fi

    adapter="$(read_summary_value adapter "$TMP_SUMMARY")"
    status="$(read_summary_value status "$TMP_SUMMARY")"
    notes="$(read_summary_value notes "$TMP_SUMMARY")"

    case "$status" in
      success) SUCCESS_COUNT=$((SUCCESS_COUNT + 1)) ;;
      warning) WARNING_COUNT=$((WARNING_COUNT + 1)) ;;
      *)       FAIL_COUNT=$((FAIL_COUNT + 1)) ;;
    esac

    printf '%s\t%s\t%s\t%s\t%s\t%s\n' \
      "$category" \
      "$relative_path" \
      "$bundle_dir" \
      "$adapter" \
      "$status" \
      "$notes" >> "$INDEX_PATH"
  done < <(find "$CATEGORY_DIR" -type f -print0 | sort -z)
done

printf '\nNormalization summary: %s success, %s warning, %s failed\n' "$SUCCESS_COUNT" "$WARNING_COUNT" "$FAIL_COUNT"
printf 'Normalized current project inputs into %s\n' "$NORMALIZED_DIR"
printf 'Index file: %s\n' "$INDEX_PATH"

if [ "$FAIL_COUNT" -gt 0 ]; then
  printf 'WARNING: %s file(s) failed normalization. Review index for details.\n' "$FAIL_COUNT"
  if [ "$STRICT" -eq 1 ]; then
    printf 'Strict mode: exiting with error due to failures.\n' >&2
    exit 1
  fi
fi

printf 'Next: review normalization warnings before parsing the tender.\n'
