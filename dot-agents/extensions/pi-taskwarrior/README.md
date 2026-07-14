# pi-taskwarrior

pi extension providing TaskWarrior CRUD tools. All tools use UUIDs, never integer IDs.

## Tools

| Tool | Description |
|------|-------------|
| `task_add` | Create a new task. Hooks auto-create linked zk note. |
| `task_list` | List/search tasks with filters (project, status, tags, search). |
| `task_show` | Show full task details including UDAs and linked zk note content. |
| `task_modify` | Modify task attributes. Auto-stops/restarts active tasks. |
| `task_start` | Start tracking time on a task. |
| `task_stop` | Stop tracking time on a task. |
| `task_done` | Mark a task as completed. |
| `task_delete` | Permanently delete a task. |

## Install

Copy to `~/.agents/extensions/` and add to `~/.pi/agent/settings.json`:

```json
{
  "extensions": ["/home/sy/.agents/extensions/pi-taskwarrior/src/index.ts"]
}
```

Or test with `-e`:

```bash
pi -e ~/.agents/extensions/pi-taskwarrior/src/index.ts
```

## Design

- **UUID-only**: all tools accept and return UUIDs (TaskWarrior IDs are unstable)
- **Hooks transparent**: `on-add`, `on-modify`, `on-done` hooks fire automatically when `task` CLI is called
- **Project sanitization**: dashes in project names are auto-converted to underscores
- **Active task safety**: `task_modify` auto-stops then restarts active tasks
- **ZK note integration**: `task_show` reads linked zk note content from `zknote` UDA automatically
