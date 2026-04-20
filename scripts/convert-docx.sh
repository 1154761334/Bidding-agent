#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 1 ]; then
  echo 'Usage: bash scripts/convert-docx.sh <input.docx> [output-dir]' >&2
  exit 1
fi

INPUT_PATH="$1"

if [ ! -f "$INPUT_PATH" ]; then
  echo "Input file not found: $INPUT_PATH" >&2
  exit 1
fi

if ! command -v pandoc >/dev/null 2>&1; then
  echo 'pandoc is required for DOCX conversion. Install pandoc and retry.' >&2
  exit 1
fi

INPUT_NAME="$(basename "$INPUT_PATH")"
INPUT_DIR="$(cd "$(dirname "$INPUT_PATH")" && pwd -P)"
INPUT_ABS="$INPUT_DIR/$INPUT_NAME"
INPUT_STEM="${INPUT_NAME%.*}"
OUTPUT_DIR="${2:-$(dirname "$INPUT_ABS")/$INPUT_STEM-bundle}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bash "$SCRIPT_DIR/normalize-document.sh" "$INPUT_ABS" "$OUTPUT_DIR" 'docx-helper' >/dev/null

printf 'Normalized %s\n' "$INPUT_ABS"
printf 'Bundle directory: %s\n' "$OUTPUT_DIR"
printf 'Review %s/source.md before adding it to raw/ or a project input folder.\n' "$OUTPUT_DIR"
