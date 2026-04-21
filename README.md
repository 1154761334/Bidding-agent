# Bidding-agent

Hermes-based bidding/tender workflow layer for IT and system-integrator projects.

This repository exposes one formal user-facing entrypoint, `bid-manager`. The recommended CLI wrapper is `scripts/start-bid-manager.sh`; other shell scripts are deterministic helpers for installation, normalization, validation, and backward compatibility.

## Product position

This is not a generic "write the bid for me" bot.
It is a bid-production workflow that keeps three things explicit:

1. one external manager agent
2. evidence-first production
3. strict separation between current project input and long-term reusable knowledge

The manager may internally coordinate evidence, drafting, compliance, formatting, and QA roles, but the user should still experience one workflow owner.

## Stack layout

Recommended local layout:

```text
/root/bid-stack/
├── Bidding-agent/
├── obsidian_vault_pipeline/
├── vault/
└── workspaces/
    └── <project-id>/
        ├── inbox/
        ├── output/
        └── logs/
```

- `vault/` is the permanent company knowledge store.
- `workspaces/<project-id>/` is the project sandbox for the current tender run.
- `obsidian_vault_pipeline` stays as a sibling checkout; do not vendor OVP into this repo.

## Primary user flow

### 1. Clone the repos

```bash
git clone <your-bidding-agent-repo-url> /root/bid-stack/Bidding-agent
git clone https://github.com/1154761334/obsidian_vault_pipeline.git /root/bid-stack/obsidian_vault_pipeline
```

### 2. Install Hermes if needed

```bash
curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash
hermes doctor
```

### 3. Install optional helpers if needed

OVP:

```bash
cd /root/bid-stack/Bidding-agent
bash scripts/install-ovp.sh local
```

Preferred normalizer:

```bash
cd /root/bid-stack/Bidding-agent
bash scripts/install-markitdown.sh venv
```

### 4. Initialize a workspace through the manager entry

Run the manager wrapper once. It will auto-create the flat workspace skeleton and the shared `vault/` if they are missing.

```bash
cd /root/bid-stack/Bidding-agent
bash scripts/start-bid-manager.sh /root/bid-stack/workspaces/ctzb-2023110453 --dry-run
```

This creates or refreshes:

- `/root/bid-stack/vault/`
- `/root/bid-stack/workspaces/ctzb-2023110453/inbox/`
- `/root/bid-stack/workspaces/ctzb-2023110453/output/`
- `/root/bid-stack/workspaces/ctzb-2023110453/logs/`

### 5. Place materials

Current project input goes into the workspace:

- `inbox/tender/`
- `inbox/addenda/`
- `inbox/company-inputs/`
- `inbox/vendor-inputs/`
- `inbox/project-attachments/`
- `inbox/notes/`

Reusable long-term material goes into the vault:

- `vault/raw/historical-bids/`
- `vault/raw/company-credentials/`
- `vault/raw/vendor-solutions/`

### 6. Start the manager

Recommended one-command kickoff:

```bash
cd /root/bid-stack/Bidding-agent
bash scripts/start-bid-manager.sh /root/bid-stack/workspaces/ctzb-2023110453 --one-shot
```

Interactive mode:

```bash
cd /root/bid-stack/Bidding-agent
bash scripts/start-bid-manager.sh /root/bid-stack/workspaces/ctzb-2023110453
```

`start-bid-manager.sh` prints the exact kickoff prompt, checks `output/PROGRESS.json`, and tells the manager where to look for project input versus reusable knowledge.

## What the manager should do first

V1 default milestone before full drafting:

1. review normalization state
2. complete the project-start sheet
3. parse the tender and addenda
4. produce the evidence gap list
5. produce the score-point / chapter / evidence mapping
6. generate outline placeholders

The manager should stop for confirmation before substantive chapter drafting.

## Manual helpers

These scripts remain available, but they are not the primary product entry:

- `scripts/bootstrap-stack.sh` — compatibility/helper workspace bootstrap
- `scripts/normalize-project-inputs.sh` — normalize all project inputs under `inbox/`
- `scripts/generate-parse-skeleton.sh` — prefill `02-TENDER-PARSE.generated.md`
- `scripts/validate-project-run.sh` — check the current workspace state
- `scripts/update-progress.sh` — update `output/PROGRESS.json` and `output/PROGRESS.md`
- `scripts/normalize-document.sh` — normalize a single file into a Markdown-first bundle
- `scripts/check-prereqs.sh` — local prerequisite check
- `scripts/check-normalization-fixtures.sh` — normalization regression check

## Knowledge boundary

Current project input:

- `workspaces/<id>/inbox/`
- normalized outputs under `workspaces/<id>/output/normalized/`
- parse, mapping, review, and draft artifacts under `workspaces/<id>/output/`

Reusable knowledge:

- `vault/raw/`
- `vault/wiki/`

The current tender package is not long-term knowledge by default.

Historical bids or prior draft samples may be loaded into the local vault for private evaluation, but they remain reference material unless explicitly confirmed as current-project evidence.
Even if a sample file shares the same project ID, its bidder identity, brand choice, staffing, certificates, or delivery metrics must still be treated as sample-only until current evidence confirms them.

## Core docs

- `docs/architecture.md`
- `docs/workflow.md`
- `docs/setup-stack.md`
- `docs/deployment.md`
- `docs/normalization-design.md`
- `docs/progress-schema.md`
- `docs/subagents.md`
- `docs/repository-boundary.md`

## Key rules

- keep `bid-manager` as the single formal entrypoint
- keep project input and long-term knowledge separate
- keep tender facts, current verified evidence, and historical sample references explicitly separated
- do not draft full chapters before outline confirmation
- do not output unsupported qualification or capability claims
- do not blur bidder capability and vendor capability
- do not convert a sample brand choice or staffing arrangement into a tender-mandated fact
- do not let the same role both draft and final-approve major output on medium or large projects
- do not treat the current tender package as reusable truth by default

## Verification baseline

```bash
cd /root/bid-stack/Bidding-agent
bash -n scripts/*.sh
bash scripts/smoke-test-e2e.sh
```
