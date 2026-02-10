# agent-self-learning

Flight recorder for agent work sessions.

This skill instructs the agent to silently log friction points (detours,
retries, missing tools, assumptions, user questions, quality issues) during
work, and only mention the log at task completion if any entries were created.

## Output location

The log is written to:

```
.agent/learning-log.md
```

