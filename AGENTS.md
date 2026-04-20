# AGENTS.md

## Repo mission

This repository is the lightweight integration layer for a runnable V1 "智能投标/标书起草助手".
It must organize OVP and Hermes into one bid-production workflow without rewriting either system.

## Fixed layering

1. OVP / Obsidian layer
   - Self-managed knowledge layer for long-term assets
   - Handles organization, indexing, promotion, and derivation of reusable knowledge
   - Do not fork or vendor OVP into this repository by default

2. Hermes layer
   - Conversational agent and multi-agent orchestration runtime
   - `bid-manager` is the only formal drafting entrypoint
   - Internal roles may include evidence, drafting, compliance, formatting, and QA

3. This repository
   - Workflow glue for bidding use cases
   - Owns skills, templates, directory conventions, helper scripts, and docs
   - Prefer small scripts and conventions over heavy services

## Working style

- Read the repository first, then plan, then implement.
- Prefer the smallest runnable V1 over broad platform design.
- Do not ask the user to re-confirm routine decisions unless there is a real blocker.
- Keep docs, scripts, and examples aligned with the actual implementation.
- After each meaningful round, report:
  - files/directories inspected
  - current architecture understanding
  - round goal
  - code/docs/scripts changed
  - verification commands and outcomes
  - remaining issues and next-step recommendation

## Knowledge boundary

Two classes of data must stay separate.

### A. Long-term knowledge assets

Store in the vault knowledge layer:
- historical bids
- company credentials and licenses
- cases and delivery proof
- solution capability materials
- vendor/original-manufacturer materials
- reusable methodologies, templates, and evidence pages

### B. Current project input

Treat as project-run input by default:
- current tender package
- addenda and clarifications
- project-specific attachments
- temporary analysis produced for the current project

Rules:
- Tender files are not default long-term knowledge objects.
- Hermes must read both the current project input and long-term knowledge assets.
- Project-end archiving is allowed, but raw tender files must not automatically become reusable truth pages.

## P0 priorities

Deliver the following first:
- `bid-manager` skill behavior
- workspace initialization
- project-input scaffolding
- project-run output scaffolding
- knowledge-boundary conventions
- helper scripts for DOCX/PDF/OCR light handling
- runnable docs and examples
- minimal verification chain

Avoid:
- rewriting OVP core
- heavy backend services
- over-platforming
- fully unattended automation

## Quality red lines

Never:
- treat the current tender as default knowledge-base truth
- fabricate claims when evidence is missing
- blur bidder capability and vendor capability
- use Hermes memory as the knowledge base
- expose multiple user-facing drafting entrypoints
- leave docs stale after changing behavior

Always:
- keep evidence first
- keep project input and long-term knowledge separate
- keep `bid-manager` as the single formal entrypoint
- use internal multi-agent roles only to serve the bidding workflow
- stop at the minimum useful milestone before expanding scope

## Local layout

Default stack layout:

```text
/root/bid-stack/
├── Bidding-agent/
├── obsidian_vault_pipeline/
└── workspaces/
```

Constraints:
- `Bidding-agent` and `obsidian_vault_pipeline` stay as sibling checkouts
- no git submodules
- no vendored OVP source inside this repository

## Verification baseline

When editing runnable assets, verify at minimum:
- `bash -n scripts/*.sh`
- workspace bootstrap smoke test
- project-input and project-run scaffolding smoke test
- helper script smoke tests where local tools are available
