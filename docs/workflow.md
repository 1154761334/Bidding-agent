# Workflow

## Default workflow

```text
materials intake
→ project-start questions
→ tender/package parse
→ evidence organization
→ score-point mapping
→ outline generation
→ user confirmation
→ drafting
→ review
→ formalization
→ export + backflow
```

## Stage details

### 1. Project-start intake
Manager asks the minimum critical questions:
1. who is the bidding entity?
2. what is the role in this project? (prime / integrator / consortium / single vendor)
3. which vendor solutions, certificates, and evidence must be included?
4. what cannot be over-promised?

### 2. Workspace validation
Check for:
- `bid-vault/`
- source tender materials
- company credentials
- vendor materials

If missing, initialize the standard structure.

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

### 5. Outline generation
Create placeholders under project output.
Each chapter placeholder should contain:
- chapter title
- relevant clause summary
- status
- missing material list

### 6. User confirmation
Manager presents the outline and asks for confirmation.

Gate:
- no full drafting before user confirms outline.

### 7. Drafting
Use either:
- manager direct drafting for small/simple jobs
- internal sub-agent orchestration for larger jobs

Recommended trigger for sub-agents:
- 8+ chapters
- business + technical volumes in parallel
- heavy vendor material load
- separate review needed

### 8. Review
Review checks:
- clause coverage
- score-point coverage
- evidence placement
- bidder/vendor boundary
- over-commitment risks

### 9. Formalization
Convert internal working draft into formal delivery draft:
- remove internal process language
- keep only formal conclusion-style content
- ensure evidence-backed claims
- mark unfinished page numbers as `[to be filled]`

### 10. Backflow
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
