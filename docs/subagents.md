# Sub-agents

This repository uses internal role decomposition without exposing multiple user-facing products.

## Policy

User-facing behavior:
- one manager entrypoint
- one conversation owner: `bid-manager`

Internal execution:
- specialized roles with clear ownership
- explicit separation between drafting, checking, formatting, and QA when complexity justifies it

## Why this split exists

For real bid work, asking one role to write, self-check, formalize, and approve everything is fragile.
The architecture therefore assumes:
- manager controls process and gates
- evidence is organized separately
- substantive drafting is separate from compliance checking
- formatting is separate from substantive review
- QA/audit is an independent last pass

## Recommended role set

### `evidence-agent`
Inputs:
- company credentials
- vendor materials
- historical evidence bundles

Outputs:
- evidence pages
- missing-material checklist
- bidder/vendor ownership labels

### `drafting-agent`
Inputs:
- approved outline
- package parse page
- evidence pages
- role boundary instructions

Outputs:
- chapter drafts
- unresolved drafting questions
- evidence dependency notes

Notes:
- for large projects, the manager may split this lane into multiple drafting workers
- these workers are still drafting roles, not independent approval roles

### `compliance-agent`
Inputs:
- latest working draft
- clause mapping
- evidence mapping
- risk boundaries

Outputs:
- compliance findings
- clause/score coverage report
- formatting blockers

### `formatting-agent`
Inputs:
- compliance-cleared working draft
- delivery structure requirements
- packaging/seal/submission notes

Outputs:
- formal-delivery styled draft
- formatting cleanup checklist
- unresolved packaging placeholders

### `qa-audit-agent`
Inputs:
- formatted draft
- compliance report
- mapping artifacts

Outputs:
- quality audit report
- contradiction/risk list
- release recommendation

## Trigger conditions

Use separated roles when one or more are true:
- outline is large
- technical and business streams run in parallel
- evidence workload is significant
- independent checking is required
- formatting rules are strict
- quality risk is high enough that self-review is not acceptable

## Separation rules

- `bid-manager` owns orchestration, not the bulk of chapter production on complex jobs
- `drafting-agent` does not final-approve its own major output
- `compliance-agent` surfaces blockers before formatting
- `formatting-agent` does not invent missing content
- `qa-audit-agent` remains independent from the main drafting lane

## Non-goal

Do not split the system into dozens of tiny chapter agents by default.
The right pattern is a small set of stable role lanes coordinated by one manager, not uncontrolled agent sprawl.
