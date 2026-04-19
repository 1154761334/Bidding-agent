# Architecture

## Product goal

Deliver a Hermes-native bidding system that feels like one professional bid manager while internally coordinating specialized execution roles over an OVP-backed knowledge layer.

## Packaging model

The recommended deployment unit is one stack with two repositories:
- `Bidding-agent` for workflow, templates, startup helpers, and the `bid-manager` skill
- `obsidian_vault_pipeline` for the vault knowledge engine

This is intentionally a stack package, not a codebase merge.
Users experience one product, but the repos stay separable for maintenance.

## External shape

User sees only:
- one skill: `bid-manager`
- one identity: 投标经理 Agent
- one workflow owner: the bid manager

The user should not decide which internal role to invoke.

## Internal collaboration model

### 1. `bid-manager`
Responsibilities:
- project intake and startup sheet
- package/lot confirmation
- clause/scoring gate control
- agent dispatch decisions
- merge and release decisions
- final communication with the user

Must not:
- default to writing every chapter itself on complex projects
- act as the only reviewer for its own major draft output on medium or large jobs
- release formal output before internal gates are satisfied

### 2. `evidence-agent`
Responsibilities:
- organize bidder credentials
- organize vendor/original-manufacturer materials
- create evidence pages and missing-material lists
- classify ownership: bidder vs vendor

Must not:
- write major chapters as its main job
- claim vendor capability as bidder-owned capability

### 3. `drafting-agent`
Responsibilities:
- draft business and technical chapters from approved outline + mapping + evidence
- expand solution, implementation, migration, service, and operation sections
- distinguish vendor capability, bidder delivery capability, and collaborative sections

Must not:
- change outline structure without manager approval
- over-commit beyond approved risk boundaries
- self-approve formal release

### 4. `compliance-agent`
Responsibilities:
- cross-check tender clauses, scoring points, and chapter coverage
- verify evidence linkage and mandatory response completeness
- flag overstatements, omissions, and bid-rejection risks

Must not:
- silently rewrite project strategy
- downgrade critical blockers into minor notes

### 5. `formatting-agent`
Responsibilities:
- convert internal working drafts into formal-delivery style
- remove process notes and draft contamination
- normalize placeholders, packaging notes, and chapter hygiene

Must not:
- invent missing content to make formatting look complete
- bypass unresolved compliance blockers

### 6. `qa-audit-agent`
Responsibilities:
- perform independent consistency, defensibility, and quality audit
- check cross-volume contradictions and unsupported claims
- verify that the right role separation was maintained

Must not:
- become the primary drafter
- waive material evidence or compliance defects on its own

## Separation policy

This architecture assumes that, on medium or large projects:
- writing and checking are separate responsibilities
- formatting is separate from substantive review
- QA/audit is independent from the main drafting lane
- manager owns gates and decisions, not raw chapter volume

Small projects may collapse some roles, but the manager must still state when separation was reduced and what risk remains.

## Knowledge model

The system assumes an Obsidian-style vault:

```text
bid-vault/
├── inbox/
├── raw/
├── wiki/
├── output/
└── logs/
```

Meaning:
- `inbox/` = current project input folders and project-only supplements
- `raw/` = reusable source material bundles
- `wiki/` = promoted reusable knowledge pages
- `output/` = project-run execution artifacts
- `logs/` = review, lint, and audit traces

Boundary:
- current tender packages are project-run inputs
- reusable bidder/vendor knowledge belongs in `raw/` and promoted `wiki/` pages
- the tender package itself is not the default canonical long-term knowledge object

## Core product objects

Minimum durable objects:
- project input manifest
- project-start sheet
- package parse page
- score-point / chapter / evidence mapping page
- evidence pages
- outline placeholders
- chapter drafts
- compliance review report
- formatting checklist
- QA/audit report
- formal-delivery package checklist

## Manager state machine

1. project folder intake
2. startup intake
3. workspace validation
4. current tender parse
5. reusable-knowledge retrieval
6. evidence organization
7. score-point / chapter / evidence mapping
8. outline generation and confirmation
9. drafting
10. compliance review
11. formatting
12. QA/audit
13. release and backflow

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

## Why this is not just a writing workflow

This system is designed for real tender production, not only language generation.
It must manage:
- current project input vs long-term knowledge boundaries
- evidence assembly
- evaluation alignment
- rejection-risk control
- separation of authoring and review
- knowledge reuse across projects
