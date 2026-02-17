#!/bin/bash
# Check all PR feedback sources (conversation, inline, reviews)
# Usage: ./check-pr-feedback.sh [PR_NUMBER]
#
# If PR_NUMBER not provided, uses current PR from git branch

set -euo pipefail

# Check for required dependencies
if ! command -v gh &> /dev/null; then
  echo "Error: 'gh' (GitHub CLI) is not installed. Please install it to use this script." >&2
  echo "See: https://cli.github.com/" >&2
  exit 1
fi

PR="${1:-$(gh pr view --json number -q .number 2>/dev/null || echo "")}"
if [ -z "$PR" ]; then
  echo "Error: No PR number provided and couldn't detect current PR" >&2
  echo "" >&2
  echo "Usage: $0 [PR_NUMBER]" >&2
  echo "" >&2
  echo "Make sure you are:" >&2
  echo "  1. In a git repository root directory" >&2
  echo "  2. On a branch with an open PR (if not providing PR number)" >&2
  echo "" >&2
  echo "Current directory: $(pwd)" >&2
  echo "Current branch: $(git branch --show-current 2>/dev/null || echo 'unknown')" >&2
  exit 1
fi

REPO=$(gh pr view "$PR" --json headRepository,headRepositoryOwner \
  -q '.headRepositoryOwner.login + "/" + .headRepository.name' 2>/dev/null \
  || gh repo view --json nameWithOwner -q .nameWithOwner)

echo "Checking PR #$PR in $REPO"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📝 CONVERSATION COMMENTS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
COMMENTS=$(gh api --paginate "repos/$REPO/issues/$PR/comments" \
  --jq '.[] | "[\(.id)] [\(.user.login)] \(.created_at | split("T")[0])\n\(.body)\n---"')
if [ -z "$COMMENTS" ]; then
  echo "None"
else
  printf "%s\n" "$COMMENTS"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "💬 INLINE COMMENTS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
INLINE=$(gh api --paginate "repos/$REPO/pulls/$PR/comments" \
  --jq '.[] | "[\(.id)] \(.path):\(.line // .original_line) [\(.user.login)]\n\(.body)\n---"')
if [ -z "$INLINE" ]; then
  echo "None"
else
  printf "%s\n" "$INLINE"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ REVIEWS (state + body)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
REVIEWS=$(gh api --paginate "repos/$REPO/pulls/$PR/reviews" \
  --jq '.[] | "[\(.id)] \(.state) [\(.user.login)] \(.submitted_at | split("T")[0])\n\(.body // "No body")\n---"')
if [ -z "$REVIEWS" ]; then
  echo "None"
else
  printf "%s\n" "$REVIEWS"
fi
