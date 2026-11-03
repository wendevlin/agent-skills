# Agent skills

A collection of agent skills. Each skill lives in its own folder under
`skills/` and has a `SKILL.md` file. Add supporting files to that folder when
a skill needs them.

## Skills

- [`ha-frontend-pr-text`](skills/ha-frontend-pr-text/SKILL.md): Draft a Home
  Assistant frontend pull request title, body, and screenshot hint.

## Contributing

Keep each skill focused and self-contained. Its `SKILL.md` should include the
skill's name and description in YAML front matter, explain when to use it, and
give the agent clear instructions about its boundaries and expected output.

The GitHub Actions workflow validates that each skill folder contains a
`SKILL.md` with matching name metadata and a non-empty description.
