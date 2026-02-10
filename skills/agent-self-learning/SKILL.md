---
name: agent-self-learning
description: >
  Flight recorder for agent work sessions. Silently logs friction points —
  detours, unexpected installs, retries, user questions, quality issues — so
  the developer can later feed the log to any agent and say "improve the
  process based on this feedback". Always on. The agent records automatically
  and reports at task completion only if entries were created.
---

# Agent Self-Learning — Flight Recorder

## Purpose

You are keeping a black-box flight recorder. Whenever you deviate from the
straight path during a task — a retry, a workaround, a missing tool, an
assumption, a question to the user — you silently append an entry to the log.

The log is **not for you to read back**. It is a deliverable for the developer.
They will review it after the session, or feed it to another agent to improve
workflows and instructions.

You are the recorder. The human is the analyst.

## Activation

This skill is **always active**. You do not need to be asked to keep the log.

- Record silently as you work. Do not mention the log mid-task.
- Do not let logging slow down or change your approach to the task itself.
- At the very end of the task (or if you must abort), **if you created any
  log entries**, add a brief note to your final response:

  > ℹ️ Flight recorder: [N] entries logged during this session.
  > See `.agent/learning-log.md` to review or feed to an agent for
  > workflow improvement.

- If the session produced **zero entries**, say nothing about the log.

## When to write an entry

Write a log entry whenever any of the following happens:

- **Detour**: you try one approach, it fails, and you switch to another.
- **Unexpected install or setup**: a tool, package, or dependency needed
  installing that was not part of the plan.
- **Retry**: the same step is attempted more than once.
- **User question**: you need to ask the user for clarification, approval,
  or missing information that was not provided upfront.
- **Quality issue**: output does not meet the expected standard and needs rework.
- **Slow step**: a single step consumes disproportionate effort (>30 % of work
  so far) due to complexity, waiting, or trial-and-error.
- **Assumption**: you proceed based on a guess because information is missing.
  Record what you assumed and why.

Do **not** write entries for steps that go as expected. Only deviations.

**Deduplication**: if the same problem recurs with the same signal (e.g. the
same step fails six times in a row), do not create separate entries. Update
the existing entry's Waste estimate instead (e.g. "~15 min, +4 retries").

## Entry format

Each entry uses the template below. Keep each entry to roughly 10 lines.
Write the **decision and its reason**, not your chain of thought.

```markdown
---

**Situation:** (One sentence. What you were doing.)
**Stuck:** (One sentence. Where exactly it got stuck.)
**Why:** (1–2 sentences. Root cause or best hypothesis.)
**Workaround:** (What you actually did to get past it.)
**Waste estimate:** (Rough cost of the detour: minutes, retries, or tokens
compared to the straight path. Does not need to be precise.)
**Suggested patch:** (One concrete change to instructions, workflow, or
environment that would prevent this next time.)
**Signal:** (How to recognise this situation early — an error message,
keyword, or symptom pattern.)
**Scope:** (Optional. One word if useful: pdf, web, env, parsing, auth, etc.)
```

### Rules

- `Suggested patch` is mandatory. If you have no suggestion, write
  "No clear patch — requires human judgment" and state why in one sentence.
- No raw user data, secrets, or PII. Summarise and anonymise.
- Do not write narratives or justify your reasoning at length.
- `Waste estimate` enables the developer to prioritise fixes. A rough
  "~10 min, 2 retries" is enough.

## File location

```
<project-root>/.agent/learning-log.md
```

Create the `.agent/` directory if it does not exist.
If the file already exists from a previous session, **append** to it.

**Fallback**: if writing to the file fails (e.g. filesystem not available),
include the full log inline at the end of your final response under the heading
`## Flight recorder log (inline)`. Note that the file write failed so the
developer can save it manually.

## Session header

Add before the first entry of each new session:

```markdown
## Session: <YYYY-MM-DD HH:MM TZ> — <task summary in ≤10 words>
```

If the task changes substantially mid-conversation (e.g. the user switches to
a different project or goal), start a new session header.

## Example

```markdown
## Session: 2026-02-10 14:32 EET — Migrate theme from Sage 8 to Sage 11

---

**Situation:** Generating a PDF report with reportlab.
**Stuck:** Finnish characters (ä, ö, å) rendered as boxes.
**Why:** Assumed the default font supports UTF-8. Reportlab's default
Helvetica does not include Finnish diacritics.
**Workaround:** Switched to DejaVu Sans TTF and registered it with
`pdfmetrics.registerFont()` before drawing.
**Waste estimate:** ~10 min, 2 retries.
**Suggested patch:** Add to PDF skill: "Always register a UTF-8
compatible TTF font before generating PDF output."
**Signal:** Characters ä/ö/å appear as boxes or question marks in PDF.
**Scope:** pdf
```

## What the developer does with the log

The log is designed to be fed directly to any LLM agent. Typical use:

**Post-session review** — Read the log, pick highest-waste frictions, update
skill or workflow instructions.

**Agent-assisted improvement** — Feed the log to an agent:
> "Read this flight recorder log. Suggest concrete changes to [SKILL.md /
> workflow / environment setup] that would prevent these issues. Prioritise
> by waste estimate."

**Trend analysis** (after 20+ entries) — Ask an agent:
> "List the top 5 recurring friction types, top 5 patches, and recommend
> which patches to implement first."

## Limits

- This skill does not instruct you to read previous logs at session start.
  The developer provides relevant context when needed.
- This skill does not auto-generate summaries or backlogs.
- If the log grows beyond ~100 entries, the developer should archive older
  sessions to `learning-log-archive-YYYY.md` and keep only the most recent
  ~30 entries in the active file.

