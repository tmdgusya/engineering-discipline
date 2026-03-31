# Engineering Discipline

Engineering discipline skills for AI coding agents. Works with Claude Code, Gemini CLI, OpenCode, Codex, and Cursor.

## Skills

### Rob Pike's 5 Rules

A decision framework that prevents premature optimization and enforces measurement-driven development.

**Triggers on:** "optimize", "slow", "performance", "bottleneck", "speed up", "make faster", "too slow"

**Core principle:** Don't guess where time is spent. Measure. Then measure again. Fancy algorithms are slow when n is small, and n is usually small.

### Systematic Debugging

Strict debugging workflow that enforces reproduce-first, root-cause-first, failing-test-first debugging.

**Triggers on:** Any bug, test failure, or unexpected behavior.

**Core principle:** Never fix without reproduction. Never fix without a root cause hypothesis. Never fix without a failing guard.

Includes reference guides:
- [Condition-based waiting](skills/systematic-debugging/condition-based-waiting.md) — Replace flaky timeouts with reliable condition polling
- [Defense-in-depth validation](skills/systematic-debugging/defense-in-depth.md) — Validate at every layer data passes through
- [Root cause tracing](skills/systematic-debugging/root-cause-tracing.md) — Trace backward through call chains to find the original trigger
- [Find polluter script](skills/systematic-debugging/find-polluter.sh) — Bisection script to find which test creates unwanted files/state

## Installation

### Claude Code

```
/plugin marketplace add tmdgusya/engineering-discipline
/plugin install engineering-discipline
```

### Gemini CLI

```bash
gemini extensions install https://github.com/tmdgusya/engineering-discipline
```

### Cursor

Install from the plugin marketplace, or:

```text
/add-plugin engineering-discipline
```

### Codex

```bash
npx skills add tmdgusya/engineering-discipline
```

Or install globally (available across all projects):

```bash
npx skills add tmdgusya/engineering-discipline -g
```

See [Codex install guide](.codex/INSTALL.md) for details.

### OpenCode

Add to your `opencode.json`:

```json
{
  "plugin": ["engineering-discipline@git+https://github.com/tmdgusya/engineering-discipline.git"]
}
```

See [OpenCode install guide](.opencode/INSTALL.md) for details.

## Verify Installation

Start a new session and mention a performance concern or a bug. The relevant skill should activate automatically.

## Marketplace

This plugin is listed in the Claude Code plugin marketplace.

- **Category:** engineering
- **Tags:** optimization, debugging, engineering, discipline, rob-pike, systematic, performance, testing

### Install from marketplace

```
/plugin marketplace add tmdgusya/engineering-discipline
/plugin install engineering-discipline
```

### Publish updates

Update `.claude-plugin/marketplace.json` with a new version and push to the repository. The marketplace entry pulls metadata from that file.

## License

MIT
