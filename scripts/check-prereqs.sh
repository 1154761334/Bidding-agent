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

printf '%-18s' 'markitdown:'
MARKITDOWN_VENV_BIN="${MARKITDOWN_VENV_DIR:-/root/bid-stack/.venvs/markitdown}/bin/markitdown"
GLOBAL_MARKITDOWN_BIN="$(command -v markitdown || true)"
if [ -x "$MARKITDOWN_VENV_BIN" ]; then
  if [ -n "$GLOBAL_MARKITDOWN_BIN" ] && [ "$GLOBAL_MARKITDOWN_BIN" != "$MARKITDOWN_VENV_BIN" ]; then
    printf '%s\n' "$MARKITDOWN_VENV_BIN (venv; global also found at $GLOBAL_MARKITDOWN_BIN)"
    echo 'warning: venv and global markitdown both exist; repo scripts prefer the venv binary.'
  else
    printf '%s\n' "$MARKITDOWN_VENV_BIN (venv)"
  fi
elif command -v markitdown >/dev/null 2>&1; then
  printf '%s\n' "$GLOBAL_MARKITDOWN_BIN (global only; shared environment)"
else
  echo 'missing (recommended default normalizer)'
fi

printf '%-18s' 'pandoc:'
if command -v pandoc >/dev/null 2>&1; then
  pandoc --version | head -n 1
else
  echo 'missing (optional DOCX fallback and media extractor)'
fi

printf '%-18s' 'pdftotext:'
if command -v pdftotext >/dev/null 2>&1; then
  pdftotext -v 2>&1 | head -n 1
else
  echo 'missing (optional plain-text PDF fallback)'
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
echo '4. markitdown installed with bash scripts/install-markitdown.sh venv or venv-clone'
echo '5. pandoc installed for DOCX fallback and attachment extraction when needed'
echo '6. pdftotext installed for simple PDF fallback when markitdown is unavailable'
echo '7. Obsidian Desktop installed manually for vault viewing/editing'
