# Workflow

## Default workflow

```text
project folder intake
→ project-start questions
→ workspace validation
→ current project document normalization
→ parse skeleton generation
→ current tender/package parse
→ reusable-knowledge retrieval
→ evidence organization
→ score-point / chapter / evidence mapping
→ outline generation
→ user confirmation
→ drafting
→ compliance review
→ formatting
→ QA audit
→ release + backflow
```

## Stage details

### 1. Project-start intake
Manager asks the minimum critical questions first:
1. who is the bidding entity?
2. what is the role in this project? (prime / integrator / consortium / single vendor)
3. which vendor solutions, certificates, and evidence must be included?
4. what cannot be over-promised?

Recommended artifact:
- `templates/project-start-sheet.md`

### 2. Workspace validation
Check for:
- `bid-vault/`
- current project input folder under `bid-vault/inbox/projects/`
- company credentials
- vendor materials
- reusable knowledge folders under `raw/`

If missing, initialize the standard structure.
If materials are partial, continue only after explicitly marking what is missing.

### 3. Current project document normalization
Normalize current-project inputs into Markdown-first working bundles before heavy parsing.

Preferred location:
- `bid-vault/output/project-runs/<project-id>/normalized/`

Preferred adapter:
- `markitdown`

Fallback adapters:
- `pandoc` for DOCX compatibility and media extraction
- `pdftotext` for simple PDF fallback

Rules:
- raw source files remain in `bid-vault/inbox/projects/<project-id>/`
- normalization output is still project-run data, not long-term knowledge
- failed or weak conversions must be recorded before parsing continues

Recommended artifact:
- `templates/normalization-manifest.md`

See design:
- `docs/normalization-design.md`

### 4. Parse skeleton generation
Generate a first-pass tender parse skeleton from normalized inputs before deeper analysis.

Inputs:
- `bid-vault/output/project-runs/<project-id>/00-NORMALIZATION-MANIFEST.md`
- `bid-vault/output/project-runs/<project-id>/normalized/normalization-index.tsv`
- normalized markdown bundles

Outputs:
- `bid-vault/output/project-runs/<project-id>/02-TENDER-PARSE.generated.md`
- `bid-vault/output/project-runs/<project-id>/parse-input-index.tsv`

Rules:
- do not overwrite an existing human-maintained `02-TENDER-PARSE.md`
- generated content is an inventory and placeholder scaffold, not a factual parse

### 5. Current tender/package parse
Extract at minimum:
- qualification requirements
- compliance and rejection rules
- scoring points
- document structure requirements
- packaging/sealing/signature rules
- whether the tender is single-pack or multi-pack

Gate:
- if multi-pack and target pack is not confirmed, stop here and ask the user

Important boundary:
- parse the tender from the current project input folder
- parse addenda, clarifications, and project-only attachments from the same current-project input area
- do not treat the tender file itself as a long-term wiki fact unless explicitly promoted later

### 6. Reusable-knowledge retrieval
Before evidence mapping, fetch reusable materials from the knowledge layer:
- historical bids
- company credentials
- vendor/original-manufacturer materials
- prior reusable chapter or evidence patterns

The manager should explicitly separate:
- bidder-owned material
- vendor-owned material
- missing material

### 7. Evidence organization
Prefer `evidence-agent` for medium or large projects.

Create or update:
- evidence pages
- missing-material checklist
- ownership tags: bidder vs vendor

Gate:
- unsupported capability claims cannot move to formal output
- evidence ownership must be explicit

Recommended artifact:
- `templates/evidence-page-template.md`
- `templates/evidence-gap-report.md`

### 8. Score-point / chapter / evidence mapping
Before major drafting, build the mapping layer.
For each score point or key requirement, identify:
- target chapter
- required evidence
- evidence ownership
- current status

Gate:
- if major mapping rows are still unknown, say so explicitly and avoid presenting the draft as complete

Recommended artifact:
- `templates/score-chapter-evidence-mapping.md`

### 9. Outline generation
Create placeholders under `bid-vault/output/project-runs/<project-id>/`.
Each chapter placeholder should contain:
- chapter title
- relevant clause summary
- status
- missing material list
- expected drafting owner

Recommended artifact:
- `templates/outline-template.md`

### 10. User confirmation
Manager presents the outline and asks for confirmation.

Gate:
- no full drafting before user confirms outline

### V1 default stopping point
For the minimum runnable V1, the manager should normally stop after:
1. normalization manifest
2. parse skeleton
3. project-start sheet
4. tender parse page
5. evidence gap list
6. score-point / chapter / evidence mapping
7. outline placeholders

If evidence is missing, the manager reports the gap instead of pretending the draft is ready.

### 11. Drafting
Prefer `drafting-agent` for substantive writing.
If volume is high, the manager may split drafting into multiple workers, but those workers still belong to the drafting lane rather than replacing the manager role.

Recommended triggers for separated drafting:
- 8+ meaningful chapters
- business and technical sections moving in parallel
- heavy vendor material load
- multiple deliverable volumes

For each drafted chapter, report:
- clauses addressed
- evidence used
- missing evidence/materials
- whether it is still internal draft only

### 12. Compliance review
Use `compliance-agent` to verify:
- clause coverage
- score-point coverage
- required evidence linkage
- bidder/vendor boundary correctness
- over-commitment risks
- rejection-risk items

Gate:
- major blockers must be visible before the draft can move into formatting

### 13. Formatting
Use `formatting-agent` to convert internal working output into formal-delivery style:
- remove internal process language
- normalize chapter headers and placeholders
- keep only formal conclusion-style content
- mark unfinished page numbers as `[to be filled]`

Gate:
- formatting does not close unresolved compliance issues

### 14. QA audit
Use `qa-audit-agent` for an independent pass over:
- cross-section consistency
- unsupported claims
- drift between outline, mapping, and final text
- release readiness

Gate:
- the same role should not both draft and final-approve the same artifact on medium or large projects

### 15. Backflow
Promote reusable outputs into `wiki/`:
- chapter templates
- evidence patterns
- mapping patterns
- review checklists
- QA/audit patterns

Do not promote the raw tender text into the reusable layer by default.

## Output philosophy

The system should create two clearly separated worlds:
- internal working artifacts
- formal delivery artifacts

Formal delivery must never contain:
- reasoning notes
- risk prompts
- internal source remarks
- to-do flags
- draft-only reminders
- fake page numbers for unfinished sections
