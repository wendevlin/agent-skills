#!/usr/bin/env ruby
# frozen_string_literal: true

# Validates every skills/<name>/SKILL.md against the Agent Skills spec.
# Run locally with: ruby scripts/validate-skills.rb

require "yaml"

ALLOWED_KEYS = %w[name description license allowed-tools metadata compatibility].freeze
NAME_PATTERN = /\A[a-z0-9]+(-[a-z0-9]+)*\z/
MAX_NAME_LENGTH = 64
MAX_DESCRIPTION_LENGTH = 1024

errors = []
skill_dirs = Dir.glob("skills/*").select { |path| File.directory?(path) }.sort
abort "No skill folders found under skills/" if skill_dirs.empty?

skill_dirs.each do |directory|
  path = File.join(directory, "SKILL.md")
  unless File.file?(path)
    errors << "#{directory}: missing SKILL.md"
    next
  end

  match = File.read(path).match(/\A---\s*\n(.*?)\n---\s*(?:\n|\z)/m)
  unless match
    errors << "#{path}: must start with YAML front matter"
    next
  end

  begin
    metadata = YAML.safe_load(match[1])
  rescue Psych::Exception => e
    errors << "#{path}: invalid YAML front matter (#{e.message})"
    next
  end

  unless metadata.is_a?(Hash)
    errors << "#{path}: front matter must be a mapping"
    next
  end

  unknown = metadata.keys - ALLOWED_KEYS
  errors << "#{path}: unknown front matter keys: #{unknown.join(', ')}" unless unknown.empty?

  name = metadata["name"]
  if !name.is_a?(String)
    errors << "#{path}: name is required"
  else
    errors << "#{path}: name '#{name}' must match folder '#{File.basename(directory)}'" if name != File.basename(directory)
    errors << "#{path}: name must be lowercase letters, digits and single hyphens" unless name.match?(NAME_PATTERN)
    errors << "#{path}: name must be at most #{MAX_NAME_LENGTH} characters" if name.length > MAX_NAME_LENGTH
  end

  description = metadata["description"]
  if !description.is_a?(String) || description.strip.empty?
    errors << "#{path}: description is required and must be non-empty"
  elsif description.length > MAX_DESCRIPTION_LENGTH
    errors << "#{path}: description is #{description.length} characters (max #{MAX_DESCRIPTION_LENGTH})"
  end
end

if errors.empty?
  puts "Validated #{skill_dirs.size} skill(s)."
else
  warn errors.map { |e| "error: #{e}" }
  exit 1
end
