#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
dist_dir="$repo_root/dist"
archive_path="$dist_dir/touch-auth.tar.gz"
staging_dir="$(mktemp -d)"

cleanup() {
  rm -rf "$staging_dir"
}

trap cleanup EXIT

cd "$repo_root"

make universal_app
mkdir -p "$dist_dir"

cp "$repo_root/touch-auth" "$staging_dir/touch-auth"
cp "$repo_root/touch-auth.plist" "$staging_dir/touch-auth.plist"

tar -czf "$archive_path" -C "$staging_dir" touch-auth touch-auth.plist
shasum -a 256 "$archive_path"
