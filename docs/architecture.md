# Architecture

## Product goal

Deliver a Hermes-native bidding system that feels like one professional bid manager while internally coordinating specialized roles over an OVP-backed knowledge layer.

## Packaging model

The recommended deployment unit is one stack with two repositories:

- `Bidding-agent` for workflow, templates, startup helpers, and the `bid-manager` skill
- `obsidian_vault_pipeline` for the vault knowledge engine

This is a stack package, not a codebase merge.

## External shape

The user should see only:

- one skill: `bid-manager`
- one identity: 投标经理 Agent
- one recommended CLI entry: `scripts/start-bid-manager.sh`

Other scripts are deterministic helpers, not separate user-facing workflow products.

## Internal collaboration model

### `bid-manager`

Responsibilities:

- project intake and startup sheet
- workspace validation
- package/lot confirmation
- clause/scoring gate control
- internal role dispatch decisions
- merge and release decisions
- final communication with the user

Must not:

- default to writing every chapter itself on complex projects
- act as the only reviewer for its own major draft output on medium or large jobs
- release formal output before internal gates are satisfied

### `evidence-agent`

Responsibilities:

- organize bidder credentials
- organize vendor/original-manufacturer materials
- create evidence pages and missing-material lists
- classify ownership: bidder vs vendor

### `drafting-agent`

Responsibilities:

- draft chapters from approved outline, mapping, and evidence
- distinguish vendor capability, bidder delivery capability, and collaborative sections

### `compliance-agent`

Responsibilities:

- cross-check tender clauses, scoring points, and chapter coverage
- verify evidence linkage and mandatory response completeness
- flag overstatement and bid-rejection risks

### `formatting-agent`

Responsibilities:

- convert internal drafts into formal-delivery style
- remove process notes and draft contamination

### `qa-audit-agent`

Responsibilities:

- perform independent consistency and defensibility checks
- verify role separation and release readiness

## Runtime storage model

### Company Knowledge Vault

Location: `vault/`

Purpose:

- permanent company-wide knowledge
- credentials, cases, vendor docs, promoted reusable pages

### Project Workspace

Location: `workspaces/<id>/`

Purpose:

- temporary project-centric documents
- normalized current-project input
- parse, mapping, review, and draft artifacts

Structure:

- `vault/raw/` = reusable source bundles
- `vault/wiki/` = promoted reusable knowledge pages
- `workspace/inbox/` = current project input
- `workspace/output/` = current project run artifacts
- `workspace/logs/` = review, lint, and audit traces

Boundary:

- current tender packages stay in `workspace/inbox/`
- normalized bundles stay in `workspace/output/normalized/`
- the tender package is not promoted to the vault by default

## Core product objects

Minimum durable objects:

- project input manifest
- normalization manifest
- parse skeleton
- project-start sheet
- package parse page
- evidence gap report
- mapping page
- evidence pages
- outline placeholders
- chapter drafts
- compliance review report
- formatting checklist
- QA/audit report

## Manager state machine

1. workspace check
2. startup intake
3. normalization check
4. parse skeleton check
5. current tender parse
6. reusable-knowledge retrieval
7. evidence organization
8. mapping
9. outline generation and confirmation
10. drafting
11. compliance review
12. formatting
13. QA/audit
14. release and backflow

For V1, the default first milestone ends after:

- normalization manifest
- parse skeleton
- package parse
- evidence gap report
- mapping page
- outline placeholders

## Gate rules

The following gates are non-optional:

- no multi-pack continuation before target pack confirmation
- no substantial drafting before outline confirmation
- no formal qualification statement without evidence
- no same-role draft-and-final-approve pattern on medium or large jobs
- no formatting pass before major compliance blockers are visible
- no fake page numbers for unfinished sections
- no internal process notes in formal delivery
- no mixing bidder capability and vendor capability
- no treating the current tender package as default reusable knowledge
