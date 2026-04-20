#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-venv}"
DEFAULT_REPO_URL="https://github.com/microsoft/markitdown.git"
DEFAULT_CLONE_DIR="${MARKITDOWN_CLONE_DIR:-/root/bid-stack/markitdown}"
DEFAULT_LOCAL_PATH="${MARKITDOWN_LOCAL_PATH:-$DEFAULT_CLONE_DIR/packages/markitdown}"
DEFAULT_VENV_DIR="${MARKITDOWN_VENV_DIR:-/root/bid-stack/.venvs/markitdown}"
MARKITDOWN_EXTRAS="${MARKITDOWN_EXTRAS:-docx,pdf,pptx,xlsx,xls}"

run_pip_install() {
  if python3 -m pip install --user "$@"; then
    return 0
  fi

  echo 'Retrying with --break-system-packages due to externally managed Python environment...' >&2
  python3 -m pip install --user --break-system-packages "$@"
}

resolve_local_path() {
  local candidate="$1"

  if [ -f "$candidate/pyproject.toml" ]; then
    printf '%s\n' "$candidate"
    return 0
  fi

  if [ -f "$candidate/packages/markitdown/pyproject.toml" ]; then
    printf '%s\n' "$candidate/packages/markitdown"
    return 0
  fi

  return 1
}

install_into_venv() {
  local spec="$1"

  python3 -m venv "$DEFAULT_VENV_DIR"
  "$DEFAULT_VENV_DIR/bin/python" -m pip install --upgrade pip
  "$DEFAULT_VENV_DIR/bin/python" -m pip install "$spec"
}

case "$MODE" in
  pypi)
    run_pip_install "markitdown[$MARKITDOWN_EXTRAS]"
    ;;
  venv)
    install_into_venv "markitdown[$MARKITDOWN_EXTRAS]"
    ;;
  local)
    LOCAL_PATH_INPUT="${2:-$DEFAULT_LOCAL_PATH}"
    if ! LOCAL_PATH="$(resolve_local_path "$LOCAL_PATH_INPUT")"; then
      echo "Local markitdown package not found under: $LOCAL_PATH_INPUT" >&2
      echo "Expected either <path>/pyproject.toml or <path>/packages/markitdown/pyproject.toml." >&2
      exit 1
    fi
    run_pip_install -e "$LOCAL_PATH[$MARKITDOWN_EXTRAS]"
    ;;
  venv-local)
    LOCAL_PATH_INPUT="${2:-$DEFAULT_LOCAL_PATH}"
    if ! LOCAL_PATH="$(resolve_local_path "$LOCAL_PATH_INPUT")"; then
      echo "Local markitdown package not found under: $LOCAL_PATH_INPUT" >&2
      echo "Expected either <path>/pyproject.toml or <path>/packages/markitdown/pyproject.toml." >&2
      exit 1
    fi
    install_into_venv "$LOCAL_PATH[$MARKITDOWN_EXTRAS]"
    ;;
  clone)
    if [ ! -d "$DEFAULT_CLONE_DIR/.git" ]; then
      git clone --depth 1 "$DEFAULT_REPO_URL" "$DEFAULT_CLONE_DIR"
    else
      git -C "$DEFAULT_CLONE_DIR" pull --ff-only
    fi
    if ! LOCAL_PATH="$(resolve_local_path "$DEFAULT_CLONE_DIR")"; then
      echo "markitdown checkout is present but package path could not be resolved: $DEFAULT_CLONE_DIR" >&2
      exit 1
    fi
    run_pip_install -e "$LOCAL_PATH[$MARKITDOWN_EXTRAS]"
    ;;
  venv-clone)
    if [ ! -d "$DEFAULT_CLONE_DIR/.git" ]; then
      git clone --depth 1 "$DEFAULT_REPO_URL" "$DEFAULT_CLONE_DIR"
    else
      git -C "$DEFAULT_CLONE_DIR" pull --ff-only
    fi
    if ! LOCAL_PATH="$(resolve_local_path "$DEFAULT_CLONE_DIR")"; then
      echo "markitdown checkout is present but package path could not be resolved: $DEFAULT_CLONE_DIR" >&2
      exit 1
    fi
    install_into_venv "$LOCAL_PATH[$MARKITDOWN_EXTRAS]"
    ;;
  *)
    echo 'Usage: bash scripts/install-markitdown.sh [pypi|venv|local [path]|venv-local [path]|clone|venv-clone]' >&2
    exit 1
    ;;
esac

echo 'markitdown installation command completed.'
if [ -x "$DEFAULT_VENV_DIR/bin/markitdown" ]; then
  echo "Venv binary: $DEFAULT_VENV_DIR/bin/markitdown"
fi
