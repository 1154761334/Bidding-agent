#!/usr/bin/env bash
set -euo pipefail

OVP_FORK_URL="https://github.com/1154761334/obsidian_vault_pipeline.git"
DEFAULT_LOCAL_PATH="/root/bid-stack/obsidian_vault_pipeline"
MODE="${1:-local}"

run_pip_install() {
  if python3 -m pip install --user "$@"; then
    return 0
  fi

  echo 'Retrying with --break-system-packages due to externally managed Python environment...' >&2
  python3 -m pip install --user --break-system-packages "$@"
}

case "$MODE" in
  local)
    LOCAL_PATH="${OVP_LOCAL_PATH:-$DEFAULT_LOCAL_PATH}"
    if [ ! -d "$LOCAL_PATH" ]; then
      echo "Local OVP checkout not found: $LOCAL_PATH" >&2
      echo "Clone your fork to $DEFAULT_LOCAL_PATH or set OVP_LOCAL_PATH." >&2
      echo "Fallback install: bash scripts/install-ovp.sh fork" >&2
      exit 1
    fi
    run_pip_install -e "$LOCAL_PATH"
    ;;
  fork|github)
    run_pip_install "git+$OVP_FORK_URL"
    ;;
  pypi)
    run_pip_install obsidian-vault-pipeline
    ;;
  *)
    echo 'Usage: bash scripts/install-ovp.sh [local|fork|pypi]' >&2
    exit 1
    ;;
esac

echo 'OVP installation command completed.'
