#!/usr/bin/env bash
# Copy the named skills from this repo into ~/.claude/skills.
#
# Usage: scripts/install-skills.sh <skill> [<skill> ...]
# Example: scripts/install-skills.sh work-on-task ha-frontend-pr-text
#
# Existing skills with the same name are replaced. Unknown names are
# reported and skipped. Always exits 0 so a cloud session can still start.

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
target="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"

if [ "$#" -eq 0 ]; then
  echo "usage: $0 <skill> [<skill> ...]" >&2
  echo "available: $(ls "$repo_dir/skills" | tr '\n' ' ')" >&2
  exit 0
fi

mkdir -p "$target"
for skill in "$@"; do
  source_dir="$repo_dir/skills/$skill"
  if [ ! -f "$source_dir/SKILL.md" ]; then
    echo "skill not found: $skill" >&2
    continue
  fi
  rm -rf "${target:?}/$skill"
  cp -r "$source_dir" "$target/"
  echo "installed: $skill -> $target/$skill"
done
exit 0
