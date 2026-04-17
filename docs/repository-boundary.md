# Repository boundary

## What belongs in this public repo

Keep:
- product-facing skill definitions
- architecture and workflow docs
- workspace templates
- helper scripts
- sanitized demo descriptions

## What stays local by default

Exclude from version control:
- raw bid source documents
- converted media attachments
- generated `.docx` exports
- zipped delivery packages
- certificate images
- heavy experimental vaults
- third-party reference trees copied locally for research

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
