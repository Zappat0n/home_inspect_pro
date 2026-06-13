# frozen_string_literal: true

# Flags use of `data: { testid: "..." }` hash syntax in favor of
# the direct `"data-testid": "..."` HTML attribute key.
class ERBLint::Linters::NoDataTestidHash < ERBLint::Linter
  include ERBLint::LinterRegistry

  FULL_HASH_PATTERN = /data:\s*\{[^}]*\btestid:[^}]*\}/
  SIMPLE_PATTERN = /data:\s*\{\s*testid:\s*("[^"]*"|'[^']*')\s*\}/

  def run(processed_source)
    content = processed_source.file_content

    content.scan(FULL_HASH_PATTERN) do
      match = Regexp.last_match
      add_offense(
        processed_source.to_source_range(match.begin(0)...match.end(0)),
        "Use `'data-testid': \"...\"` instead of `data: { testid: \"...\" }`.",
      )
    end
  end

  def autocorrect(_processed_source, offense)
    lambda do |corrector|
      original = offense.source_range.source

      if (match = original.match(SIMPLE_PATTERN))
        replacement = "'data-testid': #{match[1]}"
        corrector.replace(offense.source_range, replacement)
      end
    end
  end
end
