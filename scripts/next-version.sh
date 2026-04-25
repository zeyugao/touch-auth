#!/usr/bin/env bash
set -euo pipefail

bump="${1:-patch}"

case "$bump" in
  patch|minor|major)
    ;;
  *)
    echo "Usage: $0 [patch|minor|major]" >&2
    exit 1
    ;;
esac

major=0
minor=0
patch=0
found_version=0

while IFS= read -r tag; do
  normalized_tag="${tag#v}"
  IFS=. read -r tag_major tag_minor tag_patch extra <<<"$normalized_tag"

  if [[ -z "${tag_major:-}" || -n "${extra:-}" ]]; then
    continue
  fi

  tag_minor="${tag_minor:-0}"
  tag_patch="${tag_patch:-0}"

  if [[ ! "$tag_major" =~ ^[0-9]+$ || ! "$tag_minor" =~ ^[0-9]+$ || ! "$tag_patch" =~ ^[0-9]+$ ]]; then
    continue
  fi

  if (( found_version == 0 )) ||
     (( tag_major > major )) ||
     (( tag_major == major && tag_minor > minor )) ||
     (( tag_major == major && tag_minor == minor && tag_patch > patch )); then
    major="$tag_major"
    minor="$tag_minor"
    patch="$tag_patch"
    found_version=1
  fi
done < <(git tag --list)

case "$bump" in
  patch)
    patch=$((patch + 1))
    ;;
  minor)
    minor=$((minor + 1))
    patch=0
    ;;
  major)
    major=$((major + 1))
    minor=0
    patch=0
    ;;
esac

printf "%s.%s.%s\n" "$major" "$minor" "$patch"
