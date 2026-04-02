# Installing Engineering Discipline for Codex

Enable engineering discipline skills in Codex via the skills CLI.

## Installation

### Quick Install (Recommended)

```bash
npx skills add tmdgusya/engineering-discipline
```

This installs to your current project (project-level). Skills are placed in `.agents/skills/` and symlinked to `.codex/skills/`.

### Global Install

To make skills available across all projects:

```bash
npx skills add tmdgusya/engineering-discipline -g
```

### Verify Installation

```bash
npx skills list
```

You should see `engineering-discipline` in the list.

## Updating

```bash
npx skills update
```

Or check for updates first:

```bash
npx skills check
```

## Uninstalling

```bash
npx skills remove engineering-discipline
```

## How It Works

The skills CLI:
1. Clones the repository to `.agents/skills/engineering-discipline`
2. Creates symlinks from `.codex/skills/engineering-discipline` to the canonical copy
3. Codex automatically discovers skills from `.codex/skills/`

Since skills are symlinked, updating the canonical copy instantly updates all linked agents.

## Alternative: Manual Install

If you prefer not to use the skills CLI:

```bash
git clone https://github.com/tmdgusya/engineering-discipline.git ~/.agents/skills/engineering-discipline
mkdir -p ~/.codex/skills
ln -s ~/.agents/skills/engineering-discipline/skills ~/.codex/skills/engineering-discipline
```

Then restart Codex to discover the skills.
