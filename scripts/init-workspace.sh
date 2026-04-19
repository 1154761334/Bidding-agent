#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR="${1:-$(pwd)}"
VAULT_DIR="$TARGET_DIR/bid-vault"

mkdir -p \
  "$VAULT_DIR/00-Schema" \
  "$VAULT_DIR/inbox/projects" \
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
  "$VAULT_DIR/wiki/reports" \
  "$VAULT_DIR/output/project-runs" \
  "$VAULT_DIR/logs/lint-reports"

cat > "$VAULT_DIR/00-Schema/README.md" <<'EOF'
# bid-vault schema

This vault follows the product convention:
- inbox = current project input folders
- raw = immutable source materials
- wiki = compiled reusable knowledge
- output = project-run artifacts
- logs = lint/review traces
EOF

printf 'Initialized workspace at %s\n' "$TARGET_DIR"
