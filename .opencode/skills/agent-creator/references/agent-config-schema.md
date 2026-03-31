# Agent Configuration Schema

## opencode.json Agent Entry Structure

```json
"agent": {
  "{type}/{name}": {
    "description": "string (required) - Human-readable description",
    "temperature": "number (optional) - Model temperature, typically 0.1-0.3",
    "mode": "string (required) - 'primary' or 'subagent'",
    "prompt": "string (required) - Path to prompt file using {file:./...} syntax",
    "hidden": "boolean (optional) - If true, hide from agent list (subagents only)",
    "permission": "object (required) - Permission configuration"
  }
}
```

## Permission Object Structure

| Key         | Description                      | Common Values                                         |
| ----------- | -------------------------------- | ----------------------------------------------------- |
| `bash`      | Shell command execution          | `"deny"`, `"allow"`, or object with specific commands |
| `edit`      | File editing                     | `"allow"`, `"deny"`                                   |
| `write`     | File creation/writing            | `"allow"`, `"deny"`                                   |
| `read`      | File reading                     | `"allow"`, `"deny"`                                   |
| `grep`      | Text search in files             | `"allow"`, `"deny"`                                   |
| `glob`      | File pattern matching            | `"allow"`, `"deny"`                                   |
| `list`      | Directory listing                | `"allow"`, `"deny"`                                   |
| `patch`     | File patching                    | `"allow"`, `"deny"`                                   |
| `todowrite` | Todo list write                  | `"allow"`, `"deny"`                                   |
| `todoread`  | Todo list read                   | `"allow"`, `"deny"`                                   |
| `webfetch`  | HTTP requests                    | `"allow"`, `"deny"`                                   |
| `question`  | User questions                   | `"allow"`, `"deny"`                                   |
| `skill`     | Skill access (subagents)         | Object mapping skill names to `"allow"` or `"deny"`   |
| `task`      | Task delegation (primary agents) | Object mapping agent names to `"allow"` or `"deny"`   |
| `mcp__*`    | MCP server access                | `"allow"`, `"deny"`                                   |
| `tool__*`   | Custom tool access               | `"allow"`, `"deny"`                                   |

## Skill Permission Values

```json
"skill": {
  "code": "allow",
  "document": "deny",
  "check": "allow",
  "*": "deny"
}
```

## Task Permission Values (Primary Agents)

```json
"task": {
  "*": "deny",
  "subagent/software-engineer": "allow",
  "subagent/researcher": "allow"
}
```

## Command-Level Bash Permissions

```json
"bash": {
  "*": "deny",
  "python *": "allow",
  "psql *": "allow",
  "rg *": "allow",
  "cat *": "allow",
  "git status *": "allow"
}
```

## Validation Checklist

- [ ] Agent name is kebab-case
- [ ] Agent name is unique (no duplicate keys)
- [ ] Description is present and non-empty
- [ ] Mode is either "primary" or "subagent"
- [ ] Prompt path uses `{file:./prompts/agent/...}` syntax
- [ ] Hidden is boolean (if present)
- [ ] Permission object has valid structure
- [ ] opencode.json is valid JSON after changes
