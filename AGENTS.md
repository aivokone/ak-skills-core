# AGENTS.md

This file provides guidance to agents when working with code in this repository.

## Repository Purpose

This is **ak-skills-core**: a multi-skill repository for **general-purpose, always-on skills** that are useful across projects and can typically be installed globally as a default toolbox. Each skill is self-contained in its own directory under `skills/`.

## Architecture

### Repository Structure

```
ak-skills-core/
├── AGENTS.md                    # Repo-level agent guidance (this file)
├── CLAUDE.md                    # Claude-specific overrides (keep minimal)
├── README.md                    # Repository index / public landing page
├── .claude-plugin/
│   └── plugin.json              # Plugin manifest
└── skills/                      # All skills live here
    ├── README.md                # Skills index
    └── <skill-name>/            # Each skill is self-contained
        ├── SKILL.md             # Skill entry point
        ├── README.md            # Skill documentation
        ├── evals.json           # Per-skill evaluations
        └── references/          # Skill-specific references
```

**Progressive Disclosure Pattern**: Each skill's SKILL.md is intentionally lean (under 500 lines) and references external files. This reduces context usage - load only the specific section needed for a task rather than the entire guide.

### Skill Structure Convention

Each skill follows this pattern:
- `SKILL.md` - Skill definition with frontmatter (`name`, `description`) and core guidance
- `evals.json` - Evaluation test cases with prompts and expected outcomes
- `references/` - Detailed procedures and topic-specific documentation
- `README.md` - Skill-specific documentation and usage guide

### Current Skills

Keep the skill list and per-skill descriptions in `skills/README.md` and the root `README.md`.

## Working with This Repository

### Editing Skills

When modifying a skill's SKILL.md:
- Keep the main file lean - move detailed procedures to `references/` subdirectories
- Preserve the frontmatter format (`---` delimiters with `name` and `description`)
- Use searchable keywords in references so `rg` searches find relevant content

### Adding a New Skill

1. Create `skills/<skill-name>/` directory
2. Add `SKILL.md` with frontmatter (`name`, `description`)
3. Add `evals.json` with test cases
4. Add `references/` for detailed documentation
5. Update `skills/README.md` (skills index)
6. Update root `README.md` (top-level index)
7. Update `.claude-plugin/plugin.json` (plugin manifest)

### Adding Reference Content

Within a skill:
- Create numbered or topic-named markdown files in `references/`
- Create index files when you have many sections
- Use clear file naming for easy discovery

### Evaluation Cases

Format in each skill's `evals.json`:
```json
{
  "name": "Test case name",
  "prompt": "User prompt to test",
  "expectations": ["Expected behavior 1", "Expected behavior 2"]
}
```

## Public Repo Hygiene

- Do not add secrets (API keys, credentials, private hostnames, customer data) to skills or references.
- Prefer placeholders in examples (`example.com`, `USER`, `PROJECT_ID`) unless the target is explicitly public.

## Search Patterns

Search within a specific skill:
```bash
rg -n "keyword" skills/<skill-name>/references/
```

Search across all skills:
```bash
rg -n "keyword" skills/*/references/
```

Then open only the matching section file rather than loading everything.
