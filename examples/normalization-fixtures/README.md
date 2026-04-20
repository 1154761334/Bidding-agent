# Normalization Fixtures

This directory contains sanitized regression fixtures for the normalization layer.

Purpose:
- verify that `normalize-document.sh` works across the supported file types
- keep a stable, repo-local smoke suite for `markitdown` and fallback adapters

Rules:
- do not store real tender files here
- keep fixtures minimal and sanitized
- prefer one fixture per format unless a second fixture is required for a fallback path

Current coverage:
- `docx`
- `pdf`
- `pptx`
- `xlsx`
- `xls`
- `text`

Each fixture directory contains:
- one input file
- `fixture.assert.tsv` with the minimum assertions used by `scripts/check-normalization-fixtures.sh`
