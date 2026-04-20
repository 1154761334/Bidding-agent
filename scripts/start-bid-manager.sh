#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 1 ] || [ "$#" -gt 4 ]; then
  echo 'Usage: bash scripts/start-bid-manager.sh <workspace-dir> [project-id] [--one-shot] [--dry-run]' >&2
  exit 1
fi

WORKSPACE_DIR="$1"
PROJECT_ID=""
MODE="interactive"
DRY_RUN=0
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_PATH="$(cd "$SCRIPT_DIR/.." && pwd)/skills/bid-manager"
RUN_STATUS='not created'
PARSE_SKELETON_STATUS='not checked'
PARSE_HINT=''

for arg in "${@:2}"; do
  case "$arg" in
    --one-shot)
      MODE="one-shot"
      ;;
    --dry-run)
      DRY_RUN=1
      ;;
    *)
      if [ -z "$PROJECT_ID" ]; then
        PROJECT_ID="$arg"
      else
        echo "Unknown argument: $arg" >&2
        exit 1
      fi
      ;;
  esac
done

if [ ! -d "$WORKSPACE_DIR/bid-vault" ]; then
  echo "Workspace not initialized: $WORKSPACE_DIR/bid-vault" >&2
  echo 'Run bash scripts/bootstrap-stack.sh <workspace-dir> [project-id] first.' >&2
  exit 1
fi

if [ ! -d "$SKILL_PATH" ]; then
  echo "Skill path not found: $SKILL_PATH" >&2
  exit 1
fi

if [ -n "$PROJECT_ID" ] && [ ! -d "$WORKSPACE_DIR/bid-vault/inbox/projects/$PROJECT_ID" ]; then
  echo "Project folder not found: $WORKSPACE_DIR/bid-vault/inbox/projects/$PROJECT_ID" >&2
  exit 1
fi

if [ -n "$PROJECT_ID" ] && [ ! -d "$WORKSPACE_DIR/bid-vault/output/project-runs/$PROJECT_ID" ]; then
  bash "$SCRIPT_DIR/init-project-run.sh" "$WORKSPACE_DIR" "$PROJECT_ID" >/dev/null
  RUN_STATUS='created automatically'
elif [ -n "$PROJECT_ID" ]; then
  RUN_STATUS='already present'
fi

if [ -n "$PROJECT_ID" ]; then
  NORMALIZED_DIR="$WORKSPACE_DIR/bid-vault/output/project-runs/$PROJECT_ID/normalized"
  NORMALIZATION_INDEX="$NORMALIZED_DIR/normalization-index.tsv"
  GENERATED_PARSE_PATH="$WORKSPACE_DIR/bid-vault/output/project-runs/$PROJECT_ID/02-TENDER-PARSE.generated.md"

  if [ -f "$GENERATED_PARSE_PATH" ]; then
    PARSE_SKELETON_STATUS='generated parse skeleton present'
    PARSE_HINT="First review the generated parse skeleton at bid-vault/output/project-runs/$PROJECT_ID/02-TENDER-PARSE.generated.md before deeper tender parsing."
  elif [ -f "$NORMALIZATION_INDEX" ]; then
    PARSE_SKELETON_STATUS='normalized inputs present; parse skeleton missing'
    PARSE_HINT="Normalized current-project inputs exist under bid-vault/output/project-runs/$PROJECT_ID/normalized/. Run bash scripts/generate-parse-skeleton.sh $WORKSPACE_DIR $PROJECT_ID before deeper tender parsing."
  else
    PARSE_SKELETON_STATUS='normalization not detected'
    PARSE_HINT="Normalization has not been run yet. Run bash scripts/normalize-project-inputs.sh $WORKSPACE_DIR $PROJECT_ID before parsing binary project files."
  fi
fi

PROMPT="Act as the bid-manager for this workspace. Validate bid-vault, treat current project input and reusable knowledge as separate sources of truth, and prioritize the current project input"
if [ -n "$PROJECT_ID" ]; then
  PROMPT="$PROMPT under bid-vault/inbox/projects/$PROJECT_ID/"
else
  PROMPT="$PROMPT under bid-vault/inbox/projects/"
fi
PROMPT="$PROMPT. Use bid-vault/raw/ and bid-vault/wiki/ only as reusable knowledge support, never as a substitute for the current tender package. First inspect normalized current-project inputs under bid-vault/output/project-runs"
if [ -n "$PROJECT_ID" ]; then
  PROMPT="$PROMPT/$PROJECT_ID/normalized/"
fi
PROMPT="$PROMPT when they exist, and fall back to the raw current-project input only when normalization has not been run yet."
if [ -n "$PARSE_HINT" ]; then
  PROMPT="$PROMPT $PARSE_HINT"
fi
PROMPT="$PROMPT First milestone only: review the normalization manifest, complete the project-start sheet, parse the tender plus addenda and project attachments, classify bidder-vs-vendor evidence, produce an evidence gap list, create the score-point/chapter/evidence mapping, and generate outline placeholders. If evidence is missing, output explicit gaps instead of inventing claims. Stop and ask for confirmation before drafting any full chapter. For medium or large projects, separate internal roles for drafting, evidence, compliance, formatting, and quality audit instead of letting one role both write and approve."

if [ "$DRY_RUN" -eq 1 ]; then
  printf 'Workspace: %s\n' "$WORKSPACE_DIR"
  if [ -n "$PROJECT_ID" ]; then
    printf 'Project: %s\n' "$PROJECT_ID"
    printf 'Project run scaffold: %s\n' "$RUN_STATUS"
    printf 'Parse skeleton: %s\n' "$PARSE_SKELETON_STATUS"
  fi
  printf 'Skill: %s\n' "$SKILL_PATH"
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

printf 'Workspace: %s\n' "$WORKSPACE_DIR"
if [ -n "$PROJECT_ID" ]; then
  printf 'Project: %s\n' "$PROJECT_ID"
  printf 'Project run scaffold: %s\n' "$RUN_STATUS"
  printf 'Parse skeleton: %s\n' "$PARSE_SKELETON_STATUS"
fi
printf 'Skill: %s\n' "$SKILL_PATH"
printf '\nSuggested first message:\n%s\n\n' "$PROMPT"
exec hermes -s "$SKILL_PATH"
