# Sub-agents

This repository uses internal role decomposition without exposing multiple user-facing products.

## Policy

User-facing behavior:
- one manager entrypoint

Internal execution:
- a small number of specialized roles

## Recommended role set

### evidence-agent
Inputs:
- company credentials
- vendor materials
- historical evidence bundles

Outputs:
- evidence pages
- missing-material checklist
- bidder/vendor evidence ownership labels

### technical-agent
Inputs:
- approved outline
- package parse page
- evidence pages
- role boundary instructions

Outputs:
- technical chapter drafts
- chapter-level unresolved questions
- chapter-level evidence dependency notes

### review-agent
Inputs:
- latest working draft
- clause mapping
- evidence mapping
- risk boundaries

Outputs:
- review report
- correction checklist
- formalization blockers

## Trigger conditions

Use sub-agents when one or more are true:
- outline is large
- technical and business streams run in parallel
- evidence workload is significant
- review must be separated from drafting

## Non-goal

Do not split the system into many tiny chapter agents by default.
That adds complexity and weakens the product feeling of a single professional bid manager.
