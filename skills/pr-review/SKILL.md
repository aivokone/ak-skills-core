---
name: pr-review
description: Use FIRST for any PR/code review work — checking feedback, reading CR comments, responding to reviewers, addressing review bot or human comments, or preparing commits on a PR. Collects feedback from ALL sources (conversation, inline, reviews) to prevent the common failure of missing inline feedback. Start with check-pr-feedback.sh, then reply inline where needed and summarize with one Fix Report.
---

# PR Review Workflow

Systematic workflow for checking, responding to, and reporting on PR feedback from any source — human reviewers, review bots (CodeRabbit, Gemini, Codex, Snyk, etc.), or AI agents.

**Requirements:** GitHub repository with [GitHub CLI (`gh`)](https://cli.github.com/) installed and authenticated.

**Key insight:** PR feedback arrives through three different channels (conversation comments, inline threads, review submissions). Missing any channel means missing feedback. This skill ensures all channels are checked systematically.

## Quick Commands

**Note:** Run scripts from repository root, not from `.claude/skills/` directory.

### Check All Feedback (CRITICAL - Use First)

```bash
.claude/skills/pr-review/scripts/check-pr-feedback.sh [PR_NUMBER]
```

Checks all three sources: conversation comments, inline comments, reviews.

If no PR number provided, detects current PR from branch.

### Reply to Inline Comment

```bash
.claude/skills/pr-review/scripts/reply-to-inline.sh <COMMENT_ID> "Your message"
```

Replies in-thread to inline comments. Uses `-F` flag (not `--raw-field`) which properly handles numeric ID conversion in `gh` CLI.

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
.claude/skills/pr-review/scripts/check-pr-feedback.sh
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
- Review feedback may arrive in conversation comments, inline threads, or review submissions. Check all channels.
```

Or copy from `assets/pr_template.md`.

### Create PR

Fill Summary, How to test, and Notes sections.

## Code Review Coordination

### Feedback Channels

| Channel | Who Posts Here | Format |
|---------|---------------|--------|
| Conversation | AI agents, humans | Top-level comments |
| Inline | Review bots (CodeRabbit, Gemini, Codex, Snyk, etc.), humans | File/line threads |
| Reviews | Humans, some bots | Approve/Request Changes + optional body |

### Critical Rule: Check ALL Three Channels

```bash
.claude/skills/pr-review/scripts/check-pr-feedback.sh
```

**Why:** Different reviewers post in different channels. Missing any channel = missing feedback.

Three channels:

1. **Conversation comments** — general discussion, agent reviews
2. **Inline comments** — file/line-specific feedback from any reviewer
3. **Reviews** — approval state + optional body

### Responding to Inline Comments

1. **Address the feedback** in code
2. **Reply inline** to each comment (sign with agent identity):

```bash
.claude/skills/pr-review/scripts/reply-to-inline.sh <COMMENT_ID> "Fixed @ abc123. [details] —[Your Agent Name]"
```

3. **Include in Fix Report** (conversation comment) — the Fix Report summarizes all changes, but inline replies ensure each comment gets a direct acknowledgment

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

## Multi-Reviewer Patterns

### Duplicate Feedback

If multiple reviewers flag the same issue:

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

### Finding Comments by Reviewer

```bash
# Set REPO and PR for your context
REPO="owner/repo"  # or: gh repo view --json nameWithOwner -q .nameWithOwner
PR=42               # or: gh pr view --json number -q .number

# Find comments by a specific reviewer (e.g., CodeRabbit, Gemini)
gh api repos/$REPO/pulls/$PR/comments \
  --jq '.[] | select(.user.login | contains("coderabbitai")) | {id, line, path, body}'
```

## Troubleshooting

**"Can't find review comments"**
→ Check all three sources. Use `.claude/skills/pr-review/scripts/check-pr-feedback.sh`, not just `gh pr view`.

**"Reviewer posted inline, should I reply inline?"**
→ Address in code, include in Fix Report, optionally reply inline with brief ack.

**"Multiple reviewers flagged same issue"**
→ Fix once, report once (note all sources), tag all reviewers.

**"Conflicting suggestions"**
→ Mark QUESTION, check project docs, cite specific suggestions.

**"Script can't detect PR"**
→ Run from repository root (not `.claude/skills/`). Must be on branch with open PR.

**"Reply script fails with HTTP 422"**
→ Use `-F in_reply_to=ID` not `--raw-field`. The `-F` flag works correctly with `gh` CLI for numeric IDs.

**"Review suggestion broke working code"**
→ Always test suggestions before committing. Some suggestions may be incorrect or context-dependent.

**"Committed before checking latest feedback"**
→ Run feedback check script immediately before declaring PR "ready" or "complete."

## Summary

**Key principles:**

1. Always check all three channels (conversation + inline + reviews)
2. Any reviewer (human, bot, agent) can post in any channel
3. One Fix Report per round
4. Tag all reviewers explicitly

**Most common mistake:**
❌ Only checking conversation or `gh pr view`
✅ Always run `.claude/skills/pr-review/scripts/check-pr-feedback.sh`
