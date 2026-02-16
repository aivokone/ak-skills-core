# Aivokone Core Skills (`ak-skills-core`)

General-purpose, always-on skills using the open [skills standard](https://skills.sh/).

This repo is for skills that are broadly useful across projects and tend to be
installed globally in an agent environment (as a "default toolbox").

This is a multi-skill repository: each skill is self-contained under `skills/<skill-name>/`.

## Install (skills.sh / npx skills)

```bash
# Install all skills from this repo to current project
npx skills add aivokone/ak-skills-core
```

For full usage and installation details, see [skills.sh docs](https://skills.sh/docs).

## Skills Index

The table below is the canonical skills index for this repository.

| Name | Slug | Description |
|------|------|-------------|
| [Agent Flight Recorder](skills/agent-flight-recorder/) | `agent-flight-recorder` | Recorder-only flight log for agent runs: logs deviations to per-run files |
| [Local Reference](skills/local-ref/) | `local-ref` | Cache library docs locally so every session reads from disk instead of re-fetching |
| [Multi-Agent PR](skills/multi-agent-pr/) | `multi-agent-pr` | Multi-agent PR and code review workflow for projects with multiple AI review assistants |

## Skill Catalog

### Agent Flight Recorder (`agent-flight-recorder`)

Recorder-only flight logger for agent runs. Logs only deviations from the
expected path (detours, retries, setup surprises, missing context, blockers,
quality rework) to per-run files.

Source:
- `skills/agent-flight-recorder/SKILL.md`

Run output:
- `.agents/flight-recorder/flight-YYYY-MM-DD-HHMMSS-TZ.md`
- File header schema: `flight-recorder/v2.5`
- Header includes recorder metadata: `recorder_agent` (product name), `recorder_model` (exact model ID), optional `recorder_effort` and `task`
- Run footer with `entries`, `high_severity`, `outcome` for quick scanning
- Entries include `at` timestamp (ISO-8601 with timezone) for ordering and duration estimation
- Default git hygiene: ignore `/.agents/flight-recorder/` in `.gitignore` (opt out only if intentionally versioning logs)

Install to project scope:

```bash
npx skills add aivokone/ak-skills-core --skill agent-flight-recorder
```

Install globally:

```bash
npx skills add aivokone/ak-skills-core --skill agent-flight-recorder -g
```

### Project instruction snippet

If you want to enforce usage in a specific project, add a short note to the
project's agent instruction file (for example `AGENTS.md`, `CLAUDE.md`, or
similar).

```md
### Flight Recorder (`agent-flight-recorder`)

- For long or multi-step tasks, use the `agent-flight-recorder` skill when available.
- If the skill is unavailable, manually write one run file under `.agents/flight-recorder/`.
- Log only deviations: retries, detours, missing tools, blocking missing context, assumptions, and quality rework.
- Do not mention the log mid-task.
- At task completion, if entries were created, include: `Flight recorder: N entries logged. See <path>.`
```

This keeps flight-recorder behavior explicit at the project level and improves
consistency across agents.

### Local Reference (`local-ref`)

Cache library documentation locally so every session reads from disk instead of
re-fetching from external sources. Supports Context7 API, WebFetch, and manual
sources. Includes commands for initializing a project doc cache (`local-ref init`),
looking up docs local-first (`local-ref lookup`), updating cached docs
(`local-ref update`), and opportunistically saving fetched docs (`local-ref save`).

Docs are written to `docs/reference/<topic>.md` — project-specific, 100-200 lines
each, with cross-references to actual project files. Each file includes a
machine-readable header (`<!-- source="..." cached="..." -->`) that enables
reliable automated updates.

Source:

- `skills/local-ref/SKILL.md`

Install to project scope:

```bash
npx skills add aivokone/ak-skills-core --skill local-ref
```

Install globally:

```bash
npx skills add aivokone/ak-skills-core --skill local-ref -g
```

### Multi-Agent PR (`multi-agent-pr`)

PR and code review workflow for projects using multiple AI review assistants
(Claude, GitHub Copilot/Codex, Gemini Code Assist). Teaches agents how to check
all feedback sources (conversation, inline, reviews), create Fix Reports, reply
to inline bot comments, and coordinate between agents that use different comment
formats.

Includes helper scripts:

- `scripts/check-pr-feedback.sh` — check all three feedback sources for a PR
- `scripts/reply-to-inline.sh` — reply in-thread to inline bot comments

Source:

- `skills/multi-agent-pr/SKILL.md`

Install to project scope:

```bash
npx skills add aivokone/ak-skills-core --skill multi-agent-pr
```

Install globally:

```bash
npx skills add aivokone/ak-skills-core --skill multi-agent-pr -g
```

## Contributing / Adding Skills

This repo follows a progressive disclosure pattern: keep `SKILL.md` lean and put detailed procedures under `references/`.

Per-skill `skills/<skill-name>/README.md` files are intentionally not used in this repo.
Keep durable skill behavior in `SKILL.md` and publish human-facing summaries in this root `README.md`.

When adding a new skill or making a major update to an existing skill, update:

- `README.md` (both `Skills Index` and `Skill Catalog` section for that skill)
- `.claude-plugin/plugin.json` (plugin manifest)

Contributor conventions live in `AGENTS.md`.
