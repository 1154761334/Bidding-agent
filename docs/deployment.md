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
- `markitdown`
- `pandoc`
- `pdftotext`
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

### 5. Install the preferred document normalizer

```bash
cd /root/bid-stack/Bidding-agent
bash scripts/install-markitdown.sh venv
```

### 6. Fill the project materials

Current project input:

```text
bid-vault/inbox/projects/<project-id>/
├── PROJECT-INPUT.md
├── tender/
├── addenda/
├── company-inputs/
├── project-attachments/
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

Project-run working artifacts:

```text
bid-vault/output/project-runs/<project-id>/
├── 00-NORMALIZATION-MANIFEST.md
├── 01-PROJECT-START.md
├── 02-TENDER-PARSE.md
├── 02-TENDER-PARSE.generated.md
├── 03-EVIDENCE-GAPS.md
├── 04-SCORE-CHAPTER-EVIDENCE-MAPPING.md
├── 05-OUTLINE.md
├── 06-REVIEW-CHECKLIST.md
└── parse-input-index.tsv
```

Normalized current-project bundles:

```text
bid-vault/output/project-runs/<project-id>/normalized/
├── tender/
├── addenda/
├── company-inputs/
├── vendor-inputs/
├── project-attachments/
└── notes/
```

### 7. Normalize current project inputs

```bash
cd /root/bid-stack/Bidding-agent
bash scripts/normalize-project-inputs.sh /root/bid-stack/workspaces/my-bid-project my-project-id
```

### 8. Generate the parse skeleton

```bash
cd /root/bid-stack/Bidding-agent
bash scripts/generate-parse-skeleton.sh /root/bid-stack/workspaces/my-bid-project my-project-id
```

### 9. Start the manager

Interactive mode:

```bash
cd /root/bid-stack/Bidding-agent
bash scripts/start-bid-manager.sh /root/bid-stack/workspaces/my-bid-project my-project-id
```

Prompt preview:

```bash
cd /root/bid-stack/Bidding-agent
bash scripts/start-bid-manager.sh /root/bid-stack/workspaces/my-bid-project my-project-id --dry-run
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
2. normalize current-project files into `output/project-runs/<project-id>/normalized/`
3. generate a parse skeleton from the normalization index
4. place reusable company/vendor materials under `raw/`
5. let OVP manage the knowledge layer
6. let Hermes `bid-manager` run the workflow above it

Recommended project normalization helper:

```bash
bash scripts/normalize-project-inputs.sh /root/bid-stack/workspaces/my-bid-project my-project-id
```

Recommended parse skeleton helper:

```bash
bash scripts/generate-parse-skeleton.sh /root/bid-stack/workspaces/my-bid-project my-project-id
```

Recommended single-file helper:

```bash
bash scripts/normalize-document.sh input.docx /root/bid-stack/workspaces/my-bid-project/doc-normalized tender
```

Fallback helpers:

```bash
bash scripts/convert-docx.sh input.docx /root/bid-stack/workspaces/my-bid-project/docx-bundle
bash scripts/extract-pdf-text.sh input.pdf /root/bid-stack/workspaces/my-bid-project/pdf-text/input.txt
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
