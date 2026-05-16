#!/usr/bin/env bash
# release.sh — create a release only if git tag matches SKILL.md version
set -e

TAG="${1:-}"

if [[ -z "$TAG" ]]; then
  echo "Usage: ./release.sh v1.4.0" >&2
  exit 1
fi

SKILL_VERSION="v$(grep '^version:' SKILL.md | awk '{print $2}')"

if [[ "$TAG" != "$SKILL_VERSION" ]]; then
  echo "❌ Tag '$TAG' doesn't match SKILL.md version '$SKILL_VERSION'" >&2
  echo "   Update version: in SKILL.md first, then re-run." >&2
  exit 1
fi

echo "✅ Tag matches SKILL.md version ($SKILL_VERSION)"
echo "   Creating release $TAG..."
