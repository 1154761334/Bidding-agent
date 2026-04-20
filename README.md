# Bidding-agent

Hermes-based bidding/tender agent system for IT and system-integrator projects.

This repository is the bidding-domain orchestration layer. It exposes one external entrypoint, `bid-manager`, while internally coordinating specialized execution roles over an OVP-backed vault workspace.

## Product position

This is not a generic "write the bid for me" bot.
It is a tender-production stack for scenarios where the bidder may act as:
- prime contractor
- system integrator
- vendor-collaboration lead

The design principles are:
1. one external manager agent
2. evidence-first bid production
3. separation between bidder capability and vendor/original-manufacturer capability
4. separation between writing, checking, formatting, and QA on medium or large projects
5. current tender packages are project-run inputs, not default long-term knowledge assets

## Packaging decision

Treat the product as one deployable stack with two repositories:
- `Bidding-agent` = workflow, templates, startup helpers, and the `bid-manager` skill
- `obsidian_vault_pipeline` = knowledge-layer engine managed from your own fork

Recommended local layout:

```text
/root/bid-stack/
├── Bidding-agent/
├── obsidian_vault_pipeline/
└── workspaces/
    └── <workspace>/
        └── bid-vault/
            ├── 00-Schema/
            ├── inbox/
            │   └── projects/
            ├── raw/
            ├── wiki/
            ├── output/
            └── logs/
```

This keeps the user experience unified without physically merging OVP into this repository.

## Stack model

- Hermes = runtime and orchestration
- `bid-manager` = user-facing bidding manager
- OVP (`obsidian_vault_pipeline`) = knowledge-layer engine
- Obsidian = optional human-facing vault viewer/editor
- helper scripts = lightweight wrappers for workspace bootstrap and file normalization

## Runtime model

External presentation:
- one skill: `bid-manager`
- one persona: 投标经理 Agent
- one main startup path: start Hermes, then let the manager take over the workflow

Internal execution roles:
- `bid-manager` = workflow control, gates, routing, final decisions
- `evidence-agent` = evidence organization and ownership classification
- `drafting-agent` = chapter drafting
- `compliance-agent` = clause/score/evidence cross-check
- `formatting-agent` = formal-delivery cleanup and packaging readiness
- `qa-audit-agent` = independent quality, consistency, and risk audit

For medium and large projects, the same role should not both draft and final-approve the same artifact.

## What is in this repo

- `skills/bid-manager/SKILL.md` — main Hermes skill and entrypoint
- `docs/` — architecture, workflow, deployment, stack setup, repository boundary, multi-agent model
- `templates/` — reusable markdown templates for normalization, intake, evidence, mapping, and review
- `templates/workspace/` — recommended workspace skeleton
- `scripts/bootstrap-stack.sh` — initialize a workspace and optional project folder in one step
- `scripts/start-bid-manager.sh` — validate the workspace and launch Hermes with the manager entrypoint
- `scripts/init-workspace.sh` — initialize the bid workspace layout
- `scripts/new-project-inbox.sh` — scaffold a current project input folder
- `scripts/init-project-run.sh` — scaffold the first-pass working artifacts for one project
- `scripts/normalize-document.sh` — normalize one input file into a Markdown-first bundle
- `scripts/normalize-project-inputs.sh` — normalize one project's current inputs into project-run artifacts
- `scripts/generate-parse-skeleton.sh` — prefill a tender parse skeleton from normalized project inputs
- `scripts/check-normalization-fixtures.sh` — run regression checks across bundled normalization fixtures
- `scripts/install-markitdown.sh` — install the preferred Markdown normalizer into an isolated venv or from a local clone
- `scripts/install-ovp.sh` — install OVP from your fork checkout, fork URL, or PyPI
- `scripts/convert-docx.sh` — compatibility wrapper around the normalization layer for DOCX
- `scripts/extract-pdf-text.sh` — plain-text PDF fallback helper
- `scripts/check-prereqs.sh` — local prerequisite check
- `examples/demo-project/` — sanitized demo materials
- `examples/normalization-fixtures/` — sanitized normalization regression fixtures

