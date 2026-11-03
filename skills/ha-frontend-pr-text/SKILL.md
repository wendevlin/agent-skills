---
name: ha-frontend-pr-text
description: Draft the PR title, the full PR template body (proposed change filled in, boxes ticked) and a screenshot hint for a Home Assistant frontend branch, in Wendelin's own PR style. Use when asked to "write the PR text", "PR description", "PR title", "help me with the PR", or before opening a frontend pull request. Only drafts text for the user to copy; never creates or edits the PR.
---

# HA Frontend PR Text

Produce three things, nothing else:

1. A **PR title** in a copyable `text` block.
2. The **full PR body** in one copyable `markdown` block: the complete `.github/PULL_REQUEST_TEMPLATE.md` with the proposed change written in and the boxes ticked (see section 5).
3. A **screenshot hint**: what to capture, or that none is needed.

Do not open, edit or comment on PRs. The user reviews and posts the text themselves (see `AI_POLICY.md`).

## 1. Find the change

- The local `dev` is often stale. Compare against the real base: `git fetch origin dev` then `git merge-base origin/dev HEAD`, and use `git log --oneline <base>..HEAD` and `git diff <base>..HEAD`. Sanity-check that the commit list only holds this branch's commits.
- If a PR number or URL is given, use `gh pr view <n>` and `gh pr diff <n>` instead.
- Include uncommitted changes if `git status` shows any, and say so.
- Read the commit messages: they usually state the intent better than the diff.

## 2. Find what to reference

- Issue or PR numbers in commit messages, branch name, code comments and the diff.
- Related PRs by the user: `gh pr list --author @me --state all --limit 30 --json number,title,state`. Look for the PR this one follows up, builds on, is stacked on or replaces.
- **Series PRs:** if the branch is part of a series (for example `data-table-url/*` adding query params page by page), open the closest sibling with `gh pr view <n> --json body` and reuse its structure and wording, changing only what differs. Consistency across a series matters more than fresh phrasing.
- Cross-repo work, like a matching My Home Assistant or core PR: `gh pr list -R home-assistant/<repo> --author @me`. Reference as `home-assistant/<repo>#<n>`. If one is likely needed but can't be found, leave a `#<PR>` placeholder and tell the user.
- Only reference what helps a reviewer. Don't pad with loosely related links.

## 3. Write the title

- **At most 63 characters, including spaces.** GitHub flags longer titles in red. Count with `printf %s "<title>" | wc -m` before answering, and shorten if it's over. For example, "Split up the add automation element dialog and move it to contexts" (66) is too long; "Split up the add automation element dialog" works.
- Sentence case, imperative verb, no prefix, no trailing period, about 4–8 words.
- Say what changes for the user or the codebase, not how: "Add query params to the tags table", "Fix image cropper race conditions", "Keep dropdown menus within the viewport", "Make data tables usable with keyboard and screen reader".
- Common verbs: Add, Fix, Keep, Make, Improve, Use, Move, Remove, Migrate, Show.

## 4. Write the proposed change

Short and easy to scan beats complete. Cut every word that doesn't help a reviewer.

**Opening (1–2 sentences):**

- Start with the relation if there is one: `Fixes #123`, `Follow-up to #123`, `Successor of #123`, `Implements #123`, `Stacked on #123`.
- Then what was wrong or missing, and what this changes. "Before, ..." works well for bugs.

**Bullets:**

- One bullet per change. Use a **bold lead-in** when bullets cover different areas: `- **Sorting with the keyboard:** ...`.
- Sub-bullets only for details a reviewer needs, like a new property, a CSS variable or a removed API.
- Add a short "because ..." when the reason isn't obvious from the code.
- Put identifiers, properties, CSS variables, files and versions in backticks.
- Group internal-only changes at the end under `Other changes:` if they're worth mentioning at all.

**Closing lines, only when they apply:**

- `No visual changes intended.`
- What's deliberately not in this PR and where it goes: "The page still has no `h1`; that is fixed in a follow-up."
- Tests: one line saying what the test protects, not that a test exists.
- Breaking change: a `## Breaking change` section *above* the text, saying exactly what custom themes, cards or users must change.

**Style:**

- Plain, everyday words. Short sentences. No marketing, no "This PR ...", no filler like "various improvements".
- Describe behaviour from the user's side first, implementation second. Use Home Assistant terminology (see `ha-frontend-user-facing-text`): "Back", "My Home Assistant", "entity", "dashboard".
- Don't restate the title. Don't list every file.
- A tiny change gets a tiny body: one or two bullets is fine.

### Examples of the target style

```markdown
Fixes #54793

The image cropper broke after closing it once, and the file drawer kept files that weren't used.

- **Re-opening the cropper works again.** The dialog now uses `DialogMixin`, so each open gets a fresh cropper.
- **Crop is disabled until the image has loaded.**
- **The file drawer only shows used files.** Cancelling, clearing or a failed upload leaves it empty.
```

```markdown
Follow-up to #55145 and #55183

- Add `ha-action-bar`, a generic bar for actions below a scrolling list.
  - The top border can be changed with `--ha-action-bar-border-top`.
- Move the automation paste bar to `ha-paste-bar`, built on `ha-action-bar`.
  - The caller passes the full localized label, because "Paste action" can't be built from a shared "Paste" string in every language.
- Use `ha-paste-bar` in the add automation element, create card and create badge dialogs.

No visual changes intended.
```

## 5. Fill in the full template

Read `.github/PULL_REQUEST_TEMPLATE.md` from the repo each time; don't work from memory, it changes. Keep everything else verbatim, including the HTML comments, link references at the bottom, and section order.

- **Breaking change:** remove the section (heading and comment) unless the change is breaking. If it is, write the user-facing text there.
- **Proposed change:** the text from section 4, below the comment.
- **Screenshots:** leave the section empty for the user to fill. Remove it only when there is no visual change at all.
- **Type of change:** tick exactly one box that fits the diff. Use "Code quality improvements" for refactors, migrations and tests; "Bugfix" for fixes; "New feature" for new user-visible behaviour.
- **Additional information:** fill in what you found in section 2: `fixes #<n>`, related issues or PRs, and links to docs, contributors docs or backend PRs. Leave lines empty that don't apply; don't delete them.
- **Checklist:** tick these six:
  - I understand the code I am submitting and can explain how it works.
  - The code change is tested and works locally.
  - There is no commented out code in this PR.
  - I have followed the perfect PR recommendations
  - Any generated code has been carefully reviewed for correctness and compliance with project standards.
  - I have reviewed two other open pull requests in this repository.
- Tick "Documentation added/updated" only if a docs PR is linked.

## 6. Screenshot hint

Keep it to a few bullets and be concrete about what to show:

- **Visual change:** before and after of the exact spot, in the states that changed (empty, error, hover, focus, selected).
- **Interaction or flow:** a short video beats screenshots (drag, keyboard navigation, dialogs opening, Back behaviour).
- **Layout:** add mobile width, and RTL or dark theme if the change touches spacing, direction or colors.
- **A11y:** screen reader output or the accessibility tree, and visible focus rings.
- **No visual change:** say so; the Screenshots section is already removed from the body. For URL or state changes, a screenshot of the address bar or a short video of reload or Back still helps.

## Output format

````markdown
**Title**

```text
<title>
```

**PR body**

```markdown
<full template>
```

**Screenshots**

- <hint>
````

After the blocks, add at most two short notes: placeholders to fill in, or something left out on purpose that the user might want back.
