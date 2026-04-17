# Workflow

## Default workflow

```text
materials intake
→ project-start questions
→ workspace validation
→ tender/package parse
→ evidence organization
→ score-point / chapter / evidence mapping
→ outline generation
→ user confirmation
→ drafting
→ review
→ formalization
→ export + backflow
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
- source tender materials
- company credentials
- vendor materials

If missing, initialize the standard structure.
If materials are partial, continue only after explicitly marking what is missing.

### 3. Tender/package parse
Extract at minimum:
- qualification requirements
- compliance and rejection rules
- scoring points
- document structure requirements
- packaging/sealing/signature rules
- whether the tender is single-pack or multi-pack

Gate:
- if multi-pack and target pack is not confirmed, stop here and ask the user.

### 4. Evidence organization
Create or update:
- evidence pages
- missing-material checklist
- ownership tags: bidder vs vendor

Gate:
- unsupported capability claims cannot move to formal output.
- evidence ownership must be explicit.

Recommended artifact:
- `templates/evidence-page-template.md`

### 5. Score-point / chapter / evidence mapping
Before major drafting, build the mapping layer.
For each score point or key requirement, identify:
- target chapter
- required evidence
- evidence ownership
- current status

Gate:
- if major mapping rows are still unknown, say so explicitly and avoid presenting the draft as complete.

Recommended artifact:
- `templates/score-chapter-evidence-mapping.md`

### 6. Outline generation
Create placeholders under project output.
Each chapter placeholder should contain:
- chapter title
- relevant clause summary
- status
- missing material list

### 7. User confirmation
Manager presents the outline and asks for confirmation.

Gate:
- no full drafting before user confirms outline.

### 8. Drafting
Use either:
- manager direct drafting for small/simple jobs
- internal sub-agent orchestration for larger jobs

Recommended trigger for sub-agents:
- 8+ chapters
- business + technical volumes in parallel
- heavy vendor material load
- separate review needed

For each drafted chapter, report:
- clauses addressed
- evidence used
- missing evidence/materials
- whether it is still internal draft only

### 9. Review
Review checks:
- clause coverage
- score-point coverage
- evidence placement
- bidder/vendor boundary
- over-commitment risks
- formal-delivery contamination by internal notes

Recommended artifact:
- `templates/review-checklist.md`

### 10. Formalization
Convert internal working draft into formal delivery draft:
- remove internal process language
- keep only formal conclusion-style content
- ensure evidence-backed claims
- place evidence near the corresponding claims where appropriate
- mark unfinished page numbers as `[to be filled]`

### 11. Backflow
Promote reusable outputs into `wiki/`:
- chapter templates
- evidence patterns
- mapping patterns
- review checklists

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
