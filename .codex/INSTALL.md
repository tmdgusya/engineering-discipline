# Installing Engineering Discipline for Codex

Enable engineering discipline skills in Codex via native skill discovery.

## Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/tmdgusya/engineering-disciplines.git ~/.codex/engineering-disciplines
   ```

2. **Create the skills symlink:**
   ```bash
   mkdir -p ~/.agents/skills
   ln -s ~/.codex/engineering-disciplines/skills ~/.agents/skills/engineering-disciplines
   ```

3. **Restart Codex** to discover the skills.

## Verify

```bash
ls -la ~/.agents/skills/engineering-disciplines
```

You should see a symlink pointing to the skills directory.

## Updating

```bash
cd ~/.codex/engineering-disciplines && git pull
```

Skills update instantly through the symlink.

## Uninstalling

```bash
rm ~/.agents/skills/engineering-disciplines
rm -rf ~/.codex/engineering-disciplines
```
