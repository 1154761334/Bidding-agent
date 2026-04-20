#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
  echo 'Usage: bash scripts/normalize-document.sh <input-file> <output-dir> [source-kind]' >&2
  exit 1
fi

INPUT_PATH="$1"
OUTPUT_DIR="$2"
SOURCE_KIND="${3:-manual}"

if [ ! -f "$INPUT_PATH" ]; then
  echo "Input file not found: $INPUT_PATH" >&2
  exit 1
fi

INPUT_NAME="$(basename "$INPUT_PATH")"
INPUT_DIR="$(cd "$(dirname "$INPUT_PATH")" && pwd -P)"
INPUT_ABS="$INPUT_DIR/$INPUT_NAME"
INPUT_EXT="${INPUT_NAME##*.}"
INPUT_EXT_LOWER="$(printf '%s' "$INPUT_EXT" | tr '[:upper:]' '[:lower:]')"
OUTPUT_ABS="$(mkdir -p "$OUTPUT_DIR" && cd "$OUTPUT_DIR" && pwd -P)"
ATTACHMENTS_DIR="$OUTPUT_ABS/attachments"
SOURCE_MD="$OUTPUT_ABS/source.md"
SUMMARY_TSV="$OUTPUT_ABS/summary.tsv"
METADATA_MD="$OUTPUT_ABS/METADATA.md"
TMP_STDERR="$(mktemp)"

MARKITDOWN_BIN_ENV="${MARKITDOWN_BIN:-}"
MARKITDOWN_BIN=''
ADAPTER=''
STATUS='success'
NOTES=''
DEFAULT_MARKITDOWN_VENV_BIN="${MARKITDOWN_VENV_DIR:-/root/bid-stack/.venvs/markitdown}/bin/markitdown"

cleanup() {
  rm -f "$TMP_STDERR"
}
trap cleanup EXIT

write_metadata() {
  local original_copy="$1"

  cat > "$SUMMARY_TSV" <<EOF
adapter	$ADAPTER
status	$STATUS
source_kind	$SOURCE_KIND
source_file	$INPUT_ABS
original_copy	$original_copy
source_md	$SOURCE_MD
attachments_dir	$ATTACHMENTS_DIR
notes	$NOTES
EOF

  cat > "$METADATA_MD" <<EOF
# Normalization Metadata

- Source kind: \`$SOURCE_KIND\`
- Source file: \`$INPUT_ABS\`
- Original copy: \`$original_copy\`
- Adapter: \`$ADAPTER\`
- Status: \`$STATUS\`
- Markdown output: \`$SOURCE_MD\`
- Attachments directory: \`$ATTACHMENTS_DIR\`
- Notes: $NOTES
EOF
}

can_use_markitdown() {
  if [ -n "$MARKITDOWN_BIN_ENV" ] && [ -x "$MARKITDOWN_BIN_ENV" ]; then
    MARKITDOWN_BIN="$MARKITDOWN_BIN_ENV"
    return 0
  fi

  if [ -x "$DEFAULT_MARKITDOWN_VENV_BIN" ]; then
    MARKITDOWN_BIN="$DEFAULT_MARKITDOWN_VENV_BIN"
    return 0
  fi

  if command -v markitdown >/dev/null 2>&1; then
    MARKITDOWN_BIN='markitdown'
    return 0
  fi

  if python3 -c 'import markitdown' >/dev/null 2>&1; then
    MARKITDOWN_BIN='python3 -m markitdown'
    return 0
  fi

  return 1
}

run_markitdown() {
  case "$MARKITDOWN_BIN" in
    markitdown)
      markitdown "$INPUT_ABS" > "$SOURCE_MD"
      ;;
    'python3 -m markitdown')
      python3 -m markitdown "$INPUT_ABS" > "$SOURCE_MD"
      ;;
    *)
      "$MARKITDOWN_BIN" "$INPUT_ABS" > "$SOURCE_MD"
      ;;
  esac
}

copy_text_like() {
  cp "$INPUT_ABS" "$SOURCE_MD"
}

run_pandoc_docx() {
  mkdir -p "$ATTACHMENTS_DIR"
  pandoc "$INPUT_ABS" -t gfm --extract-media="$ATTACHMENTS_DIR" -o "$SOURCE_MD"
}

run_pdftotext() {
  pdftotext -layout "$INPUT_ABS" "$SOURCE_MD"
}

mkdir -p "$OUTPUT_ABS"
rm -f "$SOURCE_MD" "$SUMMARY_TSV" "$METADATA_MD"
rm -rf "$ATTACHMENTS_DIR"
cp "$INPUT_ABS" "$OUTPUT_ABS/$INPUT_NAME"

case "$INPUT_EXT_LOWER" in
  md|markdown|txt|csv|tsv|json|xml|yaml|yml)
    ADAPTER='copy-text'
    NOTES='Text-like file copied directly into source.md.'
    copy_text_like
    ;;
  docx|doc|pdf|pptx|ppt|xlsx|xls|html|htm)
    if can_use_markitdown && run_markitdown 2>"$TMP_STDERR"; then
      ADAPTER='markitdown'
      NOTES='Converted with markitdown.'
    else
      case "$INPUT_EXT_LOWER" in
        docx)
          if command -v pandoc >/dev/null 2>&1 && run_pandoc_docx 2>"$TMP_STDERR"; then
            ADAPTER='pandoc'
            NOTES='markitdown unavailable or failed; used pandoc fallback with attachment extraction.'
          else
            STATUS='failed'
            ADAPTER='none'
            NOTES='No compatible adapter available for DOCX.'
          fi
          ;;
        pdf)
          if command -v pdftotext >/dev/null 2>&1 && run_pdftotext 2>"$TMP_STDERR"; then
            ADAPTER='pdftotext'
            NOTES='markitdown unavailable or failed; used pdftotext fallback.'
          else
            STATUS='failed'
            ADAPTER='none'
            NOTES='No compatible adapter available for PDF.'
          fi
          ;;
        *)
          STATUS='failed'
          ADAPTER='none'
          NOTES='markitdown is required for this file type.'
          ;;
      esac
    fi
    ;;
  *)
    STATUS='failed'
    ADAPTER='none'
    NOTES="Unsupported file extension: .$INPUT_EXT_LOWER"
    ;;
esac

if [ "$STATUS" = 'success' ] && [ ! -s "$SOURCE_MD" ]; then
  STATUS='warning'
  NOTES="$NOTES Output markdown is empty."
fi

if [ -s "$TMP_STDERR" ]; then
  STDERR_SUMMARY="$(tr '\n' ' ' < "$TMP_STDERR" | sed 's/[[:space:]]\+/ /g' | sed 's/^ //; s/ $//')"
  if [ -n "$STDERR_SUMMARY" ]; then
    NOTES="$NOTES stderr: $STDERR_SUMMARY"
  fi
fi

write_metadata "$OUTPUT_ABS/$INPUT_NAME"

printf 'adapter\t%s\n' "$ADAPTER"
printf 'status\t%s\n' "$STATUS"
printf 'source_kind\t%s\n' "$SOURCE_KIND"
printf 'source_file\t%s\n' "$INPUT_ABS"
printf 'source_md\t%s\n' "$SOURCE_MD"
printf 'output_dir\t%s\n' "$OUTPUT_ABS"
printf 'notes\t%s\n' "$NOTES"

if [ "$STATUS" = 'failed' ]; then
  exit 1
fi
