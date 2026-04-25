#!/usr/bin/env bash
set -euo pipefail

: "${HOMEBREW_FORMULA_PATH:?HOMEBREW_FORMULA_PATH is required}"
: "${RELEASE_VERSION:?RELEASE_VERSION is required}"
: "${RELEASE_ASSET_URL:?RELEASE_ASSET_URL is required}"
: "${RELEASE_SHA256:?RELEASE_SHA256 is required}"
: "${HOMEPAGE_URL:?HOMEPAGE_URL is required}"

ruby - "$HOMEBREW_FORMULA_PATH" "$HOMEPAGE_URL" "$RELEASE_ASSET_URL" "$RELEASE_SHA256" <<'RUBY'
formula_path, homepage, url, sha256 = ARGV
contents = File.read(formula_path)

replacements = {
  /^\s*homepage ".*"$/ => %{  homepage "#{homepage}"},
  /^\s*url ".*"$/ => %{  url "#{url}"},
  /^\s*sha256 ".*"$/ => %{  sha256 "#{sha256}"}
}

replacements.each do |pattern, replacement|
  unless contents.match?(pattern)
    abort("Missing #{pattern.inspect} in #{formula_path}")
  end

  contents.gsub!(pattern, replacement)
end

File.write(formula_path, contents)
RUBY

echo "Updated $HOMEBREW_FORMULA_PATH for $RELEASE_VERSION"
