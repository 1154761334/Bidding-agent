# Setup Stack

This document describes the intended local stack for this repository.

## Stack components

1. Hermes
   - runtime and orchestration
   - runs `bid-manager`
2. OVP (`obsidian_vault_pipeline`)
   - knowledge-layer engine
   - manages reusable company knowledge in `vault/`
3. Obsidian
   - optional human-facing viewer/editor for the vault

## Architecture decision

Recommended structure:

- keep `Bidding-agent` and `obsidian_vault_pipeline` as sibling repositories
- keep one shared `vault/`
- keep one workspace per project under `workspaces/<project-id>/`
- keep `bid-manager` as the only formal user-facing entrypoint

## Recommended local layout

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

## Installation sequence

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

### 4. Verify prerequisites

```bash
cd /root/bid-stack/Bidding-agent
bash scripts/check-prereqs.sh
```

## Single-entry startup

Use the manager wrapper as the main startup path. It auto-creates the workspace skeleton and shared vault if they do not exist.

Preview and initialize:

```bash
cd /root/bid-stack/Bidding-agent
bash scripts/start-bid-manager.sh /root/bid-stack/workspaces/ctzb-2023110453 --dry-run
```

Launch and inject the kickoff prompt automatically:

```bash
cd /root/bid-stack/Bidding-agent
bash scripts/start-bid-manager.sh /root/bid-stack/workspaces/ctzb-2023110453 --one-shot
```

Interactive launch:

```bash
cd /root/bid-stack/Bidding-agent
bash scripts/start-bid-manager.sh /root/bid-stack/workspaces/ctzb-2023110453
```

## Data placement

Current project input goes into the workspace:

```text
workspaces/<project-id>/inbox/
├── PROJECT-INPUT.md
├── tender/
├── addenda/
├── company-inputs/
├── vendor-inputs/
├── project-attachments/
└── notes/
```

Reusable knowledge stays in the vault:

```text
vault/raw/
├── historical-bids/
├── company-credentials/
├── vendor-solutions/
└── attachments/
```

Promoted reusable pages stay under:

```text
vault/wiki/
```

Project-run artifacts stay in:

```text
workspaces/<project-id>/output/
├── 00-NORMALIZATION-MANIFEST.md
├── 01-PROJECT-START.md
├── 02-TENDER-PARSE.md
├── 02-TENDER-PARSE.generated.md
├── 03-EVIDENCE-GAPS.md
├── 04-SCORE-CHAPTER-EVIDENCE-MAPPING.md
├── 05-OUTLINE.md
├── 06-REVIEW-CHECKLIST.md
├── PROGRESS.json
├── PROGRESS.md
├── normalized/
├── evidence/
├── drafts/
├── reviews/
└── final/
```

## Manual helpers

The scripts below remain available for deterministic local work, but they are not the recommended top-level entry:

```bash
bash scripts/normalize-project-inputs.sh /root/bid-stack/workspaces/ctzb-2023110453
bash scripts/generate-parse-skeleton.sh /root/bid-stack/workspaces/ctzb-2023110453
bash scripts/validate-project-run.sh /root/bid-stack/workspaces/ctzb-2023110453
```

Single-file helper:

```bash
bash scripts/normalize-document.sh input.docx /root/bid-stack/workspaces/ctzb-2023110453/output/normalized/manual/input-docx tender
```

Fallback helpers:

```bash
bash scripts/convert-docx.sh input.docx /tmp/docx-bundle
bash scripts/extract-pdf-text.sh input.pdf /tmp/input.txt
```

## OVP environment note

OVP expects a `.env` in the vault root.
`scripts/init-vault.sh` seeds `vault/.env` from `templates/ovp-vault.env.example` if needed.
