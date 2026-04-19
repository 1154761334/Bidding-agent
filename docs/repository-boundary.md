# Repository boundary

## What belongs in this public repo

Keep:
- product-facing skill definitions
- architecture and workflow docs
- workspace templates
- helper scripts
- sanitized demo descriptions

## Two-repo stack policy

Recommended published structure:
- `Bidding-agent` stays focused on workflow, docs, templates, and startup helpers
- `obsidian_vault_pipeline` stays in its own fork/repository as the knowledge-layer dependency

Do not vendor OVP into this repo by default.
Package the system as one local stack root instead of one merged repository.

## What stays local by default

Exclude from version control:
- `bid-vault/inbox/projects/` project input folders
- raw bid source documents
- converted media attachments
- generated `.docx` exports
- zipped delivery packages
- certificate images
- heavy experimental vaults
- third-party reference trees copied locally for research

Recommended local parent layout outside the repo:
- `/root/bid-stack/Bidding-agent`
- `/root/bid-stack/obsidian_vault_pipeline`
- `/root/bid-stack/workspaces/`

## Current prototype-origin note

This repository was consolidated from an earlier local prototype workspace that contained:
- bid-vault experiments
- OVP integration tests
- converted docx bundles
- local review outputs
- design notes

Those materials remain useful locally, but are not the right default payload for a public product repository.

## Naming standard

Final naming used in this repository:
- product repo: `Bidding-agent`
- main skill: `bid-manager`
- external persona: `投标经理 Agent`

Legacy names treated as historical design inputs:
- `bid-writing-agent`
- `bid-orchestrator`
- `投标文件撰写`
- `bid-standard-generator`