## Quick start

### 1. Clone the two repos

```bash
git clone <your-bidding-agent-repo-url> /root/bid-stack/Bidding-agent
git clone https://github.com/1154761334/obsidian_vault_pipeline.git /root/bid-stack/obsidian_vault_pipeline
```

### 2. Install Hermes once if needed

```bash
curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash
hermes doctor
```

### 3. Install OVP from your fork checkout if needed

```bash
cd /root/bid-stack/Bidding-agent
bash scripts/install-ovp.sh local
```

If `ovp` is already installed and working, skip this step.

### 4. Install the preferred document normalizer

```bash
cd /root/bid-stack/Bidding-agent
bash scripts/install-markitdown.sh venv
```

If you prefer a local editable clone instead of PyPI:

```bash
cd /root/bid-stack/Bidding-agent
bash scripts/install-markitdown.sh venv-clone
```

### 5. Bootstrap the workspace and project folder

```bash
cd /root/bid-stack/Bidding-agent
bash scripts/bootstrap-stack.sh /root/bid-stack/workspaces/my-bid-project ctzb-2023110453
```

This creates the workspace, scaffolds the project input folder, creates the project-run output skeleton, and copies the vault `.env` template if it is missing.

### 6. Place materials

- tender package -> `bid-vault/inbox/projects/<project-id>/tender/`
- addenda / clarifications -> `bid-vault/inbox/projects/<project-id>/addenda/`
- project-only bidder materials -> `bid-vault/inbox/projects/<project-id>/company-inputs/`
- project-only vendor materials -> `bid-vault/inbox/projects/<project-id>/vendor-inputs/`
- project-only attachments -> `bid-vault/inbox/projects/<project-id>/project-attachments/`
- reusable long-term materials -> `bid-vault/raw/`
- first-pass working artifacts -> `bid-vault/output/project-runs/<project-id>/`

### 7. Normalize current project inputs

```bash
cd /root/bid-stack/Bidding-agent
bash scripts/normalize-project-inputs.sh /root/bid-stack/workspaces/my-bid-project ctzb-2023110453
```

This writes Markdown-first working copies under `bid-vault/output/project-runs/<project-id>/normalized/` and updates the normalization index.

### 8. Generate the parse skeleton

```bash
cd /root/bid-stack/Bidding-agent
bash scripts/generate-parse-skeleton.sh /root/bid-stack/workspaces/my-bid-project ctzb-2023110453
```

This writes `02-TENDER-PARSE.generated.md` and `parse-input-index.tsv` under the project run directory.

### 9. Start the manager

Interactive startup:

```bash
cd /root/bid-stack/Bidding-agent
bash scripts/start-bid-manager.sh /root/bid-stack/workspaces/my-bid-project ctzb-2023110453
```

Prompt preview without launching Hermes:

```bash
cd /root/bid-stack/Bidding-agent
bash scripts/start-bid-manager.sh /root/bid-stack/workspaces/my-bid-project ctzb-2023110453 --dry-run
```

One-shot initialization:

```bash
cd /root/bid-stack/Bidding-agent
bash scripts/start-bid-manager.sh /root/bid-stack/workspaces/my-bid-project ctzb-2023110453 --one-shot
```

If you prefer to launch Hermes manually:

```bash
cd /root/bid-stack/workspaces/my-bid-project
hermes -s /root/bid-stack/Bidding-agent/skills/bid-manager
```

Then send this first message:

