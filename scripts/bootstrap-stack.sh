#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
  echo 'Usage: bash scripts/bootstrap-stack.sh <project-id> [workspace-root]' >&2
  echo '' >&2
  echo 'Examples:' >&2
  echo '  bash scripts/bootstrap-stack.sh PROJ-001' >&2
  echo '  bash scripts/bootstrap-stack.sh PROJ-001 /custom/path/workspaces' >&2
  exit 1
fi

PROJECT_ID="$1"
STACK_ROOT="${BID_STACK_ROOT:-/root/bid-stack}"
WORKSPACE_ROOT="${2:-$STACK_ROOT/workspaces}"
WORKSPACE_DIR="$WORKSPACE_ROOT/$PROJECT_ID"
VAULT_DIR="${VAULT_DIR:-$STACK_ROOT/vault}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
QUIET="${BID_BOOTSTRAP_QUIET:-0}"

# Ensure the company knowledge vault exists
if [ "$QUIET" = "1" ]; then
  bash "$SCRIPT_DIR/init-vault.sh" >/dev/null
  bash "$SCRIPT_DIR/init-workspace.sh" "$WORKSPACE_DIR" >/dev/null
else
  bash "$SCRIPT_DIR/init-vault.sh"
  bash "$SCRIPT_DIR/init-workspace.sh" "$WORKSPACE_DIR"
fi

# Copy templates into the workspace
TEMPLATE_DIR="$SCRIPT_DIR/../templates"

copy_if_missing() {
  local src="$1"
  local dst="$2"
  if [ -f "$src" ] && [ ! -f "$dst" ]; then
    cp "$src" "$dst"
  fi
}

copy_if_missing "$TEMPLATE_DIR/project-input-manifest.md" "$WORKSPACE_DIR/inbox/PROJECT-INPUT.md"
copy_if_missing "$TEMPLATE_DIR/normalization-manifest.md" "$WORKSPACE_DIR/output/00-NORMALIZATION-MANIFEST.md"
copy_if_missing "$TEMPLATE_DIR/project-start-sheet.md" "$WORKSPACE_DIR/output/01-PROJECT-START.md"
copy_if_missing "$TEMPLATE_DIR/tender-parse-template.md" "$WORKSPACE_DIR/output/02-TENDER-PARSE.md"
copy_if_missing "$TEMPLATE_DIR/evidence-gap-report.md" "$WORKSPACE_DIR/output/03-EVIDENCE-GAPS.md"
copy_if_missing "$TEMPLATE_DIR/score-chapter-evidence-mapping.md" "$WORKSPACE_DIR/output/04-SCORE-CHAPTER-EVIDENCE-MAPPING.md"
copy_if_missing "$TEMPLATE_DIR/outline-template.md" "$WORKSPACE_DIR/output/05-OUTLINE.md"
copy_if_missing "$TEMPLATE_DIR/review-checklist.md" "$WORKSPACE_DIR/output/06-REVIEW-CHECKLIST.md"

# Initialize PROGRESS.json
if [ ! -f "$WORKSPACE_DIR/output/PROGRESS.json" ]; then
  python3 -c "
import json, datetime as dt
data = {
    'schema_version': 2,
    'project_id': '$PROJECT_ID',
    'vault_dir': '$VAULT_DIR',
    'current_phase': 0,
    'phase_name': 'pending',
    'phases': {},
    'gates_passed': [],
    'gates_blocked': [],
    'evidence_coverage': {'total': 0, 'covered': 0, 'missing': 0},
    'score_coverage': {'total': 0, 'covered': 0, 'missing': 0},
    'last_updated': dt.datetime.now().astimezone().isoformat(timespec='seconds'),
}
names = {
    1: 'intake', 2: 'workspace-check', 3: 'normalization',
    4: 'parse-skeleton', 5: 'tender-parse', 6: 'knowledge-retrieval',
    7: 'evidence', 8: 'mapping', 9: 'outline', 10: 'confirmation',
    11: 'drafting', 12: 'compliance', 13: 'formatting',
    14: 'qa-audit', 15: 'release',
}
for num, name in names.items():
    data['phases'][f'{num}-{name}'] = {'status': 'pending', 'ts': None, 'artifacts': []}
with open('$WORKSPACE_DIR/output/PROGRESS.json', 'w') as fh:
    json.dump(data, fh, indent=2, ensure_ascii=False)
    fh.write('\n')
"
fi

# Write workspace README
if [ ! -f "$WORKSPACE_DIR/README.md" ]; then
  cat > "$WORKSPACE_DIR/README.md" <<EOF
# Project workspace: $PROJECT_ID

## Paths
- Project input: \`inbox/\`
- Working output: \`output/\`
- Company knowledge vault: \`$VAULT_DIR\`

## Boundary
- This workspace contains ONLY project-specific data.
- Company knowledge (credentials, cases, vendor materials) is in the vault.
- Do not treat the tender package as long-term knowledge by default.
EOF
fi

if [ "$QUIET" != "1" ]; then
  printf '\n=== Workspace bootstrap complete ===\n'
  printf 'Vault:     %s\n' "$VAULT_DIR"
  printf 'Workspace: %s\n' "$WORKSPACE_DIR"
  printf '\nbootstrap-stack.sh is a compatibility/helper entry.\n'
  printf 'Primary user entry: bash scripts/start-bid-manager.sh %s [--one-shot]\n' "$WORKSPACE_DIR"
  printf '\nNext steps:\n'
  printf '  1. Place tender files under %s/inbox/tender/\n' "$WORKSPACE_DIR"
  printf '  2. Start the manager: bash scripts/start-bid-manager.sh %s --one-shot\n' "$WORKSPACE_DIR"
  printf '  3. Optional manual helpers: normalize-project-inputs.sh / generate-parse-skeleton.sh\n'
fi
