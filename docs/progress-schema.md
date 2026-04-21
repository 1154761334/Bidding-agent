# Progress Schema

This document defines the state persistence model for `bid-manager` project runs.

## Location

```text
workspaces/<project-id>/output/PROGRESS.json
workspaces/<project-id>/output/PROGRESS.md
```

## Purpose

- allow `bid-manager` to resume after interruption
- provide human-readable progress visibility
- enable deterministic validation of artifact completeness

## PROGRESS.json schema

```json
{
  "schema_version": 2,
  "project_id": "<project-id>",
  "vault_dir": "/root/bid-stack/vault",
  "current_phase": 0,
  "phase_name": "pending",
  "phases": {
    "1-intake":              { "status": "pending", "ts": null, "artifacts": [] },
    "2-workspace-check":     { "status": "pending", "ts": null, "artifacts": [] },
    "3-normalization":       { "status": "pending", "ts": null, "artifacts": [] },
    "4-parse-skeleton":      { "status": "pending", "ts": null, "artifacts": [] },
    "5-tender-parse":        { "status": "pending", "ts": null, "artifacts": [] },
    "6-knowledge-retrieval": { "status": "pending", "ts": null, "artifacts": [] },
    "7-evidence":            { "status": "pending", "ts": null, "artifacts": [] },
    "8-mapping":             { "status": "pending", "ts": null, "artifacts": [] },
    "9-outline":             { "status": "pending", "ts": null, "artifacts": [] },
    "10-confirmation":       { "status": "pending", "ts": null, "artifacts": [] },
    "11-drafting":           { "status": "pending", "ts": null, "artifacts": [] },
    "12-compliance":         { "status": "pending", "ts": null, "artifacts": [] },
    "13-formatting":         { "status": "pending", "ts": null, "artifacts": [] },
    "14-qa-audit":           { "status": "pending", "ts": null, "artifacts": [] },
    "15-release":            { "status": "pending", "ts": null, "artifacts": [] }
  },
  "gates_passed": [],
  "gates_blocked": [],
  "evidence_coverage": { "total": 0, "covered": 0, "missing": 0 },
  "score_coverage":    { "total": 0, "covered": 0, "missing": 0 },
  "last_updated": null
}
```

## Field semantics

| Field | Type | Description |
| --- | --- | --- |
| `schema_version` | int | current schema version, `2` |
| `project_id` | string | derived from the workspace basename |
| `vault_dir` | string | absolute path to the shared knowledge vault |
| `current_phase` | int | highest phase number with status `in-progress` or `done` |
| `phase_name` | string | human-readable current phase |
| `phases.<key>.status` | enum | `pending` / `in-progress` / `done` / `blocked` |
| `phases.<key>.ts` | string or null | ISO-8601 timestamp of last status change |
| `phases.<key>.artifacts` | string[] | artifact basenames recorded for that phase |
| `gates_passed` | string[] | cleared gates |
| `gates_blocked` | string[] | currently blocking gates |
| `evidence_coverage` | object | evidence completeness snapshot |
| `score_coverage` | object | scoring completeness snapshot |
| `last_updated` | string or null | timestamp of last update |

## Valid gate identifiers

- `pack-confirmed`
- `normalization-reviewed`
- `parse-reviewed`
- `outline-confirmed`
- `compliance-cleared`
- `formatting-cleared`
- `qa-passed`
- `release-approved`

## Lifecycle

- `start-bid-manager.sh` or `bootstrap-stack.sh` seeds `PROGRESS.json` if missing
- `bid-manager` reads `PROGRESS.json` at session start
- `scripts/update-progress.sh` updates both `PROGRESS.json` and `PROGRESS.md`
- `scripts/validate-project-run.sh` uses the progress file to inspect workspace completeness
