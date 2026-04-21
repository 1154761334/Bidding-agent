#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat >&2 <<'EOF'
Usage: bash scripts/ovp-bridge.sh <subcommand> [args...]

Subcommands:
  check                 — verify vault health via ovp --check
  query <term>          — search vault knowledge for a term
  absorb <file>         — absorb a file into the vault knowledge layer
  doctor [pack]         — run ovp-doctor, optionally for a specific pack
  index                 — rebuild or show the knowledge index

Uses VAULT_DIR env var (default: /root/bid-stack/vault).
EOF
  exit 1
}

if [ "$#" -lt 1 ]; then
  usage
fi

SUBCMD="$1"
shift

STACK_ROOT="${BID_STACK_ROOT:-/root/bid-stack}"
VAULT_DIR="${VAULT_DIR:-$STACK_ROOT/vault}"

if [ ! -d "$VAULT_DIR" ]; then
  echo "error: vault not found at $VAULT_DIR" >&2
  echo "Set VAULT_DIR or run bash scripts/init-vault.sh first." >&2
  exit 1
fi

ovp_available() { command -v ovp >/dev/null 2>&1; }
ovp_query_available() { command -v ovp-query >/dev/null 2>&1; }
ovp_doctor_available() { command -v ovp-doctor >/dev/null 2>&1; }
ovp_absorb_available() { command -v ovp-absorb >/dev/null 2>&1; }
ovp_knowledge_index_available() { command -v ovp-knowledge-index >/dev/null 2>&1; }

degraded_fallback() {
  local subcmd="$1"
  echo "## OVP degraded mode"
  echo ""
  echo "OVP command \`$subcmd\` is not installed."
  echo "Knowledge retrieval is limited to direct file listing."
  echo ""
  echo "Available fallback: browse \`$VAULT_DIR/raw/\` and \`$VAULT_DIR/wiki/\` manually."
  echo ""
  echo "To install OVP:"
  echo '```bash'
  echo "bash scripts/install-ovp.sh local"
  echo '```'
}

case "$SUBCMD" in
  check)
    if ovp_available; then
      echo "## OVP vault check"
      echo ""
      ovp --check --vault-dir "$VAULT_DIR" 2>&1 || true
    else
      degraded_fallback "ovp"
      echo ""
      echo "### Directory structure check (fallback)"
      echo ""
      for subdir in raw wiki; do
        if [ -d "$VAULT_DIR/$subdir" ]; then
          count=$(find "$VAULT_DIR/$subdir" -type f 2>/dev/null | wc -l)
          printf '- ✅ `%s/` — %d files\n' "$subdir" "$count"
        else
          printf '- ❌ `%s/` — missing\n' "$subdir"
        fi
      done
    fi
    ;;

  query)
    if [ "$#" -lt 1 ]; then
      echo "Usage: ovp-bridge.sh query <search-term>" >&2
      exit 1
    fi
    SEARCH_TERM="$1"
    if ovp_query_available; then
      echo "## OVP query: $SEARCH_TERM"
      echo ""
      ovp-query --vault-dir "$VAULT_DIR" "$SEARCH_TERM" 2>&1 || true
    else
      degraded_fallback "ovp-query"
      echo ""
      echo "### Grep fallback: searching raw/ and wiki/"
      echo ""
      for search_dir in "$VAULT_DIR/raw" "$VAULT_DIR/wiki"; do
        if [ -d "$search_dir" ]; then
          echo "#### $(basename "$search_dir")/"
          echo ""
          results=$(grep -rl --include='*.md' "$SEARCH_TERM" "$search_dir" 2>/dev/null | head -20) || true
          if [ -n "$results" ]; then
            echo "$results" | while read -r f; do
              printf '- `%s`\n' "${f#$VAULT_DIR/}"
            done
          else
            echo "- No matches found."
          fi
          echo ""
        fi
      done
    fi
    ;;

  absorb)
    if [ "$#" -lt 1 ]; then
      echo "Usage: ovp-bridge.sh absorb <file-path>" >&2
      exit 1
    fi
    TARGET_FILE="$1"
    if [ ! -f "$TARGET_FILE" ]; then
      echo "error: file not found: $TARGET_FILE" >&2
      exit 1
    fi
    if ovp_absorb_available; then
      echo "## OVP absorb"
      echo ""
      ovp-absorb --vault-dir "$VAULT_DIR" "$TARGET_FILE" 2>&1 || true
    else
      degraded_fallback "ovp-absorb"
      echo ""
      echo "### Manual fallback"
      echo ""
      echo "Copy the file manually to \`$VAULT_DIR/raw/\` or \`$VAULT_DIR/wiki/\`."
    fi
    ;;

  doctor)
    PACK="${1:-}"
    if ovp_doctor_available; then
      echo "## OVP doctor"
      echo ""
      if [ -n "$PACK" ]; then
        ovp-doctor --vault-dir "$VAULT_DIR" --pack "$PACK" --json 2>&1 || true
      else
        ovp-doctor --vault-dir "$VAULT_DIR" --json 2>&1 || true
      fi
    else
      degraded_fallback "ovp-doctor"
    fi
    ;;

  index)
    if ovp_knowledge_index_available; then
      echo "## OVP knowledge index"
      echo ""
      ovp-knowledge-index --vault-dir "$VAULT_DIR" 2>&1 || true
    else
      degraded_fallback "ovp-knowledge-index"
    fi
    ;;

  *)
    echo "Unknown subcommand: $SUBCMD" >&2
    usage
    ;;
esac
