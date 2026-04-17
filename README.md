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
- `docs/` — architecture, workflow, deployment, repository boundary
- `templates/workspace/` — recommended workspace skeleton
- `scripts/init-workspace.sh` — initialize a clean bid workspace
- `examples/demo-project/` — lightweight sanitized demo description

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
5. outline generation
6. user confirmation gate
7. drafting
8. review
9. formal-delivery conversion
10. knowledge backflow

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
请作为投标经理读取当前工作区材料，先完成项目启动咨询，再解析招标文件、整理证据、生成目录占位，并在需要时启用内部 sub agent。
```

## Key rules

- do not enter chapter drafting before outline confirmation
- do not output formal qualification claims without evidence
- do not mix vendor capability with bidder-owned capability
- do not fabricate page numbers for unfinished sections
- do not leak internal process text into formal delivery drafts

## Repository status

This repo is being consolidated from an earlier local prototype workspace that already validated:
- bid-vault knowledge layout
- 2+1 sub-agent orchestration
- evidence-page concept
- review-loop concept

See `docs/` for the cleaned product architecture.
