# ak-skills-core

General-purpose, always-on skills using the open [skills standard](https://skills.sh/).

This repo is for skills that are broadly useful across projects and tend to be
installed globally in an agent environment (as a "default toolbox").

This is a multi-skill repository: each skill is self-contained under `skills/<skill-name>/`.

## Skills

The table below is the canonical skills index for this repository.

| Skill | Description |
|-------|-------------|
| [agent-flight-recorder](skills/agent-flight-recorder/) | Agent flight recorder for sessions: silently logs friction points to improve workflows |

## Install (skills.sh / npx skills)

```bash
# Install all skills from this repo
npx skills add aivokone/ak-skills-core

# Install specific skill(s)
npx skills add aivokone/ak-skills-core --skill agent-flight-recorder
```

For full usage and installation details, see [skills.sh docs](https://skills.sh/docs).

## Contributing / Adding Skills

This repo follows a progressive disclosure pattern: keep `SKILL.md` lean and put detailed procedures under `references/`.

When adding a new skill, update:
- `README.md` (skills index)
- `.claude-plugin/plugin.json` (plugin manifest)

Contributor conventions live in `AGENTS.md`.
