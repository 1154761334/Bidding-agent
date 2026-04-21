#!/usr/bin/env bash
set -euo pipefail

# Initialize the company-wide knowledge vault.
# This is a one-time setup; re-running is safe (idempotent).

STACK_ROOT="${BID_STACK_ROOT:-/root/bid-stack}"
VAULT_DIR="${VAULT_DIR:-$STACK_ROOT/vault}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_TEMPLATE="$SCRIPT_DIR/../templates/ovp-vault.env.example"

mkdir -p \
  "$VAULT_DIR/raw/historical-bids" \
  "$VAULT_DIR/raw/company-credentials" \
  "$VAULT_DIR/raw/vendor-solutions" \
  "$VAULT_DIR/raw/attachments" \
  "$VAULT_DIR/wiki/capabilities" \
  "$VAULT_DIR/wiki/cases" \
  "$VAULT_DIR/wiki/packs" \
  "$VAULT_DIR/wiki/mappings" \
  "$VAULT_DIR/wiki/templates" \
  "$VAULT_DIR/wiki/evidence" \
  "$VAULT_DIR/wiki/reports"

if [ -f "$ENV_TEMPLATE" ] && [ ! -f "$VAULT_DIR/.env" ]; then
  cp "$ENV_TEMPLATE" "$VAULT_DIR/.env"
  printf 'Vault .env created from template.\n'
fi

cat > "$VAULT_DIR/README.md" <<'EOF'
# Company Knowledge Vault

This is the single, permanent knowledge store for the bidding entity.
All project workspaces read from this vault; no project-specific data belongs here.

## Structure

- `raw/` — immutable source materials (historical bids, credentials, vendor docs)
- `wiki/` — curated, promoted knowledge pages
- `.env` — OVP API configuration
EOF

printf 'Vault initialized at %s\n' "$VAULT_DIR"
