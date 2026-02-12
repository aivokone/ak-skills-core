# AGENTS.md

Repository-specific guidance for agents working in `ak-skills-core`.

## Scope And Precedence

- This file defines repo-local policy only.
- For generic skill-authoring workflow, use `skill-creator` guidance (for example `.agents/skills/skill-creator/SKILL.md`).
- If any generic guidance conflicts with this file, `AGENTS.md` wins in this repository.

## Repository Model

- This is a multi-skill repository: each skill lives in `skills/<skill-name>/`.
- Keep each `SKILL.md` lean and use `references/` for detailed procedures.
- Use searchable keywords in references so `rg` can find the right section quickly.
- Keep `CLAUDE.md` minimal and scoped to Claude-only overrides.

## Per-Skill File Contract

Each skill should include:

- `skills/<skill-name>/SKILL.md` with frontmatter (`name`, `description`)
- `skills/<skill-name>/evals.json`
- `skills/<skill-name>/references/` when additional detail is needed
- Do not add `skills/<skill-name>/README.md`; keep essential behavior in `SKILL.md`
  and user-facing catalog details in root `README.md`.

`evals.json` case format:

```json
{
  "name": "Test case name",
  "prompt": "User prompt to test",
  "expectations": ["Expected behavior 1", "Expected behavior 2"]
}
```

## Root README Contract

Treat root `README.md` as the public landing page and keep it synchronized with actual skills.

- `Skills Index` is the canonical compact list of all skills.
- In `Skills Index`, include both human-readable name and slug.
- `Skill Catalog` must include one section per skill with heading format:
  - `### Human Name (`skill-slug`)`
- Each skill section must include:
  - short practical description
  - source paths (at least `skills/<skill-name>/SKILL.md`)
  - project install command: `npx skills add ... --skill <skill-name>`
  - global install command: `npx skills add ... --skill <skill-name> -g`

## Change Checklists

### Adding A New Skill

1. Create `skills/<skill-name>/`.
2. Add `SKILL.md` and `evals.json`.
3. Add `references/` content as needed.
4. Update root `README.md` (`Skills Index` and `Skill Catalog`).
5. Update `.claude-plugin/plugin.json`.

### Major Skill Update

When behavior changes materially (output format, behavior model, activation/reporting semantics), update at minimum:

1. `skills/<skill-name>/SKILL.md`
2. `skills/<skill-name>/evals.json`
3. The matching `Skill Catalog` subsection in root `README.md`

## Public Repo Hygiene

- Do not commit secrets (API keys, credentials, private hostnames, customer data).
- Use placeholders like `example.com`, `USER`, and `PROJECT_ID` unless the target is explicitly public.

## Search Patterns

```bash
rg -n "keyword" skills/<skill-name>/references/
rg -n "keyword" skills/*/references/
```

Open only matching files instead of loading all references.
