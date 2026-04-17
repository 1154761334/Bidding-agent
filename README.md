# Bidding-agent

Hermes-based bidding/tender agent system for IT/system-integrator projects.

This repository packages a single external entrypoint, `bid-manager`, that presents as a "投标经理 Agent" while internally coordinating sub-agents for evidence handling, technical drafting, and review.

## Product positioning

This is not a generic writing bot.
It is a tender-production workflow for projects where the bidder often acts as:
- prime contractor
- system integrator
- vendor-collaboration lead

The system is designed around four principles:
1. single external manager agent
2. evidence-first bid production
3. strict separation between bidder capability and vendor/original-manufacturer capability
4. Obsidian-style AI-managed knowledge base with `raw / wiki / output / logs`

## What is in this repo

- `skills/bid-manager/SKILL.md` — main Hermes skill and product entrypoint
- `docs/` — architecture, workflow, deployment, repository boundary, sub-agent model
- `templates/` — reusable markdown templates for intake, evidence, mapping, and review
- `templates/workspace/` — recommended workspace skeleton
- `scripts/init-workspace.sh` — initialize a clean bid workspace
- `examples/demo-project/` — lightweight sanitized demo materials

## Intended runtime model

External presentation:
- one agent only: `bid-manager`
- one identity only: 投标经理 Agent

Internal execution:
- manager agent
- evidence sub-agent
- technical sub-agent
- optional review sub-agent

The user should feel like they are talking to one bid manager, not manually orchestrating multiple tools.

## Recommended workspace layout

```text
<workspace>/
├── bid-vault/
│   ├── 00-Schema/
│   ├── raw/
│   ├── wiki/
│   ├── output/
│   └── logs/
├── docs/
├── skills/
└── scripts/
```

## Safe publishing policy used in this repo

This repository intentionally excludes:
- raw tender source files
- exported `.docx` / `.zip` deliverables
- certificate images and other evidence attachments
- large intermediate conversion bundles
- experimental vaults and heavyweight reference data

Only product-facing docs, templates, and skill definitions are published by default.

## Main workflow

1. project intake
2. workspace check
3. tender/package parsing
4. evidence organization
5. score-point / chapter / evidence mapping
6. outline generation
7. user confirmation gate
8. drafting
9. review
10. formal-delivery conversion
11. knowledge backflow

## Core public assets in this version

### Main skill
- `skills/bid-manager/SKILL.md`

### Product docs
- `docs/architecture.md`
- `docs/workflow.md`
- `docs/subagents.md`
- `docs/deployment.md`
- `docs/repository-boundary.md`

### Reusable templates
- `templates/project-start-sheet.md`
- `templates/score-chapter-evidence-mapping.md`
- `templates/evidence-page-template.md`
- `templates/review-checklist.md`

### Demo
- `examples/demo-project/README.md`
- `examples/demo-project/session-example.md`

## Why this architecture

Compared with a normal “write the bid for me” agent, this system adds:
- score-point / chapter / evidence mapping
- rejection-risk awareness
- vendor-vs-integrator capability boundary control
- formal-delivery cleanup rules
- reusable knowledge accumulation in Obsidian-style vault structure

## Quick start

### 1. Initialize a workspace

```bash
bash scripts/init-workspace.sh /path/to/my-bid-project
```

### 2. Start the manager skill in Hermes

```bash
cd /path/to/my-bid-project
hermes -s bid-manager
```

### 3. Example prompt

```text
请作为投标经理读取当前工作区材料，先完成项目启动咨询，再解析招标文件、整理证据、建立评分点-章节-证据映射、生成目录占位，并在需要时启用内部 sub agent。
```

## Key rules

- do not enter chapter drafting before outline confirmation
- do not output formal qualification claims without evidence
- do not mix vendor capability with bidder-owned capability
- do not fabricate page numbers for unfinished sections
- do not leak internal process text into formal delivery drafts
- do not treat historical bid facts as current formal facts without confirmation

## Repository status

This repo is being consolidated from an earlier local prototype workspace that already validated:
- bid-vault knowledge layout
- 2+1 sub-agent orchestration
- evidence-page concept
- review-loop concept
- internal-vs-formal draft separation concerns

See `docs/` for the cleaned product architecture.
