# Workflow

## Default workflow

```text
start bid-manager
→ workspace check
→ startup intake
→ normalization check
→ parse skeleton check
→ tender/addenda parse
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

The formal entrypoint is still `bid-manager`.
CLI helpers may prepare files, but they are not the product workflow owner.

## Runtime boundary

Two data worlds must stay separate:

- current project input in `workspaces/<project-id>/inbox/`
- reusable long-term knowledge in `vault/raw/` and `vault/wiki/`

Normalized outputs, parse skeletons, mapping pages, and drafts all stay in `workspaces/<project-id>/output/`.

Within the reusable knowledge layer, also distinguish:

- current verified evidence that is explicitly confirmed for this bid
- historical/sample references that are useful for structure or response patterns only

## Stage details

### 1. Workspace check

At session start, the manager checks:

- `inbox/`
- `output/`
- `output/PROGRESS.json`
- shared `vault/`

If folders or template artifacts are missing, the standard skeleton should be created first.
If the workspace exists but materials are absent, the manager should stop after producing a precise missing-material list.

### 2. Startup intake

The manager asks the minimum critical questions:

1. who is the bidding entity?
2. what is the role in this project?
3. which vendor/original-manufacturer materials must be included?
4. what must not be over-promised?

Recommended artifact:
- `templates/project-start-sheet.md`

### 3. Current project document normalization

Normalize current-project inputs into Markdown-first working bundles before deeper parsing.

Preferred location:
- `workspaces/<project-id>/output/normalized/`

Preferred adapter:
- `markitdown`

Fallback adapters:
- `pandoc` for DOCX compatibility and media extraction
- `pdftotext` for simple PDF fallback

Rules:

- raw source files remain in `workspaces/<project-id>/inbox/`
- normalization output is still project-run data, not long-term knowledge
- failed or weak conversions must be recorded before parsing continues

### 4. Parse skeleton generation

Generate a first-pass tender parse skeleton from normalized inputs before deeper analysis.

Inputs:

- `output/00-NORMALIZATION-MANIFEST.md`
- `output/normalized/normalization-index.tsv`
- normalized markdown bundles

Outputs:

- `output/02-TENDER-PARSE.generated.md`
- `output/parse-input-index.tsv`

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

- if multi-pack and target pack is not confirmed, stop and ask the user

### 6. Reusable-knowledge retrieval

Before evidence mapping, fetch reusable materials from the vault:

- historical bids
- company credentials
- vendor/original-manufacturer materials
- prior reusable chapter or evidence patterns

The manager should explicitly separate:

- bidder-owned material
- vendor-owned material
- missing material
- sample/reference-only material

### 7. Evidence organization

Prefer `evidence-agent` for medium or large projects.

Create or update:

- evidence pages
- missing-material checklist
- ownership tags: bidder vs vendor

Gate:

- unsupported capability claims cannot move to formal output
- evidence ownership must be explicit

### 8. Score-point / chapter / evidence mapping

Before major drafting, build the mapping layer.
For each score point or key requirement, identify:

- target chapter
- required evidence
- evidence ownership
- current status

Gate:

- if major mapping rows are still unknown, say so explicitly and avoid presenting the draft as complete

### 9. Outline generation

Create placeholders under `workspaces/<project-id>/output/`.
Each chapter placeholder should contain:

- chapter title
- relevant clause summary
- status
- missing material list
- expected drafting owner

### 10. User confirmation

The manager presents the outline and asks for confirmation.
No full drafting before user confirmation.

### 11. Drafting

Prefer `drafting-agent` for substantive writing.
If volume is high, the manager may split drafting into multiple workers within the drafting lane.

Drafting rule:

- do not turn a sample bid's concrete brand choice, staffing detail, performance target, or certificate validity into a current-project fact unless current evidence confirms it

### 12. Compliance review

Use `compliance-agent` to verify:

- clause coverage
- score-point coverage
- required evidence linkage
- bidder/vendor boundary correctness
- over-commitment risks
- rejection-risk items

### 13. Formatting

Use `formatting-agent` to convert internal working output into formal-delivery style.

### 14. QA audit

Use `qa-audit-agent` for an independent pass over:

- cross-section consistency
- unsupported claims
- drift between outline, mapping, and final text
- release readiness

## V1 stopping point

For the minimum runnable V1, the manager should normally stop after:

1. normalization manifest review
2. parse skeleton review
3. project-start sheet
4. tender parse page
5. evidence gap list
6. score-point / chapter / evidence mapping
7. outline placeholders

If evidence is missing, the manager reports the gap instead of pretending the draft is ready.
