# Workspace Template

This directory documents the recommended flat project workspace layout.

Primary entry:

```bash
bash scripts/start-bid-manager.sh /path/to/workspaces/my-project --dry-run
```

The wrapper auto-creates the standard workspace and shared vault if they are missing.

Recommended structure:

```text
/path/to/workspaces/my-project/
├── inbox/
├── output/
└── logs/
```

Current project files go into `inbox/`.
Project-run artifacts stay in `output/`.

Manual helpers remain available for advanced or compatibility use:

```bash
bash scripts/normalize-project-inputs.sh /path/to/workspaces/my-project
bash scripts/generate-parse-skeleton.sh /path/to/workspaces/my-project
bash scripts/validate-project-run.sh /path/to/workspaces/my-project
```
