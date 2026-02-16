---
name: local-ref
description: Maintain project-local reference documentation cached from Context7 and other sources. Use when (1) initializing local docs for a new project, (2) updating or expanding existing reference docs, (3) looking up library documentation — check local cache first, (4) saving useful externally fetched docs for future sessions.
---

# Local Reference

Cache library documentation locally so every session reads from disk instead of re-fetching from external sources. Local docs load via `Read` tool (free, instant) instead of API calls (tokens + latency).

## Sources

Fetch documentation from any of these, in order of preference:

1. **Context7 API** — curated library docs with code examples. See `references/context7-api.md`.
2. **WebFetch** — official documentation sites (e.g., developer.wordpress.org, getbootstrap.com)
3. **Manual** — user-provided docs, internal wikis, or CLI `--help` output

## Commands

### Init — `local-ref init`

Set up local documentation cache for a project.

1. **Detect project technologies** from these sources:
   - `package.json` (JS/Node dependencies)
   - `composer.json` (PHP dependencies)
   - `AGENTS.md` / `CLAUDE.md` (mentioned frameworks)
   - `requirements.txt` / `pyproject.toml` (Python)
   - `Gemfile` (Ruby)
   - `go.mod` (Go)

2. **Confirm with user** which technologies to cache. Suggest the top 3-5 most relevant. Skip generic/obvious ones (e.g., don't cache "JavaScript" docs for a JS project).

3. **For each technology**, fetch documentation using the best available source (see Sources above).

4. **Write project-specific docs** to `docs/reference/<topic>.md`:
   - Start each file with: `# <Topic> — Project Reference` and a source note
   - Include only patterns relevant to this project's actual code
   - Cross-reference actual project files when possible (e.g., "Used in `lib/acf.php`")
   - Target 100-200 lines per file — enough to be useful, small enough to read quickly

5. **Update AGENTS.md** — add a `## Local Reference Documentation` section with verbal references (NOT `@`-references) to the docs:
   ```markdown
   ## Local Reference Documentation

   The `docs/reference/` directory contains project-specific API references.
   Check these files before using external documentation tools:

   - `docs/reference/<file>.md` — <brief description>
   ```

### Update — `local-ref update`

Refresh existing local docs.

1. Read `docs/reference/` to find existing doc files
2. For each file, re-fetch from the original source
3. Merge new content while preserving project-specific annotations
4. Report what changed

### Lookup — `local-ref lookup <topic>`

Find documentation, local-first.

1. Check `docs/reference/` for a matching file (grep for topic keywords)
2. If found, read and use local file (done)
3. If not found, fetch from external source, then ask user if the result should be saved locally

### Save — `local-ref save` (opportunistic, mid-project)

When working on a project and you fetch documentation from an external source (Context7, WebFetch, etc.) that would be useful across sessions:

1. After using the fetched docs to complete the current task, offer: "This documentation could be useful in future sessions. Save to `docs/reference/`?"
2. If user agrees, write a project-specific version (not raw dump) to `docs/reference/<topic>.md`
3. Add the new file to the AGENTS.md `## Local Reference Documentation` bullet list so future sessions discover it
4. Continue with the original task

This keeps docs growing organically as the project evolves, without requiring explicit `init` or `update` runs.

## Passive Behavior (via AGENTS.md)

The `init` command adds a `## Local Reference Documentation` section to AGENTS.md. This section loads every session (~80 tokens) and tells Claude to check `docs/reference/` before external lookups. This passive guidance works without loading the skill itself.

## Key Design Rules

- **Verbal references only** — never add `@docs/reference/...` to AGENTS.md (would bloat system prompt). Use plain text descriptions so Claude reads files on-demand.
- **Project-specific over generic** — don't dump raw API output. Tailor examples to the project's actual code, file structure, and patterns.
- **Cross-reference project files** — mention where patterns are used (e.g., "see `lib/assets.php` for implementation").
- **One file per topic** — keep docs modular. Don't create one giant reference file.
- **100-200 lines per file** — large enough to be useful, small enough to `Read` without waste.

## File Naming Convention

Use descriptive kebab-case names:
```
docs/reference/
├── acf-patterns.md
├── vite-asset-pipeline.md
├── wordpress-cpt-taxonomy.md
├── bootstrap-grid-components.md
└── react-hooks-patterns.md
```

## External Source References

See `references/context7-api.md` for Context7 API endpoints and common library IDs.
