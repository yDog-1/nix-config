---
name: worktrunk
description: Use when modifying a Git repository with wt or Worktrunk, including creating worktrees, committing, merging, or removing branches. Requires Worktrunk-managed worktrees for every repository change.
---

# Worktrunk Workflow

Use `wt` for every Git repository modification. `wt` is Worktrunk, the
repository's worktree lifecycle manager.

## Required Rules

- Before making a change, run `git status --short` in the current worktree.
- For new work, create an isolated worktree with `wt switch --create <branch>`.
- Use a descriptive branch name such as `feat/<name>`, `fix/<name>`,
  `docs/<name>`, or `chore/<name>`.
- If the task already has an appropriate non-default worktree, continue there
  with `wt switch <branch>` instead of creating another one.
- Do not edit the default-branch worktree. Do not use `git worktree add`,
  `git worktree remove`, or `git merge` for the task lifecycle.
- Merge only from the feature worktree with `wt merge [target]`; the target is
  the default branch when omitted.
- Before merging, review the diff, run relevant verification, and confirm that
  no unintended files are included.
- Let `wt merge` create the squash commit message. It must match the
  repository's recent commit convention, using a concise imperative
  Conventional Commit when that convention is established.
- Do not use `--no-hooks`, `--no-rebase`, `--no-remove`, `--force`, or `-D`
  unless the user explicitly requests it or there is a documented technical
  reason. Explain the reason before doing so.

## Standard Flow

```sh
# From the primary worktree, before any repository edits
git status --short
wt switch --create feat/short-description

# Make changes in the new worktree, then verify them
git diff --check
# Run the repository's relevant formatter, tests, or build

# Review and integrate from the feature worktree
git status --short
git diff
wt merge
```

`wt switch` changes directories only when its shell integration is active. If
automation uses `--no-cd`, use the returned worktree path as the working
directory for all subsequent commands.

## Existing Work and Cleanup

- Inspect active worktrees with `wt list` before selecting or creating one.
- Use `wt switch <branch>` to resume an existing branch.
- For abandoned work, use `wt remove <branch>` only after confirming it is safe
  to discard. Never force-remove dirty worktrees or unmerged branches without
  explicit user approval.
- If a merge has conflicts or verification fails, resolve the issue in the
  feature worktree, rerun verification, and then rerun `wt merge`. Do not
  bypass the failed stage.

## Exceptions

Read-only work does not need a new worktree: inspecting files, searching,
reviewing, running status commands, or answering questions can happen in the
current worktree. Creating or changing files, formatting, generating lockfiles,
committing, merging, or deleting branches must use the Worktrunk workflow.
