# Agent skills

A collection of agent skills. Each skill lives in its own folder under
`skills/` and has a `SKILL.md` file. Add supporting files to that folder when
a skill needs them.

## Skills

- [`fdm-parametric-design`](skills/fdm-parametric-design/SKILL.md): Design
  functional 3D-printable parts as parametric OpenSCAD models and deliver
  print-ready 3MF/STL files with slicer settings, previews and a publishing
  package. Needs `openscad` and `xvfb` (see `scripts/setup.sh` in the skill).
- [`ha-frontend-pr-text`](skills/ha-frontend-pr-text/SKILL.md): Draft a Home
  Assistant frontend pull request title, body, and screenshot hint.
- [`work-on-task`](skills/work-on-task/SKILL.md): Carry out a coding task on
  an `<agent-name>/<meaningful-name>` branch, without opening a pull request,
  and finish with a self-review round.

## Installing skills

`scripts/install-skills.sh` copies the skills you name into
`~/.claude/skills`, replacing older copies:

```sh
scripts/install-skills.sh work-on-task ha-frontend-pr-text
```

### Claude Code cloud environments

Paste this into the environment's setup script and list the skills that
environment should get. Each environment has its own script, so each can load
a different set.

```bash
#!/bin/bash
# version: 2026-11-03 (change this line to force a fresh clone)
git clone --depth 1 https://github.com/wendevlin/agent-skills /tmp/agent-skills || exit 0
/tmp/agent-skills/scripts/install-skills.sh work-on-task ha-frontend-pr-text
exit 0
```

Notes:

- The environment's network access must allow `github.com`. With restricted
  access, the clone may still be blocked by the GitHub proxy; check the setup
  log.
- The setup result is cached for about seven days, so pushes to this repo
  don't reach the environment right away. Edit the `version` line to force a
  fresh clone.
- In a session, check that `ls ~/.claude/skills` lists the skills and that
  they appear in the `/` menu.

## Contributing

Keep each skill focused and self-contained. Its `SKILL.md` should include the
skill's name and description in YAML front matter, explain when to use it, and
give the agent clear instructions about its boundaries and expected output.

CI runs two checks, both of which you can run locally:

- `ruby scripts/validate-skills.rb` checks that every skill folder has a
  `SKILL.md` whose front matter follows the Agent Skills spec: a lowercase,
  hyphenated `name` matching the folder, a non-empty `description` of at most
  1024 characters, and no unknown keys.
- `npx markdownlint-cli2 "**/*.md"` lints all markdown, using the config in
  `.markdownlint-cli2.jsonc`.
