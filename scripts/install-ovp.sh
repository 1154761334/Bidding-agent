#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-pypi}"

case "$MODE" in
  pypi)
    python3 -m pip install --user obsidian-vault-pipeline
    ;;
  github)
    python3 -m pip install --user git+https://github.com/fakechris/obsidian_vault_pipeline.git
    ;;
  local)
    if [ -z "${OVP_LOCAL_PATH:-}" ]; then
      echo 'Set OVP_LOCAL_PATH to your local obsidian_vault_pipeline checkout.' >&2
      exit 1
    fi
    python3 -m pip install --user -e "$OVP_LOCAL_PATH"
    ;;
  *)
    echo 'Usage: bash scripts/install-ovp.sh [pypi|github|local]' >&2
    exit 1
    ;;
esac

echo 'OVP installation command completed.'
