# Deployment

## Runtime stack

This product is designed as a stack, not a single binary:

1. Hermes
   - agent runtime
   - runs `bid-manager`
   - coordinates sub-agents and workflow states

2. Obsidian
   - local vault viewer/editor
   - used by humans to inspect `raw / wiki / output / logs`
   - optional for CLI-only operation, but recommended

3. Obsidian Vault Pipeline (OVP)
   - self-managed vault knowledge engine
   - manages compiled markdown knowledge and derived views
   - should remain the knowledge layer, not the user-facing bid workflow center

## Prerequisites

Required:
- Python 3.10+
- Hermes installed

Recommended:
- pandoc
- Obsidian Desktop
- OVP installed

Quick local check:
```bash
bash scripts/check-prereqs.sh
```

## Install sequence

### 1. Install Hermes
```bash
curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash
hermes doctor
```

### 2. Install OVP
From PyPI:
```bash
bash scripts/install-ovp.sh pypi
```

From GitHub:
```bash
bash scripts/install-ovp.sh github
```

From a local checkout:
```bash
OVP_LOCAL_PATH=/path/to/obsidian_vault_pipeline bash scripts/install-ovp.sh local
```

### 3. Install Obsidian Desktop
Install manually from:
- https://obsidian.md/

This repo does not automate the desktop installation.

### 4. Initialize workspace
```bash
bash scripts/init-workspace.sh /path/to/project
```

### 5. Create vault `.env`
Copy:
```bash
cp templates/ovp-vault.env.example /path/to/project/bid-vault/.env
```

Then fill in the real model settings required by OVP.

## Workspace setup

Initialize a workspace with the helper script:

```bash
bash scripts/init-workspace.sh /path/to/project
```

This creates:

```text
/path/to/project/
└── bid-vault/
    ├── 00-Schema/
    ├── raw/
    ├── wiki/
    ├── output/
    └── logs/
```

## Recommended material placement

```text
bid-vault/raw/
├── tenders/
├── historical-bids/
├── company-credentials/
├── vendor-solutions/
└── attachments/
```

## Ingestion recommendation

For bid/tender materials, OVP should not be treated as the only ingest layer.
Preferred pattern:
1. convert/normalize source files into markdown bundles
2. place them into the vault structure
3. let OVP manage the knowledge layer
4. let Hermes `bid-manager` run the tender workflow above it

Recommended DOCX bridge:
```bash
pandoc input.docx -t gfm --extract-media=<stem>-media -o <stem>.md
```

## Main usage model

Run Hermes with the main skill:

```bash
hermes -s bid-manager
```

Or for a single-shot task:

```bash
hermes chat -s bid-manager -q "请作为投标经理读取当前工作区并启动投标流程"
```

## OVP usage model

OVP is the knowledge-layer engine, not the main user-facing workflow center.

Useful commands include:
```bash
ovp --check --vault-dir /path/to/project/bid-vault
ovp-doctor --pack research-tech --json
ovp-packs
```

## Internal sub-agent policy

Sub-agents are internal implementation details.
The user should not normally invoke them directly.

Recommended internal roles:
- evidence-agent
- technical-agent
- review-agent

## Safe publishing boundary

This repository is product-focused.
Do not publish the following by default:
- real tender source files
- exported bid deliverables
- scanned certificates and identity-sensitive evidence
- large conversion bundles
- project-specific raw vaults

## Suggested future packaging

Possible next steps:
- package `bid-manager` as an installable Hermes skill bundle
- add a bid-specific ingestion helper script for `.docx -> bundle`
- evaluate a true `bid` domain pack for OVP later
