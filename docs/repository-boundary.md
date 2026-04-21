# Repository Boundary

## What belongs in this public repo

Keep:

- product-facing skill definitions
- architecture and workflow docs
- templates
- deterministic helper scripts
- sanitized demo descriptions

## Two-repo stack policy

Recommended published structure:

- `Bidding-agent` stays focused on workflow, docs, templates, and startup helpers
- `obsidian_vault_pipeline` stays in its own fork/repository as the knowledge-layer dependency

Do not vendor OVP into this repo by default.

## What stays local by default

Exclude from version control:

- `workspaces/*/inbox/`
- raw tender source documents
- converted media attachments
- generated `.docx` exports
- zipped delivery packages
- certificate images
- heavy experimental vaults
- third-party reference trees copied locally for research

Recommended local parent layout:

- `/root/bid-stack/Bidding-agent`
- `/root/bid-stack/obsidian_vault_pipeline`
- `/root/bid-stack/vault/`
- `/root/bid-stack/workspaces/`

## Naming standard

Final naming used in this repository:

- product repo: `Bidding-agent`
- main skill: `bid-manager`
- external persona: `投标经理 Agent`

Legacy names remain historical design inputs only.
