#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 1 ]; then
  echo 'Usage: bash scripts/extract-pdf-text.sh <input.pdf> [output.txt]' >&2
  exit 1
fi

INPUT_PATH="$1"

if [ ! -f "$INPUT_PATH" ]; then
  echo "Input file not found: $INPUT_PATH" >&2
  exit 1
fi

if ! command -v pdftotext >/dev/null 2>&1; then
  echo 'pdftotext is required for PDF text extraction. Install poppler-utils and retry.' >&2
  exit 1
fi

INPUT_NAME="$(basename "$INPUT_PATH")"
INPUT_DIR="$(cd "$(dirname "$INPUT_PATH")" && pwd -P)"
INPUT_ABS="$INPUT_DIR/$INPUT_NAME"
INPUT_STEM="${INPUT_NAME%.*}"
OUTPUT_PATH="${2:-$INPUT_DIR/$INPUT_STEM.txt}"

mkdir -p "$(dirname "$OUTPUT_PATH")"
pdftotext -layout "$INPUT_ABS" "$OUTPUT_PATH"

printf 'Extracted text from %s\n' "$INPUT_ABS"
printf 'Output text: %s\n' "$OUTPUT_PATH"

if [ ! -s "$OUTPUT_PATH" ]; then
  echo 'Warning: extracted text is empty. Review the original PDF or process it with an external scan-recognition tool.' >&2
fi
