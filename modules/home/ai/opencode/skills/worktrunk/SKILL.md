---
name: worktrunk
description: Use for Git repository changes that need an isolated task worktree, a generated commit message, or Worktrunk lifecycle commands. Covers wt creation, resuming assigned worktrees, safe commits, and explicitly requested merges or cleanup. Respects agent-managed worktree ownership.
---

# Worktrunk workflow

Use `wt` for user-managed task worktree creation, commits, merges, and cleanup.
Ordinary Git inspection and selective staging remain available inside the task
worktree.

## Select the task worktree

- Before editing, run `git status --short` and inspect `wt list`.
- If the task already has an assigned non-default worktree, work there. Do not
  create another worktree or switch away from the assigned path.
- If the agent runtime created a subagent worktree, use that directory as given,
  even if HEAD is detached. Only the runtime owns its creation and cleanup.
  Do not recreate it with `wt`, run `wt merge` there, or remove it with `wt remove`.
- Otherwise, create an isolated worktree with `wt switch --create <branch>`.
  Check the intended base first. Worktrunk defaults to the default branch;
  pass `--base=<ref>` when the task needs another base.
- Use a descriptive branch name such as `feat/<name>`, `fix/<name>`,
  `docs/<name>`, or `chore/<name>`.
- To resume an existing user-managed task, use `wt switch <branch>`.
- Do not edit the default-branch worktree. Do not use `git worktree add`,
  `git worktree remove`, or `git merge` for the user-managed task lifecycle.

`wt switch` changes the shell directory only with shell integration. In command
runners, use `--no-cd --format=json` and use the returned worktree path as the
working directory for subsequent commands. A prior shell's directory change
may not persist between tool calls.

Read-only work does not need a new worktree.

## Review and commit

Commit only when the user or coordinating agent authorizes it. A delegate
assigned implementation only must leave the changes for its coordinator.

1. Review `git status --short`, the diff, and relevant verification results.
2. Choose the staging scope. `wt step commit` defaults to all changes, including
   untracked files. If unrelated files exist, use `git add <paths>` to stage only
   task files, inspect `git diff --cached`, and use `--stage=none` for both commands
   below. Use `--stage=none` only after reviewing everything already in the index.
3. Run `wt step commit --dry-run` with the chosen staging option. It calls the
   configured generator without staging, committing, or running hooks.
4. Check that the generated message describes the change and matches recent
   repository history. Do not proceed with a fallback message or a failed
   generator. The local `worktrunk-commit-message` generator uses OpenCode and
   the configured OpenRouter secret; fix missing dependencies rather than
   bypassing generation.
5. Run `wt step commit` with the same staging option. It invokes the generator
   again, so inspect the actual message with `git log -1` afterward.
6. Confirm the commit contains only intended files and inspect the remaining
   worktree changes. Do not use `git commit`, including `--amend`, to bypass
   this workflow.

For a clean task worktree containing only intended changes:

```sh
git status --short
git diff --check
git diff
# Run the repository's relevant formatter, tests, or build.
wt step commit --dry-run
wt step commit
git log -1 --stat
git status --short
```

## Merge or clean up only when requested

A completed task does not imply permission to merge or remove its worktree.

- Only when the user requests integration, run
  `wt merge --no-squash [target]` from the user-managed task worktree.
  The target defaults to the default branch. Review the diff and verification
  results first, and require a clean worktree with prepared commits.
- Keep `--no-squash` to preserve the prepared commits. The local Worktrunk config
  also sets `merge.commit = false` so integration requires a clean worktree.
  Worktrunk may rebase onto the local target and removes the task worktree and
  branch after a successful merge. It does not fetch the remote target.
- If a merge leaves a rebase conflict, resolve or abort that rebase before
  retrying. After resolution, rerun verification before integration. Do not
  bypass a failed stage.
- For requested cleanup, use `wt remove <branch>` only after confirming the
  worktree is clean and its commits are preserved elsewhere.
- Do not force-remove dirty worktrees or unmerged branches without explicit
  user approval. Do not use `--no-hooks`, `--no-rebase`, `--no-remove`, `--force`,
  or `-D` unless explicitly requested or required by a documented technical
  reason. Explain that reason before proceeding.
