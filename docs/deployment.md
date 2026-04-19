# Deployment

## Runtime stack

This product is deployed as a stack, not a single binary:

1. Hermes
   - agent runtime
   - runs `bid-manager`
   - coordinates workflow states and internal execution roles

2. OVP
   - self-managed vault knowledge engine
   - manages reusable knowledge and vault-level checks

3. Obsidian
   - optional local vault viewer/editor
   - useful for humans, but not required to launch the manager workflow

## Prerequisites

Required:
- Python 3.10+
- Hermes installed

Recommended:
- OVP installed
- `pandoc`
- `pdftotext`
- `tesseract`
- Obsidian Desktop

Quick local check:

```bash
cd /root/bid-stack/Bidding-agent
bash scripts/check-prereqs.sh
```

## Recommended deployment layout

```text
/root/bid-stack/
├── Bidding-agent/
├── obsidian_vault_pipeline/
└── workspaces/
    └── <workspace>/
        └── bid-vault/
```

Keep `Bidding-agent` and OVP as sibling repos.
Do not vendor OVP into this repo by default.

## Deploy sequence

### 1. Ensure the two repos are present

```bash
git clone <your-bidding-agent-repo-url> /root/bid-stack/Bidding-agent
git clone https://github.com/1154761334/obsidian_vault_pipeline.git /root/bid-stack/obsidian_vault_pipeline
```

### 2. Ensure Hermes is installed

```bash
curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash
hermes doctor
```

### 3. Ensure OVP is installed if needed

```bash
cd /root/bid-stack/Bidding-agent
bash scripts/install-ovp.sh local
```

### 4. Bootstrap the workspace

```bash
cd /root/bid-stack/Bidding-agent
bash scripts/bootstrap-stack.sh /root/bid-stack/workspaces/my-bid-project my-project-id
```

### 5. Fill the project materials

Current project input:

```text
bid-vault/inbox/projects/<project-id>/
├── tender/
├── company-inputs/
├── vendor-inputs/
└── notes/
```

Reusable knowledge:

```text
bid-vault/raw/
├── historical-bids/
├── company-credentials/
├── vendor-solutions/
└── attachments/
```

### 6. Start the manager

Interactive mode:

```bash
cd /root/bid-stack/Bidding-agent
bash scripts/start-bid-manager.sh /root/bid-stack/workspaces/my-bid-project my-project-id
```

One-shot initialization:

```bash
cd /root/bid-stack/Bidding-agent
bash scripts/start-bid-manager.sh /root/bid-stack/workspaces/my-bid-project my-project-id --one-shot
```

If you want to launch Hermes yourself:

```bash
cd /root/bid-stack/workspaces/my-bid-project
hermes -s /root/bid-stack/Bidding-agent/skills/bid-manager
```

## Ingestion recommendation

For bid/tender work, keep the current tender package separate from the reusable knowledge layer.
Preferred pattern:
1. place the current tender package under `inbox/projects/<project-id>/`
2. place reusable company/vendor materials under `raw/`
3. optionally normalize Office files with helper scripts
4. let OVP manage the knowledge layer
5. let Hermes `bid-manager` run the workflow above it

Recommended DOCX helper:

```bash
bash scripts/convert-docx.sh input.docx /root/bid-stack/workspaces/my-bid-project/docx-bundle
```

## OVP usage model

OVP is the knowledge-layer engine, not the main user-facing workflow center.

Useful commands include:

```bash
ovp --check --vault-dir /root/bid-stack/workspaces/my-bid-project/bid-vault
ovp-doctor --pack research-tech --json
ovp-packs
```

## Internal multi-agent policy

Internal roles are implementation details.
The user should normally interact only with `bid-manager`.

Recommended internal roles:
- `evidence-agent`
- `drafting-agent`
- `compliance-agent`
- `formatting-agent`
- `qa-audit-agent`

The goal is to avoid the same role both writing and approving the same major artifact on medium or large projects.

## Safe publishing boundary

This repository is product-focused.
Do not publish the following by default:
- real project input folders
- real tender source files
- exported bid deliverables
- scanned certificates and identity-sensitive evidence
- large conversion bundles
- project-specific raw vaults
