# agent-flight-recorder

Flight recorder for agent work sessions.

This skill instructs the agent to silently log only deviations from the
expected path (detours, retries, setup surprises, missing context, quality
rework, blockers). It is recorder-only: no analysis and no suggested fixes.

## Output location

Each run writes its own file:

```
.agent/flight-recorder/flight-YYYY-MM-DD-HHMMSS-TZ.md
```

The file starts with a schema header:

```yaml
schema: flight-recorder/v2.2
run_started: <timestamp>
```

## Project instruction snippet

If you want to enforce usage in a specific project, add a short note to the
project's agent instruction file (for example `AGENTS.md`, `CLAUDE.md`, or
similar).

```md
## Flight Recorder (`agent-flight-recorder`)

- For long or multi-step tasks, use the `agent-flight-recorder` skill when available.
- If the skill is unavailable, manually write one run file under `.agent/flight-recorder/`.
- Log only deviations: retries, detours, missing tools, blocking missing context, assumptions, and quality rework.
- Do not mention the log mid-task.
- At task completion, if entries were created, include: `Flight recorder: N entries logged. See <path>.`
```

This keeps flight-recorder behavior explicit at the project level and improves
consistency across agents.
