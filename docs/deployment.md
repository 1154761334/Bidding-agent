# Deployment

## Runtime stack

This product is deployed as a stack, not a single binary:

1. Hermes
   - agent runtime
   - runs `bid-manager`
2. OVP
   - knowledge-layer engine
   - manages reusable company knowledge in `vault/`
3. Obsidian
   - optional local viewer/editor

## Recommended deployment layout

```text
/root/bid-stack/
├── Bidding-agent/
├── obsidian_vault_pipeline/
├── vault/
└── workspaces/
    └── <project-id>/
```

Keep `Bidding-agent` and OVP as sibling repos.
Do not vendor OVP into this repo.

## Deployment sequence

### 1. Ensure the repos are present

```bash
git clone <your-bidding-agent-repo-url> /root/bid-stack/Bidding-agent
git clone https://github.com/1154761334/obsidian_vault_pipeline.git /root/bid-stack/obsidian_vault_pipeline
```

### 2. Ensure Hermes is installed

```bash
curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash
hermes doctor
```

### 3. Ensure optional helpers are installed

```bash
cd /root/bid-stack/Bidding-agent
bash scripts/install-ovp.sh local
bash scripts/install-markitdown.sh venv
```

### 4. Bootstrap through the manager wrapper

```bash
cd /root/bid-stack/Bidding-agent
bash scripts/start-bid-manager.sh /root/bid-stack/workspaces/my-project --dry-run
```

This wrapper will ensure:

- `vault/`
- `workspaces/my-project/inbox/`
- `workspaces/my-project/output/`
- `workspaces/my-project/logs/`
- template artifacts and `PROGRESS.json`

### 5. Fill project materials

Current project input:

```text
workspaces/my-project/inbox/
├── tender/
├── addenda/
├── company-inputs/
├── vendor-inputs/
├── project-attachments/
└── notes/
```

Reusable knowledge:

```text
vault/raw/
├── historical-bids/
├── company-credentials/
├── vendor-solutions/
└── attachments/
```

### 6. Start the manager

One-shot kickoff:

```bash
cd /root/bid-stack/Bidding-agent
bash scripts/start-bid-manager.sh /root/bid-stack/workspaces/my-project --one-shot
```

Interactive kickoff:

```bash
cd /root/bid-stack/Bidding-agent
bash scripts/start-bid-manager.sh /root/bid-stack/workspaces/my-project
```

## Ingestion policy

For bid/tender work:

1. keep the current tender package in `workspace/inbox/`
2. keep normalized outputs in `workspace/output/normalized/`
3. keep parse, mapping, review, and draft artifacts in `workspace/output/`
4. keep reusable company/vendor material in `vault/raw/`
5. promote only intentionally reusable material into `vault/wiki/`

The current tender package is not reusable truth by default.

## Manual helper commands

Normalize all project inputs:

```bash
bash scripts/normalize-project-inputs.sh /root/bid-stack/workspaces/my-project
```

Generate the parse skeleton:

```bash
bash scripts/generate-parse-skeleton.sh /root/bid-stack/workspaces/my-project
```

Validate the current run:

```bash
bash scripts/validate-project-run.sh /root/bid-stack/workspaces/my-project
```

## Safe publishing boundary

Do not publish by default:

- real project input folders
- raw tender source files
- exported bid deliverables
- scanned certificates and sensitive evidence
- large conversion bundles
- project-specific vault copies
