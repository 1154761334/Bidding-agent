#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 1 ] || [ "$#" -gt 3 ]; then
  echo 'Usage: bash scripts/start-bid-manager.sh <workspace-dir> [project-id] [--one-shot]' >&2
  exit 1
fi

WORKSPACE_DIR="$1"
PROJECT_ID=""
MODE="interactive"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_PATH="$(cd "$SCRIPT_DIR/.." && pwd)/skills/bid-manager"

for arg in "${@:2}"; do
  case "$arg" in
    --one-shot)
      MODE="one-shot"
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

PROMPT="Act as the bid-manager for this workspace. Validate bid-vault, prioritize the current project input"
if [ -n "$PROJECT_ID" ]; then
  PROMPT="$PROMPT under bid-vault/inbox/projects/$PROJECT_ID/"
else
  PROMPT="$PROMPT under bid-vault/inbox/projects/"
fi
PROMPT="$PROMPT, and run phases in order: project-start intake, tender/package parsing, evidence organization, score-point/chapter/evidence mapping, outline placeholders, drafting, compliance review, formatting, and QA audit. For medium or large projects, separate internal roles for drafting, evidence, compliance, formatting, and quality audit instead of letting one role both write and approve. Do not draft full chapters before outline confirmation."

cd "$WORKSPACE_DIR"

if [ "$MODE" = "one-shot" ]; then
  exec hermes chat -s "$SKILL_PATH" -q "$PROMPT"
fi

printf 'Workspace: %s\n' "$WORKSPACE_DIR"
if [ -n "$PROJECT_ID" ]; then
  printf 'Project: %s\n' "$PROJECT_ID"
fi
printf 'Skill: %s\n' "$SKILL_PATH"
printf '\nSuggested first message:\n%s\n\n' "$PROMPT"
exec hermes -s "$SKILL_PATH"
