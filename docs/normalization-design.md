# Normalization Design

This document defines the V1 design for the document normalization layer used by the bidding workflow.

The goal is not to build a general ingestion platform.
The goal is to provide one controlled project-run layer between raw current-project files and bid parsing.

## Scope

This layer is responsible for:
- converting current-project files into Markdown-first working copies
- keeping per-file normalization metadata
- recording conversion failures and weak extracts
- providing a stable input surface for `bid-manager`

This layer is not responsible for:
- deciding what is reusable long-term knowledge
- classifying formal evidence ownership
- writing bid chapters
- replacing OVP or Hermes

## 1. Environment policy

### Decision

Do not install normalization adapters into the base Python environment by default.

Preferred install mode:
- isolated virtual environment under `/root/bid-stack/.venvs/markitdown`

Why:
- current machines may already contain packages such as `magic-pdf`
- `markitdown` and its dependencies can upgrade shared libraries such as `pdfminer-six`
- project-level normalization tooling should not break unrelated local document pipelines

### Installation modes

Preferred:
- `bash scripts/install-markitdown.sh venv`
- `bash scripts/install-markitdown.sh venv-clone`
- `bash scripts/install-markitdown.sh venv-local /path/to/markitdown`

Allowed but not preferred:
- `pypi`
- `clone`
- `local`

Use the non-venv modes only when the machine is already dedicated to this stack or the operator explicitly wants a shared install.

### Runtime resolution order

`normalize-document.sh` should resolve adapters in this order:
1. explicit `MARKITDOWN_BIN`
2. venv binary under `${MARKITDOWN_VENV_DIR:-/root/bid-stack/.venvs/markitdown}/bin/markitdown`
3. `markitdown` in `PATH`
4. `python3 -m markitdown`

This keeps project automation stable even when user shells differ.

### Operational rule

If a non-venv install was previously performed and package conflicts are suspected:
- do not blindly uninstall from the base environment
- switch the repo to venv mode first
- treat cleanup of global Python packages as a separate operator task

## 2. Adapter strategy

### Decision

Use one preferred adapter and a small fallback chain instead of per-format custom pipelines.

Preferred adapter:
- `markitdown`

Fallbacks:
- `pandoc` for DOCX compatibility and attachment extraction
- `pdftotext` for simple PDF text fallback

Non-goals:
- no internal OCR subsystem
- no heavy scan pipeline
- no custom bridge service

### Format coverage policy

Target V1 input formats:
- `docx`
- `pdf`
- `pptx`
- `xlsx`
- `xls`
- text-like files such as `txt`, `md`, `csv`, `tsv`, `json`, `xml`, `yaml`

### Test matrix

V1 should keep a small regression matrix:

1. `docx`
   - heading hierarchy
   - tables
   - inline images or attachments
   - fallback path with `pandoc`

2. `pdf`
   - text PDF through `markitdown`
   - fallback path with `pdftotext`
   - empty or weak extract warning

3. `pptx`
   - title slide
   - bullet slide
   - notes and image-heavy slides

4. `xlsx`
   - single-sheet table
   - multi-sheet workbook
   - mixed text and numeric cells

5. `xls`
   - legacy workbook through `markitdown`

### Recommended example assets

Keep sanitized fixtures under a dedicated examples tree in a later round, for example:

```text
examples/normalization-fixtures/
├── docx/
├── pdf/
├── pptx/
├── text/
├── xlsx/
└── xls/
```

The repo should not store sensitive real tender files.

## 3. Project-run data model

### Raw current-project input

Always stays under:

```text
bid-vault/inbox/projects/<project-id>/
```

### Normalized output

Always stays under:

```text
bid-vault/output/project-runs/<project-id>/normalized/
```

Each file gets one bundle:

```text
normalized/<category>/<relative-file-name>/
├── source.md
├── METADATA.md
├── summary.tsv
└── <original-file>
```

### Index

Machine index:
- `bid-vault/output/project-runs/<project-id>/normalized/normalization-index.tsv`

Purpose:
- one-row-per-file status view
- adapter used
- success/warning/failure visibility
- later input to parse-skeleton generation

### Manifest

Human-facing summary:
- `bid-vault/output/project-runs/<project-id>/00-NORMALIZATION-MANIFEST.md`

Purpose:
- manager review gate
- visible conversion risks before parsing

## 4. Parse-skeleton generation design

### Problem

After normalization, the manager still has to manually bootstrap `02-TENDER-PARSE.md`.
That is serviceable, but slower than necessary.

### Decision

Add one lightweight helper:
- `scripts/generate-parse-skeleton.sh <workspace-dir> <project-id>`

This is a project-run helper, not an agent replacement.

### Inputs

- `00-NORMALIZATION-MANIFEST.md`
- `normalized/normalization-index.tsv`
- normalized markdown bundles under `normalized/`

### Outputs

At minimum:
- prefilled `02-TENDER-PARSE.generated.md`
- machine-readable sidecar `parse-input-index.tsv`

### What it should do

1. read normalization index
2. group files by category:
   - tender
   - addenda
   - company-inputs
   - vendor-inputs
   - project-attachments
   - notes
3. list successful, warning, and failed conversions
4. prefill the parse page with:
   - source file inventory
   - addenda inventory
   - files that need manual review
   - known weak extracts
5. preserve empty sections for the manager or agent to complete:
   - qualification requirements
   - rejection rules
   - scoring points
   - packaging rules
   - pending clarifications

### What it should not do

- it should not guess qualification facts
- it should not infer bidder/vendor ownership
- it should not mark tender obligations as satisfied
- it should not promote anything into long-term knowledge

### Suggested implementation shape

Keep it shell-first.
If text assembly becomes awkward, use a tiny Python helper only for TSV parsing and markdown rendering.

Do not introduce a web service or queue.

## 5. Current implementation

Implemented:
1. venv-first `markitdown` installation
2. normalized project-run bundles and `normalization-index.tsv`
3. sanitized fixtures for `docx/pdf/pptx/xlsx/xls/txt`
4. `scripts/check-normalization-fixtures.sh`
5. `scripts/generate-parse-skeleton.sh`

Next follow-ups:
1. add warnings for large binary files or weak extracts
2. optionally enrich the machine index with more structured parse hints
3. optionally tighten OVP-side promotion workflows after the bidding flow is stable

## 6. Red lines

- normalized tender markdown is still current-project data
- no automatic knowledge promotion from normalization output
- no OCR subsystem inside this repository
- no global Python dependency changes as the default install path
- no heavy ingestion platform before the V1 bid workflow is stable
