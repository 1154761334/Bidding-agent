#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 1 ] || [ "$#" -gt 3 ]; then
  echo 'Usage: bash scripts/start-bid-manager.sh <workspace-dir> [--one-shot] [--dry-run]' >&2
  exit 1
fi

WORKSPACE_DIR="${1%/}"
MODE="interactive"
DRY_RUN=0
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_PATH="$(cd "$SCRIPT_DIR/.." && pwd)/skills/bid-manager"
STACK_ROOT="${BID_STACK_ROOT:-/root/bid-stack}"
VAULT_DIR="${VAULT_DIR:-$STACK_ROOT/vault}"
WORKSPACE_PARENT="$(dirname "$WORKSPACE_DIR")"
PROJECT_ID="$(basename "$WORKSPACE_DIR")"
BOOTSTRAP_NOTE=''

for arg in "${@:2}"; do
  case "$arg" in
    --one-shot) MODE="one-shot" ;;
    --dry-run)  DRY_RUN=1 ;;
    *) echo "Unknown argument: $arg" >&2; exit 1 ;;
  esac
done

# Ensure workspace + vault state using the compatibility helper.
if [ ! -d "$WORKSPACE_DIR/inbox" ] || [ ! -f "$WORKSPACE_DIR/output/PROGRESS.json" ] || [ ! -d "$VAULT_DIR/raw" ]; then
  BID_BOOTSTRAP_QUIET=1 bash "$SCRIPT_DIR/bootstrap-stack.sh" "$PROJECT_ID" "$WORKSPACE_PARENT"
  BOOTSTRAP_NOTE='Workspace/vault scaffolding was created or refreshed automatically.'
fi

WORKSPACE_DIR="$(cd "$WORKSPACE_DIR" && pwd -P)"
VAULT_DIR="$(cd "$VAULT_DIR" && pwd -P)"

if [ ! -d "$SKILL_PATH" ]; then
  echo "Skill path not found: $SKILL_PATH" >&2
  exit 1
fi

# Detect normalization state
PARSE_HINT=''
NORMALIZATION_INDEX="$WORKSPACE_DIR/output/normalized/normalization-index.tsv"
GENERATED_PARSE_PATH="$WORKSPACE_DIR/output/02-TENDER-PARSE.generated.md"

if [ -f "$GENERATED_PARSE_PATH" ]; then
  PARSE_HINT="Generated parse skeleton present at output/02-TENDER-PARSE.generated.md. Review it first."
elif [ -f "$NORMALIZATION_INDEX" ]; then
  PARSE_HINT="Normalized inputs present under output/normalized/. Parse skeleton not yet generated."
else
  PARSE_HINT="Normalization has not been run yet. Run bash scripts/normalize-project-inputs.sh $WORKSPACE_DIR before parsing."
fi

# Detect resume state
PROGRESS_HINT=''
PROGRESS_PATH="$WORKSPACE_DIR/output/PROGRESS.json"
if [ -f "$PROGRESS_PATH" ]; then
  RESUME_PHASE=$(python3 -c "import json; d=json.load(open('$PROGRESS_PATH')); print(d.get('current_phase', 0))" 2>/dev/null || echo 0)
  RESUME_NAME=$(python3 -c "import json; d=json.load(open('$PROGRESS_PATH')); print(d.get('phase_name', 'pending'))" 2>/dev/null || echo 'pending')
  if [ "$RESUME_PHASE" -gt 0 ] 2>/dev/null; then
    PROGRESS_HINT="[RESUME] Last completed phase: $RESUME_PHASE ($RESUME_NAME). Read PROGRESS.json to resume."
  fi
fi

# Detect tool availability
TOOLS_HINT="[TOOLS] Available:"
MARKITDOWN_VENV_BIN="${MARKITDOWN_VENV_DIR:-/root/bid-stack/.venvs/markitdown}/bin/markitdown"
if [ -x "$MARKITDOWN_VENV_BIN" ] || command -v markitdown >/dev/null 2>&1; then
  TOOLS_HINT="$TOOLS_HINT markitdown=yes"
else
  TOOLS_HINT="$TOOLS_HINT markitdown=no"
