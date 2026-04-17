# Setup stack: Hermes + Obsidian + OVP

This document explains the intended product stack for this repository.

The stack has three layers:
1. Hermes = agent runtime
2. Obsidian = human-facing vault viewer/editor
3. Obsidian Vault Pipeline (OVP) = self-managed knowledge-layer engine

## 1. Architecture decision

Recommended architecture:
- `bid-manager` remains the bidding manager agent and workflow engine
- Obsidian is not the main application UI; it is the vault interface
- `obsidian_vault_pipeline` is used as the knowledge-layer management engine
- A bid-specific bridge layer is still needed before/around OVP for tender materials

This means:
- Hermes runs the bidding workflow
- OVP manages compiled vault knowledge
- Obsidian is used to inspect and maintain the vault

## 2. Required components

### A. Hermes
Purpose:
- run `bid-manager`
- coordinate sub-agents
- drive workflow states and output generation

Install:
```bash
curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash
hermes doctor
```

### B. Obsidian
Purpose:
- open and inspect the vault locally
- review `raw / wiki / output / logs`
- manually navigate knowledge pages and artifacts

Note:
- Obsidian is a desktop application, not required for CLI-only runtime
- if Obsidian is not installed, the system can still run in CLI mode
- current local environment check showed: `obsidian` command not found

Install:
- install Obsidian Desktop manually from https://obsidian.md/
- open the generated vault folder after workspace initialization

### C. Obsidian Vault Pipeline (OVP)
Purpose:
- self-managed vault compilation
- raw markdown processing
- registry / lint / knowledge index / pack runtime

Recommended source:
- upstream repo: `https://github.com/fakechris/obsidian_vault_pipeline`

## 3. OVP dependency findings

Based on the local reference copy, the key runtime requirements are:
- Python >= 3.10
- hatchling build backend
- anthropic>=0.21.0
- openai>=1.0.0
- litellm>=1.0.0
- python-dotenv>=1.0.0
- requests>=2.28.0
- pyyaml>=6.0
- feedparser>=6.0.0
- beautifulsoup4>=4.12.0
- tiktoken>=0.5.0
- watchdog>=3.0.0
- networkx>=3.0

Useful optional local tool for bid ingestion:
- `pandoc` for `.docx -> markdown + extracted media`

Current local environment check:
- Python: present
- Hermes: present
- pandoc: present
- Obsidian CLI command: not present

## 4. OVP installation options

### Option A: install from PyPI
```bash
python3 -m pip install --user obsidian-vault-pipeline
```

If user-scoped install fails, upstream provides a helper script pattern and suggests:
- use `pipx install obsidian-vault-pipeline`
- or opt in to `--break-system-packages` only if needed

### Option B: install from local reference checkout
If you already have the reference repo locally:
```bash
cd /path/to/obsidian_vault_pipeline
python3 -m pip install --user -e .
```

### Option C: install from GitHub directly
```bash
python3 -m pip install --user git+https://github.com/fakechris/obsidian_vault_pipeline.git
```

## 5. OVP environment requirements

Important finding from prior testing:
- `ovp --check --vault-dir <vault>` expects a `.env` in the vault root
- do not assume only global shell env is enough

Typical `.env` values are provider/model-related, for example:
- `AUTO_VAULT_API_KEY`
- `AUTO_VAULT_API_BASE`
- `AUTO_VAULT_MODEL`
- optional proxy settings

The exact field names come from the OVP layer, not Hermes.

## 6. Recommended installation sequence for users

### Step 1: install Hermes
```bash
curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash
hermes doctor
```

### Step 2: install OVP
Recommended:
```bash
python3 -m pip install --user obsidian-vault-pipeline
```

Or from local reference / GitHub if you want a pinned source.

### Step 3: install Obsidian Desktop
- install manually from the official website
- later open your vault folder in Obsidian

### Step 4: initialize the bid workspace
```bash
bash scripts/init-workspace.sh /path/to/my-bid-project
```

### Step 5: create vault `.env`
Inside:
```text
/path/to/my-bid-project/bid-vault/.env
```
Add the OVP-required model settings.

### Step 6: open the vault in Obsidian
Open:
```text
/path/to/my-bid-project/bid-vault/
```

### Step 7: start Hermes manager
```bash
cd /path/to/my-bid-project
hermes -s bid-manager
```

## 7. How data enters the system

This is critical.
Do not rely on OVP alone to ingest real tender materials directly.

### Recommended ingestion path

#### Tender documents
Place under:
```text
bid-vault/raw/tenders/
```

#### Historical bids
Place under:
```text
bid-vault/raw/historical-bids/
```

#### Company credentials
Place under:
```text
bid-vault/raw/company-credentials/
```

#### Vendor/original-manufacturer materials
Place under:
```text
bid-vault/raw/vendor-solutions/
```

### DOCX recommendation
For bid materials, prefer:
```bash
pandoc input.docx -t gfm --extract-media=<stem>-media -o <stem>.md
```

Then store as a bundle:
```text
raw/<category>/<doc-name>/
├── source.md
├── attachments/
└── <doc-name>.vault.md
```

### Why this bridge is needed
OVP is not itself a bid-specific parser.
Its default flow is markdown-oriented and pack-oriented.
So the recommended model is:
- keep OVP upstream mostly unmodified
- add a bid-specific bridge layer before OVP
- normalize `.docx / pdf / jpg` into markdown sidecars / OCR sidecars
- let OVP manage the compiled vault
- let Hermes `bid-manager` run the bid workflow on top of that knowledge layer

## 8. How users run the system

There are two practical operating modes.

### Mode A: manager-first workflow (recommended)
User starts Hermes and works through the bid workflow:
```bash
cd /path/to/my-bid-project
hermes -s bid-manager
```

Suggested prompt:
```text
请作为投标经理读取当前工作区材料，先完成项目启动咨询，再解析招标文件、整理证据、建立评分点-章节-证据映射、生成目录占位，并在需要时启用内部 sub agent。
```

### Mode B: knowledge-layer maintenance first
If the user first wants to normalize and maintain the vault layer, they can use OVP commands directly.
Examples from upstream include:
```bash
ovp --check --vault-dir /path/to/my-bid-project/bid-vault
ovp-doctor --pack research-tech --json
ovp-packs
```

But for this product, OVP is not the user-facing workflow center.
Hermes remains the main interaction layer.

## 9. Recommended product framing for the repo

The repository should explain the stack like this:
- Hermes = runtime and orchestration
- bid-manager = user-facing product entry
- Obsidian = vault viewing/editing surface
- OVP = self-managed knowledge-layer engine
- bridge scripts/process = bid-specific ingestion and normalization

## 10. Known limitations right now

1. OVP upstream default pack is not bid-specific
2. bid-specific ingestion bridge is still lightweight, not yet a full dedicated pack
3. Obsidian installation is still a manual desktop step
4. certificate/image-heavy OCR flow is not yet fully automated inside this repo
5. current public repo documents the architecture, but still needs more operator-grade bootstrap guidance

## 11. Recommended next product improvements

Priority order:
1. add a repo-local bootstrap/check script for Hermes + OVP prerequisites
2. add a repo-local OVP setup guide and `.env` example for bid usage
3. add a bid-specific ingestion helper script for `.docx -> bundle`
4. later evaluate whether to build a true `bid` domain pack for OVP
