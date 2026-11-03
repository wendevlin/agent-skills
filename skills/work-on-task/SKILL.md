---
name: work-on-task
description: Workflow for carrying out a coding task in a git repository. Work on a fresh branch named `<agent-name>/<meaningful-name>`, never open a pull request, and finish with an extra self-review round before reporting back. Use whenever asked to implement, fix, change or add something in a repo ("work on this", "implement X", "fix the bug", "add a feature").
---

# Work on a Task

Carry the task from a clean start to a reviewed, committed result on its own branch. The user decides what happens to the branch afterwards.

## 1. Start on a new branch

- Check `git status` first. If there are uncommitted changes that are not yours, stop and ask what to do with them; never stash, reset or discard them on your own.
- Branch from the up-to-date default branch, not from whatever happens to be checked out: `git fetch origin`, then `git switch -c <branch> origin/<default>`. Find the default with `git symbolic-ref refs/remotes/origin/HEAD` if unsure. If the task builds on another unmerged branch, branch from that one instead and say so.
- Name the branch `<agent-name>/<meaningful-name>`:
  - `<agent-name>` is your own name in lowercase, for example `claude`, `copilot` or `codex`.
  - `<meaningful-name>` is a short kebab-case summary of the change, starting with a verb where it reads naturally: `claude/add-csv-export`, `copilot/fix-login-redirect`, `codex/remove-legacy-config`.
  - No ticket-only names (`claude/task-123`) and no vague ones (`claude/changes`, `claude/fix`). Add the issue number at the end if there is one: `claude/fix-login-redirect-4821`.
- If the branch name already exists, pick a more specific name instead of reusing or overwriting it.

## 2. Do the work

- Read the repo's own guidance before changing anything: `AGENTS.md`, `CLAUDE.md`, `CONTRIBUTING.md`, `.github/copilot-instructions.md`, and the README. Follow its conventions over your defaults.
- Stay in scope. Note unrelated problems you find for the final report instead of fixing them in the same branch.
- Run the project's checks (tests, linters, type checks, build) for what you touched, and fix what you broke.
- Commit in logical steps with messages that say why, following the repo's commit style. Don't leave the work uncommitted.

## 3. Don't open a pull request

- Never open, draft or comment on a pull request, and don't push unless the user asks. The user reviews the branch and opens the PR themselves.
- If the user asks for PR text, draft it in the reply for them to copy.

## 4. Review your own work

When the task feels done, do one more full review round before reporting. Review the complete change as a reviewer seeing it for the first time, not from memory:

```sh
git diff origin/<default>...HEAD
git log --oneline origin/<default>..HEAD
```

Check for:

- **Correctness:** does it do what was asked, including edge cases and error paths?
- **Scope:** unrelated edits, drive-by reformatting, files that shouldn't be there.
- **Leftovers:** debug output, commented-out code, TODOs you added, temporary files.
- **Tests and docs:** new behaviour covered by tests; README, docs and changelogs updated where the repo keeps them.
- **Consistency:** naming and structure match the surrounding code.
- **Checks:** re-run them on the final state.

Fix what you find in new commits, then review the fixes the same way. Only stop when a round finds nothing worth changing.

## 5. Report back

Keep the report short:

- The branch name, and that no PR was opened.
- What changed and why, in a few bullets.
- Which checks you ran and their results. Say plainly if something failed or was skipped.
- What the review round found and how you fixed it.
- Open questions and out-of-scope issues you noticed.
