#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_DIR="$REPO_DIR/skills"
TARGET_DIR="${SKILLS_DIR:-$HOME/.agents/skills}"
FORCE=0
PRUNE=0

usage() {
  cat <<EOF
Usage: $(basename "$0") [--force] [--prune]

Symlink each skill directory under $SOURCE_DIR into $TARGET_DIR.

  --force   Replace an existing symlink at the destination. Real directories
            are NEVER touched, with or without --force.
  --prune   Remove symlinks inside $TARGET_DIR that point into this repo but
            have no matching source under $SOURCE_DIR.
  -h        Show this help.

Environment:
  SKILLS_DIR   Target skills directory (default: ~/.agents/skills)
EOF
}

while (($#)); do
  case "$1" in
    --force) FORCE=1 ;;
    --prune) PRUNE=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

mkdir -p "$TARGET_DIR"

linked=0
skipped=0

for dir in "$SOURCE_DIR"/*/; do
  [ -d "$dir" ] || continue
  name="$(basename "$dir")"
  target="$TARGET_DIR/$name"

  if [ -L "$target" ] || [ -e "$target" ]; then
    if [ -d "$target" ] && [ ! -L "$target" ]; then
      echo "skip: $target is a real directory (not touching it)" >&2
      skipped=$((skipped + 1))
      continue
    fi
    if [ "$FORCE" -eq 0 ]; then
      echo "skip: $target already exists (use --force to replace a symlink)" >&2
      skipped=$((skipped + 1))
      continue
    fi
    rm -f "$target"
  fi

  ln -s "$dir" "$target"
  echo "linked: $name -> $target"
  linked=$((linked + 1))
done

pruned=0
if [ "$PRUNE" -eq 1 ]; then
  for target in "$TARGET_DIR"/*; do
    [ -L "$target" ] || continue
    dest="$(readlink "$target")"
    case "$dest" in
      "$SOURCE_DIR"/*)
        name="$(basename "$target")"
        if [ ! -e "$SOURCE_DIR/$name" ]; then
          rm -f "$target"
          echo "pruned: $target (no source under $SOURCE_DIR)" >&2
          pruned=$((pruned + 1))
        fi
        ;;
    esac
  done
fi

echo "done: linked=$linked skipped=$skipped pruned=$pruned"