fi
for tool in pandoc pdftotext; do
  if command -v "$tool" >/dev/null 2>&1; then
    TOOLS_HINT="$TOOLS_HINT ${tool}=yes"
  else
    TOOLS_HINT="$TOOLS_HINT ${tool}=no"
  fi
done
if command -v ovp >/dev/null 2>&1; then
  TOOLS_HINT="$TOOLS_HINT ovp=yes(use bash $SCRIPT_DIR/ovp-bridge.sh <subcommand>)"
else
  TOOLS_HINT="$TOOLS_HINT ovp=no(fallback to grep)"
fi

# Build prompt
PROMPT="Act as the single entry bid-manager for this project workspace."
PROMPT="$PROMPT The company knowledge vault is at $VAULT_DIR — use $VAULT_DIR/raw/ and $VAULT_DIR/wiki/ for reusable knowledge (credentials, cases, vendor materials)."
PROMPT="$PROMPT The current project workspace is at $WORKSPACE_DIR — use $WORKSPACE_DIR/inbox/ for current tender inputs and $WORKSPACE_DIR/output/ for working artifacts."
PROMPT="$PROMPT These two paths are separate: the vault is the permanent company knowledge store; the workspace is the project drafting sandbox."
PROMPT="$PROMPT Start by inspecting inbox/, output/, and output/PROGRESS.json. Treat empty templates as placeholders rather than completed work."
PROMPT="$PROMPT If input files are missing, stop after intake plus a precise missing-material list. Do not pretend parsing or drafting is ready."
PROMPT="$PROMPT Treat historical bids and sample materials in the vault as reference patterns unless the user explicitly confirms they are current-project evidence."
PROMPT="$PROMPT Never infer a mandatory brand, SLA target, staffing level, or certification validity from a sample document when the tender only gives suggested brands or broad requirements."
PROMPT="$PROMPT A sample file with the same project ID, bidder name, product brand, staffing plan, or service metric is still sample-only unless current evidence confirms it for this run."
PROMPT="$PROMPT For any scoring conclusion or draft chapter, separate: tender requirement, current verified evidence, sample/reference only, and unverified gap. Use [待补证据] instead of inventing facts."
PROMPT="$PROMPT When drafting substantive content, append a short source basis for each major section so the user can distinguish tender-derived facts from sample-derived wording."
PROMPT="$PROMPT $PARSE_HINT"
if [ -n "$PROGRESS_HINT" ]; then
  PROMPT="$PROMPT $PROGRESS_HINT"
fi
PROMPT="$PROMPT $TOOLS_HINT"
PROMPT="$PROMPT First milestone only: review normalization manifest, complete project-start sheet, parse tender, classify evidence, produce evidence gap list, create score-point/chapter/evidence mapping, and generate outline placeholders. If evidence is missing, output explicit gaps instead of inventing claims. Stop and ask for confirmation before drafting any full chapter."

if [ "$DRY_RUN" -eq 1 ]; then
  printf 'Vault:     %s\n' "$VAULT_DIR"
  printf 'Workspace: %s\n' "$WORKSPACE_DIR"
  printf 'Skill:     %s\n' "$SKILL_PATH"
  if [ -n "$BOOTSTRAP_NOTE" ]; then
    printf 'Bootstrap: %s\n' "$BOOTSTRAP_NOTE"
  fi
  printf '\nPrompt preview:\n%s\n' "$PROMPT"
  exit 0
fi

if ! command -v hermes >/dev/null 2>&1; then
  echo 'hermes command not found. Install Hermes or use --dry-run to inspect the startup prompt.' >&2
  exit 1
fi

cd "$WORKSPACE_DIR"

if [ "$MODE" = "one-shot" ]; then
  exec hermes chat -s "$SKILL_PATH" -q "$PROMPT"
fi

printf 'Vault:     %s\n' "$VAULT_DIR"
printf 'Workspace: %s\n' "$WORKSPACE_DIR"
printf 'Skill:     %s\n' "$SKILL_PATH"
if [ -n "$BOOTSTRAP_NOTE" ]; then
  printf 'Bootstrap: %s\n' "$BOOTSTRAP_NOTE"
fi
printf '\nSuggested first message:\n%s\n\n' "$PROMPT"
exec hermes -s "$SKILL_PATH"
