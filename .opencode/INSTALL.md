# Installing Engineering Discipline for OpenCode

## Installation

Add engineering-disciplines to the `plugin` array in your `opencode.json`:

```json
{
  "plugin": ["engineering-disciplines@git+https://github.com/tmdgusya/engineering-disciplines.git"]
}
```

Restart OpenCode. That's it.

## Verify

Ask: "What engineering discipline skills do you have?"

## Updating

Updates automatically when you restart OpenCode.

To pin a version:

```json
{
  "plugin": ["engineering-disciplines@git+https://github.com/tmdgusya/engineering-disciplines.git#v1.0.0"]
}
```

## Troubleshooting

### Skills not found

1. Use `skill` tool to list what's discovered
2. Check that the plugin line is correct in `opencode.json`
3. Restart OpenCode
