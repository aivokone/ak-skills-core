---
name: multi-agent-pr
description: Multi-agent PR and code review workflow for projects using multiple AI assistants (Claude, GitHub Copilot/Codex, Gemini Code Assist). Use when working with pull requests, code reviews, commits, or addressing review feedback. Teaches how to check all feedback sources (conversation, inline, reviews), respond to inline bot comments, create Fix Reports, and coordinate between agents that use different comment formats. Critical for ensuring no feedback is missed from external review bots.
---

# Multi-Agent PR & Code Review Workflow

Handle pull requests and code reviews in projects with multiple AI review assistants.

**Requirements:** GitHub repository with [GitHub CLI (`gh`)](https://cli.github.com/) installed and authenticated.

**Key insight:** Review bots (Gemini, Codex) don't read skills and post inline comments. This skill teaches implementers how to check ALL feedback sources and respond systematically.

## Quick Commands

**Note:** Run scripts from repository root, not from `.claude/skills/` directory.

### Check All Feedback (CRITICAL - Use First)

```bash
.claude/skills/multi-agent-pr/scripts/check-pr-feedback.sh [PR_NUMBER]
```

Checks all three sources: conversation comments, inline comments, reviews.

If no PR number provided, detects current PR from branch.

### Reply to Inline Comment

```bash
.claude/skills/multi-agent-pr/scripts/reply-to-inline.sh <COMMENT_ID> "Your message"
```

Replies in-thread to inline bot comments. Uses `-F` flag (not `--raw-field`) which properly handles numeric ID conversion in `gh` CLI.

**Must be run from repository root** with an active PR branch.

**Important:** Always sign inline replies with your agent identity (e.g., `—Claude Sonnet 4.5`, `—GPT-4`, `—Custom Agent`) to distinguish agent responses from human responses in the GitHub UI.

## Commit Workflows

### Quick Commit (No Approval)

Allowed when:
- Not on `main`/`master`
- No `--force` needed
- Changes clearly scoped

```bash
git add -A
git commit -m "<type>: <outcome>"
git push  # if requested
```

Types: `feat`, `fix`, `refactor`, `docs`, `chore`, `test`

### Safe Commit (With Inspection)

Required for `main`/`master` or ambiguous changes:

1. Inspect: `git status --porcelain && git diff --stat`
2. Wait for approval if ambiguous
3. Stage selectively: `git add -A` or `git add -p <files>`
4. Commit: `git commit -m "<type>: <outcome>"`
5. Push (never `--force`)
6. Report: branch, commit hash, pushed (yes/no)

### Self-Check Before Commit

Before committing, verify:

1. **Test changes** - If modifying working code based on suggestions, test first
2. **Check latest feedback** - Run feedback check script to catch new comments
3. **User confirmation** - If user is active in session, ask before committing
4. **Verify claims** - If Fix Report says "verified:", actually verify

Example check:

```bash
# 1. Test changes (run project-specific tests)
npm test  # or: pytest, go test, etc.

# 2. Check for new feedback since last check
.claude/skills/multi-agent-pr/scripts/check-pr-feedback.sh
# (prevents "ready to merge" when new comments exist)

# 3. If user active: "Ready to commit these changes?"
```

## PR Creation

### Set Up Template (Once)

Create `.github/pull_request_template.md`:

```markdown
## Summary
-

## How to test
-

## Notes
- Agent review loop: PR Conversation comments only (for agent-reviewers). External bots may use inline comments. See workflow docs.
```

Or copy from `assets/pr_template.md`.

### Create PR

Fill Summary, How to test, and Notes sections.

## Code Review Coordination

### Agent Roles

| Agent Type | Posts Where | Format |
|------------|-------------|--------|
| Agent-reviewers (Claude, GPT-4, custom) | Conversation | Top-level comments |
| External review bots (Gemini, Codex) | Inline | File/line threads |
| Human reviewers | Mixed | Conversation or inline |

### Critical Rule: Check ALL Three Sources

```bash
.claude/skills/multi-agent-pr/scripts/check-pr-feedback.sh
```

**Why:** External bots post inline comments even though agent-reviewers use conversation. Missing any source = missing feedback.

Three sources:

1. **Conversation comments** - Agent-reviewers post here
2. **Inline comments** - Gemini, Codex, security bots post here
3. **Reviews** - State + optional body

### Responding to Inline Bot Comments

1. **Address the feedback** in code
2. **Include in Fix Report** (conversation comment)
3. **Optionally reply inline** (sign with agent identity):

```bash
.claude/skills/multi-agent-pr/scripts/reply-to-inline.sh <COMMENT_ID> "Fixed @ abc123. [details] —[Your Agent Name]"
```

**Always end inline replies with agent signature** (e.g., `—Claude Sonnet 4.5`, `—GPT-4`, `—Custom Agent`) to distinguish from human responses in GitHub UI.

## Fix Reporting

After addressing feedback, post ONE conversation comment:

```markdown
### Fix Report

- [file.ext:L10 Symbol]: FIXED @ abc123 — verified: `npm test` passes
- [file.ext:L42 fn]: WONTFIX — reason: intentional per AGENTS.md
- [file.ext:L100 class]: DEFERRED — tracking: #123
- [file.ext:L200 method]: QUESTION — Should this handle X?

@reviewer-username please re-review.
```

### Fix Statuses

| Status | Required Info |
|--------|---------------|
| FIXED | Commit hash + verification command/result |
| WONTFIX | Reason (cite docs if applicable) |
| DEFERRED | Issue/ticket link |
| QUESTION | Specific question to unblock |

**See `references/fix-report-examples.md` for real-world examples.**

Use `assets/fix-report-template.md` as starting point.

## Review Format (For Agent-Reviewers)

Agent-reviewers MUST post ONE top-level conversation comment:

```markdown
### Review - Actionable Findings

**Blocking**
- path/file.ext:L10-L15 (Symbol): Issue → Fix → Verify: `command`

**Optional**
- path/file.ext:L100 (class): Improvement → Fix
```

Rules:

- Blocking MUST include verification (runnable command or objective check)
- Use `file:line` + symbol anchor
- Actionable, not prose
- Group by severity

**Do NOT:**

- Create inline file/line comments
- Submit GitHub review submissions
- Post multiple separate comments

**Why:** Inline comments harder to retrieve. Conversation comments deterministic.

## Re-Review Loop

After Fix Report:

1. **Request re-review**: `@reviewer please re-review. See Fix Report.`
2. **Tag ALL reviewers** who provided feedback
3. **If QUESTION items**: Wait for clarification
4. **If blocking feedback was only provided inline**: Mention it was addressed, optionally ask to mirror to conversation for future determinism

## Multi-Agent Patterns

### Duplicate Feedback

If multiple agents flag same issue:

```markdown
- [file.php:L42 (ALL flagged)]: FIXED @ abc123 — verified: `npm test` passes
  - Gemini: "use const"
  - Codex: "prefer immutable"
  - Claude: "const prevents reassignment"
```

### Conflicting Suggestions

```markdown
- [file.php:L100]: QUESTION — Gemini suggests pattern A, Codex suggests pattern B. Which aligns with project conventions? See AGENTS.md.
```

### Finding Specific Bot Comments

```bash
# Set REPO and PR for your context
REPO="owner/repo"  # or: gh repo view --json nameWithOwner -q .nameWithOwner
PR=42               # or: gh pr view --json number -q .number

# Find Gemini comment about "JavaScript"
gh api repos/$REPO/pulls/$PR/comments \
  --jq '.[] | select(.user.login == "gemini-code-assist[bot]" and (.body | contains("JavaScript"))) | {id, line, path}'
```

## Troubleshooting

**"Can't find review comments"**
→ Check all three sources. Use `.claude/skills/multi-agent-pr/scripts/check-pr-feedback.sh`, not just `gh pr view`.

**"Bot posted inline, should I reply inline?"**
→ Address in code, include in Fix Report, optionally reply inline with brief ack.

**"Multiple agents flagged same issue"**
→ Fix once, report once (note all sources), tag all reviewers.

**"Conflicting suggestions"**
→ Mark QUESTION, check project docs, cite specific suggestions.

**"Script can't detect PR"**
→ Run from repository root (not `.claude/skills/`). Must be on branch with open PR.

**"Reply script fails with HTTP 422"**
→ Use `-F in_reply_to=ID` not `--raw-field`. The `-F` flag works correctly with `gh` CLI for numeric IDs.

**"Bot suggestion broke working code"**
→ Always test suggestions before committing. Some bot suggestions may be incorrect or context-dependent.

**"Committed before checking latest feedback"**
→ Run feedback check script immediately before declaring PR "ready" or "complete."

## Summary

**Key principles:**

1. Always check all three sources (conversation + inline + reviews)
2. Agent-reviewers use conversation only
3. External bots use inline (expected)
4. One Fix Report per round
5. Tag all reviewers explicitly

**Most common mistake:**
❌ Only checking conversation or `gh pr view`
✅ Always run `.claude/skills/multi-agent-pr/scripts/check-pr-feedback.sh`
