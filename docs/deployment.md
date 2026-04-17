# Deployment

## Runtime prerequisites

- Hermes installed
- GitHub / local filesystem access as needed
- file + terminal tools enabled
- optional vision tool for certificate/image evidence handling

## Main usage model

Run Hermes with the main skill:

```bash
hermes -s bid-manager
```

Or for a single-shot task:

```bash
hermes chat -s bid-manager -q "请作为投标经理读取当前工作区并启动投标流程"
```

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
- add a small config template for local profiles
- add lint/review helper scripts for the vault layer
