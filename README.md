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

## Skill Catalog

### Agent Flight Recorder (`agent-flight-recorder`)

Recorder-only flight logger for agent runs. Logs only deviations from the
expected path (detours, retries, setup surprises, missing context, blockers,
quality rework) to per-run files.

Source:
- `skills/agent-flight-recorder/SKILL.md`
- `skills/agent-flight-recorder/README.md`

Install to project scope:

```bash
npx skills add aivokone/ak-skills-core --skill agent-flight-recorder
```

Install globally:

```bash
npx skills add aivokone/ak-skills-core --skill agent-flight-recorder -g
```

## Contributing / Adding Skills

This repo follows a progressive disclosure pattern: keep `SKILL.md` lean and put detailed procedures under `references/`.

When adding a new skill or making a major update to an existing skill, update:
- `README.md` (both `Skills Index` and `Skill Catalog` section for that skill)
- `.claude-plugin/plugin.json` (plugin manifest)

Contributor conventions live in `AGENTS.md`.
