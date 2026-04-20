# Workspace template

This directory provides the recommended starter layout for a Hermes-based bidding workspace.

Use:

```bash
bash scripts/init-workspace.sh /path/to/project
```

For a current bid run, create a project input folder with:

```bash
bash scripts/new-project-inbox.sh /path/to/project my-project-id
```

Then initialize the working artifact skeleton with:

```bash
bash scripts/init-project-run.sh /path/to/project my-project-id
```

Then normalize the current project files into the project-run workspace with:

```bash
bash scripts/normalize-project-inputs.sh /path/to/project my-project-id
```

Then prefill the tender parse scaffold with:

```bash
bash scripts/generate-parse-skeleton.sh /path/to/project my-project-id
```

Or copy the `bid-vault/` structure manually.
