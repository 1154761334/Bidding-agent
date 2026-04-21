# Normalization Design

This document defines the V1 normalization layer used by the bidding workflow.

The goal is not to build a general ingestion platform.
The goal is to create one controlled layer between raw current-project files and `bid-manager` parsing.

## Scope

This layer is responsible for:

- converting current-project files into Markdown-first working copies
- keeping per-file normalization metadata
- recording conversion failures and weak extracts
- providing a stable input surface for `bid-manager`

This layer is not responsible for:

- deciding what becomes long-term reusable knowledge
- classifying bidder/vendor ownership
- writing bid chapters
- replacing OVP or Hermes

## Environment policy

Preferred install mode:

- isolated virtual environment under `/root/bid-stack/.venvs/markitdown`

Preferred commands:

- `bash scripts/install-markitdown.sh venv`
- `bash scripts/install-markitdown.sh venv-clone`
- `bash scripts/install-markitdown.sh venv-local /path/to/markitdown`

Use non-venv modes only if the machine is dedicated to this stack.

## Adapter strategy

Preferred adapter:

- `markitdown`

Fallbacks:

- `pandoc` for DOCX compatibility and attachment extraction
- `pdftotext` for simple PDF fallback

V1 target formats:

- `docx`
- `pdf`
- `pptx`
- `xlsx`
- `xls`
- text-like files such as `txt`, `md`, `csv`, `tsv`, `json`, `xml`, `yaml`

## Data model

Raw current-project input always stays under:

```text
workspaces/<project-id>/inbox/
```

Normalized output always stays under:

```text
workspaces/<project-id>/output/normalized/
```

Each file gets one bundle:

```text
normalized/<category>/<relative-file-name>/
├── source.md
├── METADATA.md
├── summary.tsv
└── <original-file>
```

Machine index:

- `workspaces/<project-id>/output/normalized/normalization-index.tsv`

Human-facing manifest:

- `workspaces/<project-id>/output/00-NORMALIZATION-MANIFEST.md`

## Parse-skeleton generation

The parse-skeleton helper is a deterministic project-run helper, not an agent replacement.

Command:

- `scripts/generate-parse-skeleton.sh <workspace-dir>`

Inputs:

- `output/00-NORMALIZATION-MANIFEST.md`
- `output/normalized/normalization-index.tsv`
- normalized markdown bundles under `output/normalized/`

Outputs:

- `output/02-TENDER-PARSE.generated.md`
- `output/parse-input-index.tsv`

What it should do:

1. read the normalization index
2. group files by category
3. list successful, warning, and failed conversions
4. prefill the parse page with source inventory and review-needed items
5. leave placeholder sections for the manager to complete

What it must not do:

- guess qualification facts
- infer bidder/vendor ownership
- mark obligations as satisfied
- promote anything into long-term knowledge

## Current implementation

Implemented:

1. venv-first `markitdown` installation
2. normalized bundles plus `normalization-index.tsv`
3. sanitized fixtures
4. `scripts/check-normalization-fixtures.sh`
5. `scripts/generate-parse-skeleton.sh`

Follow-up direction:

- improve weak-extract warnings
- keep the normalization layer deterministic and lightweight
