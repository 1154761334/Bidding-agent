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
echo '2. OVP installed for vault self-management'
echo '3. pandoc installed for docx -> markdown bundles'
echo '4. Obsidian Desktop installed manually for vault viewing/editing'
