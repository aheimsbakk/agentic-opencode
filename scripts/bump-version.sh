#!/usr/bin/env bash
set -euo pipefail

VERSION_FILE="VERSION"

if [ ! -f "$VERSION_FILE" ]; then
  echo "v0.0.0" >"$VERSION_FILE"
fi

RAW_VERSION=$(tr -d 'v' <"$VERSION_FILE")
read -r MAJOR MINOR PATCH < <(tr '.' ' ' <<<"$RAW_VERSION")

case "${1:-}" in
major)
  MAJOR=$((MAJOR + 1))
  MINOR=0
  PATCH=0
  ;;
minor)
  MINOR=$((MINOR + 1))
  PATCH=0
  ;;
patch)
  PATCH=$((PATCH + 1))
  ;;
*)
  echo "Usage: $0 {patch|minor|major}"
  exit 1
  ;;
esac

NEW_VERSION="v${MAJOR}.${MINOR}.${PATCH}"
echo "$NEW_VERSION" >"$VERSION_FILE"
echo "$NEW_VERSION"
