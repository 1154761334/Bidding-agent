# Architecture

## Product goal

Deliver a Hermes-native bidding system that feels like one professional bid manager, while internally coordinating specialized execution roles.

## External shape

User sees only:
- one skill: `bid-manager`
- one identity: 投标经理 Agent

The user should not have to decide which internal role to invoke.

## Internal roles

### 1. Manager agent
Responsibilities:
- project intake
- role identification
- package/lot confirmation
- clause and scoring gate control
- evidence and outline gate control
- sub-agent dispatch decisions
- final review and release decision

Must not:
- default to writing all chapters itself on complex projects
- allow formal delivery before gates are satisfied

### 2. Evidence agent
Responsibilities:
- organize bidder credentials
- organize vendor/original-manufacturer materials
- structure evidence pages
- classify evidence ownership
- produce missing-evidence checklist

Must not:
- write major technical solution chapters
- claim vendor capability as bidder-owned capability

### 3. Technical agent
Responsibilities:
- demand response
- solution chapters
- deployment, implementation, migration, service, and operation chapters
- use three writing modes:
  - vendor-led capability sections
  - integrator-led implementation sections
  - collaborative sections

Must not:
- alter the approved outline on its own
- over-commit beyond approved risk boundaries

### 4. Review agent
Responsibilities:
- clause coverage review
- score-point coverage review
- evidence linkage review
- bidder-vs-vendor boundary review
- over-commitment review
- formal-delivery hygiene review

Must not:
- replace manager decisions on project strategy

## Knowledge model

The system assumes an Obsidian-style vault:

```text
bid-vault/
├── raw/
├── wiki/
├── output/
└── logs/
```

Meaning:
- `raw/` = immutable source material bundles
- `wiki/` = compiled knowledge pages and reusable objects
- `output/` = project-specific execution artifacts
- `logs/` = lint, review, and operational traces

## Core product objects

Minimum durable objects:
- project-start sheet
- pack/package parse page
- score-point / chapter / evidence mapping page
- evidence page
- chapter placeholders
- chapter drafts
- review report
- formal-delivery package checklist

## Manager state machine

1. startup intake
2. workspace validation
3. tender parse
4. evidence organization
5. outline generation
6. user confirmation gate
7. drafting
8. independent review
9. formalization
10. export/backflow

## Gate rules

The following gates are non-optional:
- no multi-pack continuation before target pack confirmation
- no drafting before outline confirmation
- no formal qualification statement without evidence
- no fake page numbers for unfinished sections
- no internal process notes in formal delivery
- no mixing bidder capability and vendor capability

## Why this is not just a writing workflow

This system is designed for real tender production, not only language generation.
It must manage:
- evidence assembly
- evaluation alignment
- rejection-risk control
- role boundary control
- knowledge reuse across projects
