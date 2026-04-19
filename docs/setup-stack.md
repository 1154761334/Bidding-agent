# Setup stack: Hermes + OVP + optional Obsidian

This document explains the intended product stack for this repository.

The practical setup is:
1. Hermes = runtime and orchestration
2. OVP (`obsidian_vault_pipeline`) = knowledge-layer engine
3. Obsidian = optional human-facing vault viewer/editor

## 1. Architecture decision

Recommended architecture:
- keep `Bidding-agent` and `obsidian_vault_pipeline` as sibling repositories
- use `bid-manager` as the single workflow entrypoint
- let OVP remain the knowledge-layer engine
- treat Obsidian as optional inspection/editing UI, not a startup blocker

This means:
- Hermes runs the bidding workflow
- OVP manages compiled vault knowledge
- Obsidian is used only when a human wants to inspect the vault visually
- current tender packages stay in project input folders unless promoted later

## 2. What users actually need to pull

The normal user setup is not "install everything from zero every time".
The standard stack is:

```bash
git clone <your-bidding-agent-repo-url> /root/bid-stack/Bidding-agent
git clone https://github.com/1154761334/obsidian_vault_pipeline.git /root/bid-stack/obsidian_vault_pipeline
```

If Hermes, OVP, or Obsidian are already installed and working, do not reinstall them just because a new bid project starts.

## 3. Required components

### A. Hermes
Purpose:
- run `bid-manager`
- coordinate internal execution roles
- keep the workflow centered on one manager-facing conversation

Install once if needed:

```bash
curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash
hermes doctor
```

### B. OVP
Purpose:
- maintain the vault knowledge layer
- provide `.env`-driven model access and vault tooling
- support reusable knowledge promotion outside the immediate project run

Recommended source:
- development fork: `https://github.com/1154761334/obsidian_vault_pipeline`

Recommended install:

```bash
cd /root/bid-stack/Bidding-agent
bash scripts/install-ovp.sh local
```

The helper retries with `--break-system-packages` automatically if plain `pip install --user` is blocked.

### C. Obsidian
Purpose:
- open and inspect the vault locally
- review `inbox / raw / wiki / output / logs`

Notes:
- optional for CLI-only runtime
- useful, but not required to start the manager workflow

Install manually from `https://obsidian.md/` if you want the desktop viewer.

## 4. OVP environment requirement

Important behavior from prior testing:
- `ovp --check --vault-dir <vault>` expects a `.env` in the vault root
- do not assume a global shell environment alone is enough

Typical `.env` values are provider/model-related, for example:
- `AUTO_VAULT_API_KEY`
- `AUTO_VAULT_API_BASE`
- `AUTO_VAULT_MODEL`

The exact field names come from OVP, not Hermes.

## 5. Recommended installation sequence

### Step 1: verify local prerequisites

```bash
cd /root/bid-stack/Bidding-agent
bash scripts/check-prereqs.sh
```

### Step 2: bootstrap the workspace

```bash
cd /root/bid-stack/Bidding-agent
bash scripts/bootstrap-stack.sh /root/bid-stack/workspaces/my-bid-project ctzb-2023110453
```

This does three things:
- initializes the standard workspace layout
- creates the current project input folder
- copies `templates/ovp-vault.env.example` into the vault root if `.env` is missing

### Step 3: fill the project materials

Place files under:

```text
bid-vault/inbox/projects/ctzb-2023110453/
├── PROJECT-INPUT.md
├── tender/
├── company-inputs/
├── vendor-inputs/
└── notes/
```

### Step 4: start the manager

Recommended helper:

```bash
cd /root/bid-stack/Bidding-agent
bash scripts/start-bid-manager.sh /root/bid-stack/workspaces/my-bid-project ctzb-2023110453
```

If you want a one-shot initialization query:

```bash
bash scripts/start-bid-manager.sh /root/bid-stack/workspaces/my-bid-project ctzb-2023110453 --one-shot
```

## 6. How data enters the system

Separate current project input from reusable knowledge assets.

### Current project input

Create a project folder under:

```text
bid-vault/inbox/projects/<project-id>/
```

Recommended layout:

```text
bid-vault/inbox/projects/<project-id>/
├── PROJECT-INPUT.md
├── tender/
├── company-inputs/
├── vendor-inputs/
└── notes/
```

The current tender package belongs here.
It is parsed for the current run, but not treated as default long-term reusable knowledge.

### Reusable knowledge assets

Historical bids:

```text
bid-vault/raw/historical-bids/
```

Company credentials:

```text
bid-vault/raw/company-credentials/
```

Vendor/original-manufacturer materials:

```text
bid-vault/raw/vendor-solutions/
```

### Lightweight helper recommendation

For Office materials, prefer:

```bash
bash scripts/convert-docx.sh input.docx /root/bid-stack/workspaces/my-bid-project/docx-bundle
```

## 7. How users should think about the product

Recommended framing:
- Hermes = runtime and orchestration
- `bid-manager` = user-facing product entry
- OVP = knowledge-layer engine
- Obsidian = optional vault viewer
- helper scripts = workspace bootstrap and startup convenience

The user interacts with one bid manager.
Internally, the manager may dispatch evidence, drafting, compliance, formatting, and QA roles when complexity justifies it.

## 8. Known limitations right now

- the project input model is convention-driven rather than enforced by a full custom bridge
- reusable knowledge promotion is still guided by templates and skill rules, not a dedicated bid pack
- complex PDF/OCR handling is intentionally lightweight in this version
