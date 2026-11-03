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

CI runs two checks, both of which you can run locally:

- `ruby scripts/validate-skills.rb` checks that every skill folder has a
  `SKILL.md` whose front matter follows the Agent Skills spec: a lowercase,
  hyphenated `name` matching the folder, a non-empty `description` of at most
  1024 characters, and no unknown keys.
- `npx markdownlint-cli2 "**/*.md"` lints all markdown, using the config in
  `.markdownlint-cli2.jsonc`.