```text
请作为投标经理 Agent 接管当前工作区，优先处理 bid-vault/inbox/projects/ctzb-2023110453/。当前项目输入与长期知识必须分开读取：前者看 bid-vault/inbox/projects/ctzb-2023110453/，后者看 bid-vault/raw/ 与 bid-vault/wiki/。优先读取 bid-vault/output/project-runs/ctzb-2023110453/normalized/ 下的标准化产物，并先检查 00-NORMALIZATION-MANIFEST.md 与 02-TENDER-PARSE.generated.md。然后完成项目启动单、招标解析、证据缺口清单、评分点-章节-证据映射和目录占位，输出到 bid-vault/output/project-runs/ctzb-2023110453/。证据不足时明确报缺，不要编造。目录未经确认，不要直接起草完整正文。
```

Using the local skill path avoids requiring a separate Hermes skill installation step.

## Workflow summary

1. project intake and startup sheet
2. workspace validation
3. current project document normalization
4. parse skeleton generation
5. current tender/package parsing
6. reusable-knowledge retrieval
7. evidence organization and gap listing
8. score-point / chapter / evidence mapping
9. outline generation and user confirmation
10. drafting
11. compliance review
12. formatting
13. QA audit
14. release decision and knowledge backflow

Default V1 milestone before full drafting:
- normalization manifest review
- parse skeleton review
- project-start sheet
- tender parse page
- evidence gap list
- score-point / chapter / evidence mapping
- outline placeholders

## Knowledge boundary

Current project input:
- `bid-vault/inbox/projects/<project-id>/tender/`
- `bid-vault/inbox/projects/<project-id>/addenda/`
- `bid-vault/inbox/projects/<project-id>/company-inputs/`
- `bid-vault/inbox/projects/<project-id>/vendor-inputs/`
- `bid-vault/inbox/projects/<project-id>/project-attachments/`

Reusable knowledge:
- `bid-vault/raw/historical-bids/`
- `bid-vault/raw/company-credentials/`
- `bid-vault/raw/vendor-solutions/`
- `bid-vault/raw/attachments/`
- promoted reusable pages under `bid-vault/wiki/`

OVP should stay the vault knowledge layer.
The tender package itself should remain a current-project input unless you intentionally promote reusable facts or patterns later.

Preferred normalization command:

```bash
bash scripts/normalize-document.sh input.docx /root/bid-stack/workspaces/my-bid-project/doc-normalized tender
```

Project-wide normalization:

```bash
bash scripts/normalize-project-inputs.sh /root/bid-stack/workspaces/my-bid-project ctzb-2023110453
```

Parse skeleton generation:

```bash
bash scripts/generate-parse-skeleton.sh /root/bid-stack/workspaces/my-bid-project ctzb-2023110453
```

Fallback helpers:

```bash
bash scripts/convert-docx.sh input.docx /root/bid-stack/workspaces/my-bid-project/docx-bundle
bash scripts/extract-pdf-text.sh input.pdf /root/bid-stack/workspaces/my-bid-project/pdf-text/input.txt
```

## Core docs

- `docs/architecture.md`
- `docs/normalization-design.md`
- `docs/workflow.md`
- `docs/subagents.md`
- `docs/deployment.md`
- `docs/repository-boundary.md`
- `docs/setup-stack.md`

## Fixture Check

```bash
cd /root/bid-stack/Bidding-agent
bash scripts/check-normalization-fixtures.sh
```

## Key rules

- do not enter full chapter drafting before outline confirmation
- do not output formal qualification or capability claims without evidence
- do not mix bidder capability with vendor/original-manufacturer capability
- do not let one role both draft and final-approve the same artifact on medium or large projects
- do not fabricate page numbers for unfinished sections
- do not leak internal process text into formal delivery drafts
- do not treat historical bid facts as current formal facts without confirmation
- do not treat the current tender package as canonical long-term reusable knowledge by default

## Safe publishing boundary

This repo intentionally excludes:
- current project input folders
- raw tender source files
- exported `.docx` / `.zip` deliverables
- certificate images and other evidence attachments
- large intermediate conversion bundles
- experimental vaults and heavyweight reference data

See `docs/` for the cleaned product architecture and operating model.
