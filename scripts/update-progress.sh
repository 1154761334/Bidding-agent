#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo 'Usage: bash scripts/update-progress.sh <workspace-dir> <phase-number> <status> [artifact...]' >&2
  echo '' >&2
  echo 'phase-number: 1-15' >&2
  echo 'status:       in-progress | done | blocked' >&2
  echo 'artifact:     optional basename(s) produced in this phase' >&2
  exit 1
}

if [ "$#" -lt 3 ]; then
  usage
fi

WORKSPACE_DIR="$1"
PHASE_NUM="$2"
PHASE_STATUS="$3"
shift 3
ARTIFACTS=("$@")

RUN_DIR="$WORKSPACE_DIR/output"
PROGRESS_JSON="$RUN_DIR/PROGRESS.json"
PROGRESS_MD="$RUN_DIR/PROGRESS.md"

if [ ! -d "$RUN_DIR" ]; then
  echo "Project output folder not found: $RUN_DIR" >&2
  exit 1
fi

if [ ! -f "$PROGRESS_JSON" ]; then
  echo "PROGRESS.json not found: $PROGRESS_JSON" >&2
  echo "Run bash scripts/start-bid-manager.sh $WORKSPACE_DIR --dry-run once, or bootstrap the workspace manually." >&2
  exit 1
fi

case "$PHASE_STATUS" in
  in-progress|done|blocked) ;;
  *)
    echo "Invalid status: $PHASE_STATUS (must be in-progress|done|blocked)" >&2
    exit 1
    ;;
esac

if ! echo "$PHASE_NUM" | grep -qE '^[0-9]+$' || [ "$PHASE_NUM" -lt 1 ] || [ "$PHASE_NUM" -gt 15 ]; then
  echo "Invalid phase number: $PHASE_NUM (must be 1-15)" >&2
  exit 1
fi

ARTIFACTS_JSON="["
for i in "${!ARTIFACTS[@]}"; do
  if [ "$i" -gt 0 ]; then
    ARTIFACTS_JSON+=","
  fi
  ARTIFACTS_JSON+="\"${ARTIFACTS[$i]}\""
done
ARTIFACTS_JSON+="]"

python3 - "$PROGRESS_JSON" "$PROGRESS_MD" "$PHASE_NUM" "$PHASE_STATUS" "$ARTIFACTS_JSON" <<'PY'
import json
import sys
import datetime as dt

progress_path = sys.argv[1]
md_path = sys.argv[2]
phase_num = int(sys.argv[3])
phase_status = sys.argv[4]
new_artifacts = json.loads(sys.argv[5])

with open(progress_path, "r", encoding="utf-8") as fh:
    data = json.load(fh)

PHASE_NAMES = {
    1: "intake", 2: "workspace-check", 3: "normalization",
    4: "parse-skeleton", 5: "tender-parse", 6: "knowledge-retrieval",
    7: "evidence", 8: "mapping", 9: "outline", 10: "confirmation",
    11: "drafting", 12: "compliance", 13: "formatting",
    14: "qa-audit", 15: "release",
}

phase_key = f"{phase_num}-{PHASE_NAMES[phase_num]}"
now = dt.datetime.now().astimezone().isoformat(timespec="seconds")

if phase_key not in data["phases"]:
    print(f"Unknown phase key: {phase_key}", file=sys.stderr)
    sys.exit(1)

phase = data["phases"][phase_key]
phase["status"] = phase_status
phase["ts"] = now

existing = phase.get("artifacts", [])
for a in new_artifacts:
    if a not in existing:
        existing.append(a)
phase["artifacts"] = existing

if phase_status in ("in-progress", "done"):
    data["current_phase"] = phase_num
    data["phase_name"] = PHASE_NAMES[phase_num]

data["last_updated"] = now

with open(progress_path, "w", encoding="utf-8") as fh:
    json.dump(data, fh, indent=2, ensure_ascii=False)
    fh.write("\n")

# Generate PROGRESS.md
STATUS_ICONS = {"pending": "⬜", "in-progress": "🔄", "done": "✅", "blocked": "🚫"}

lines = [
    f"# Progress: {data['project_id']}",
    "",
    f"Last updated: {data['last_updated']}",
    f"Current phase: **{data['current_phase']} — {data['phase_name']}**",
    "",
    "## Phases",
    "",
]

for key in sorted(data["phases"], key=lambda k: int(k.split("-")[0])):
    p = data["phases"][key]
    icon = STATUS_ICONS.get(p["status"], "❓")
    arts = ", ".join(f"`{a}`" for a in p.get("artifacts", [])) or "—"
    ts = p.get("ts") or "—"
    lines.append(f"- {icon} **{key}**: {p['status']} ({ts}) → {arts}")

lines += [
    "",
    "## Gates",
    "",
    f"- Passed: {', '.join(data.get('gates_passed', [])) or '—'}",
    f"- Blocked: {', '.join(data.get('gates_blocked', [])) or '—'}",
    "",
    "## Coverage",
    "",
]

ev = data.get("evidence_coverage", {})
sc = data.get("score_coverage", {})
lines.append(f"- Evidence: {ev.get('covered', 0)}/{ev.get('total', 0)} (missing: {ev.get('missing', 0)})")
lines.append(f"- Score points: {sc.get('covered', 0)}/{sc.get('total', 0)} (missing: {sc.get('missing', 0)})")
lines.append("")

with open(md_path, "w", encoding="utf-8") as fh:
    fh.write("\n".join(lines))

print(f"Updated phase {phase_key} -> {phase_status}")
PY

printf 'Progress updated: %s phase %s -> %s\n' "$PROGRESS_JSON" "$PHASE_NUM" "$PHASE_STATUS"
