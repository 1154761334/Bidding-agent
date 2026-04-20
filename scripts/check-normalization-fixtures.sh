#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
FIXTURE_DIR="$REPO_DIR/examples/normalization-fixtures"
TMP_DIR="$(mktemp -d)"
PASS_COUNT=0
FAIL_COUNT=0

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

require_file() {
  local path="$1"
  if [ ! -f "$path" ]; then
    echo "Missing fixture file: $path" >&2
    exit 1
  fi
}

run_fixture() {
  local assert_path="$1"
  local fixture_dir fixture_name output_dir input_file allowed_adapters require_attachments
  local actual_adapter actual_status source_md
  local must_contain=()

  fixture_dir="$(dirname "$assert_path")"
  fixture_name="$(basename "$fixture_dir")"
  output_dir="$TMP_DIR/$fixture_name"
  input_file=''
  allowed_adapters=''
  require_attachments='false'

  while IFS=$'\t' read -r key value; do
    case "$key" in
      input_file) input_file="$value" ;;
      allowed_adapters) allowed_adapters="$value" ;;
      require_attachments_dir) require_attachments="$value" ;;
      must_contain) must_contain+=("$value") ;;
      '') ;;
      *) ;;
    esac
  done < "$assert_path"

  require_file "$fixture_dir/$input_file"

  bash "$SCRIPT_DIR/normalize-document.sh" "$fixture_dir/$input_file" "$output_dir" "fixture:$fixture_name" >/dev/null

  actual_adapter="$(awk -F '\t' '$1=="adapter"{print $2}' "$output_dir/summary.tsv")"
  actual_status="$(awk -F '\t' '$1=="status"{print $2}' "$output_dir/summary.tsv")"
  source_md="$output_dir/source.md"

  if [[ ",$allowed_adapters," != *",$actual_adapter,"* ]]; then
    echo "FAIL [$fixture_name] adapter $actual_adapter not in allowed list: $allowed_adapters" >&2
    return 1
  fi

  if [ "$actual_status" = 'failed' ]; then
    echo "FAIL [$fixture_name] normalization failed" >&2
    return 1
  fi

  if [ ! -s "$source_md" ]; then
    echo "FAIL [$fixture_name] source.md is empty" >&2
    return 1
  fi

  for needle in "${must_contain[@]}"; do
    if ! grep -Fq "$needle" "$source_md"; then
      echo "FAIL [$fixture_name] missing expected text: $needle" >&2
      return 1
    fi
  done

  if [ "$require_attachments" = 'true' ] && [ ! -d "$output_dir/attachments" ]; then
    echo "FAIL [$fixture_name] attachments directory missing" >&2
    return 1
  fi

  echo "PASS [$fixture_name] adapter=$actual_adapter status=$actual_status"
}

echo '== Normalization fixture check =='

while IFS= read -r assert_path; do
  if run_fixture "$assert_path"; then
    PASS_COUNT=$((PASS_COUNT + 1))
  else
    FAIL_COUNT=$((FAIL_COUNT + 1))
  fi
done < <(find "$FIXTURE_DIR" -name 'fixture.assert.tsv' | sort)

DOCX_FIXTURE="$FIXTURE_DIR/docx/minimal-bid-docx/minimal-bid.docx"
PDF_FIXTURE="$FIXTURE_DIR/pdf/minimal-bid-pdf/minimal-bid.pdf"

require_file "$DOCX_FIXTURE"
require_file "$PDF_FIXTURE"

DOCX_FALLBACK_DIR="$TMP_DIR/docx-fallback"
if MARKITDOWN_BIN=/bin/false bash "$SCRIPT_DIR/normalize-document.sh" "$DOCX_FIXTURE" "$DOCX_FALLBACK_DIR" 'fallback:docx' >/dev/null; then
  DOCX_ADAPTER="$(awk -F '\t' '$1=="adapter"{print $2}' "$DOCX_FALLBACK_DIR/summary.tsv")"
  if [ "$DOCX_ADAPTER" = 'pandoc' ] && find "$DOCX_FALLBACK_DIR/attachments" -type f | grep -q .; then
    echo "PASS [docx-fallback] adapter=$DOCX_ADAPTER"
    PASS_COUNT=$((PASS_COUNT + 1))
  else
    echo "FAIL [docx-fallback] expected adapter pandoc with extracted attachment files" >&2
    FAIL_COUNT=$((FAIL_COUNT + 1))
  fi
else
  echo 'FAIL [docx-fallback] normalize-document.sh returned non-zero' >&2
  FAIL_COUNT=$((FAIL_COUNT + 1))
fi

PDF_FALLBACK_DIR="$TMP_DIR/pdf-fallback"
if MARKITDOWN_BIN=/bin/false bash "$SCRIPT_DIR/normalize-document.sh" "$PDF_FIXTURE" "$PDF_FALLBACK_DIR" 'fallback:pdf' >/dev/null; then
  PDF_ADAPTER="$(awk -F '\t' '$1=="adapter"{print $2}' "$PDF_FALLBACK_DIR/summary.tsv")"
  if [ "$PDF_ADAPTER" = 'pdftotext' ] && [ -s "$PDF_FALLBACK_DIR/source.md" ]; then
    echo "PASS [pdf-fallback] adapter=$PDF_ADAPTER"
    PASS_COUNT=$((PASS_COUNT + 1))
  else
    echo "FAIL [pdf-fallback] expected adapter pdftotext with non-empty source.md" >&2
    FAIL_COUNT=$((FAIL_COUNT + 1))
  fi
else
  echo 'FAIL [pdf-fallback] normalize-document.sh returned non-zero' >&2
  FAIL_COUNT=$((FAIL_COUNT + 1))
fi

printf '\nFixture summary: %s passed, %s failed\n' "$PASS_COUNT" "$FAIL_COUNT"

if [ "$FAIL_COUNT" -gt 0 ]; then
  exit 1
fi
