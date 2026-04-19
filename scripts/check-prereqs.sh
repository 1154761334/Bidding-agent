#!/usr/bin/env bash
set -euo pipefail

echo '== Bidding-agent prerequisite check =='

echo
printf '%-18s' 'python3:'
if command -v python3 >/dev/null 2>&1; then
  python3 --version
else
  echo 'missing'
fi

printf '%-18s' 'pip:'
if command -v pip3 >/dev/null 2>&1; then
  pip3 --version | cut -d' ' -f1-2
else
  echo 'missing'
fi

printf '%-18s' 'hermes:'
if command -v hermes >/dev/null 2>&1; then
  hermes --version | head -n 1
else
  echo 'missing'
fi

printf '%-18s' 'pandoc:'
if command -v pandoc >/dev/null 2>&1; then
  pandoc --version | head -n 1
else
  echo 'missing (recommended for docx ingestion)'
fi

printf '%-18s' 'pdftotext:'
if command -v pdftotext >/dev/null 2>&1; then
  pdftotext -v 2>&1 | head -n 1
else
  echo 'missing (optional for text PDF extraction)'
fi

printf '%-18s' 'tesseract:'
if command -v tesseract >/dev/null 2>&1; then
  tesseract --version | head -n 1
else
  echo 'missing (optional for OCR on scanned files)'
fi

printf '%-18s' 'OVP local src:'
OVP_LOCAL_PATH_CHECK="${OVP_LOCAL_PATH:-/root/bid-stack/obsidian_vault_pipeline}"
if [ -d "$OVP_LOCAL_PATH_CHECK/.git" ]; then
  printf '%s\n' "$OVP_LOCAL_PATH_CHECK (recommended)"
else
  echo "missing (clone your fork or set OVP_LOCAL_PATH)"
fi

printf '%-18s' 'ovp:'
if command -v ovp >/dev/null 2>&1; then
  ovp --help >/dev/null 2>&1 && echo 'installed'
else
  echo 'missing'
fi

printf '%-18s' 'obsidian:'
if command -v obsidian >/dev/null 2>&1; then
  obsidian --version || true
else
  echo 'not found in PATH (desktop app can still be installed manually)'
fi

echo
echo 'Recommended stack:'
echo '1. Hermes installed and working'
echo '2. Your OVP fork cloned under /root/bid-stack/obsidian_vault_pipeline or exposed via OVP_LOCAL_PATH'
echo '3. OVP installed in editable mode with bash scripts/install-ovp.sh local'
echo '4. pandoc installed for docx -> markdown bundles'
echo '5. pdftotext and/or tesseract available for optional PDF/OCR assistance'
echo '6. Obsidian Desktop installed manually for vault viewing/editing'
