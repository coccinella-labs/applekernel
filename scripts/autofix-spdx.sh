#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2025 KERNEL.METAL (coccinella-labs)

# autofix-spdx.sh
# Adds SPDX header to files that are missing it. Use with caution.

set -euo pipefail

META_FILE="project.meta.json"
if [ ! -f "$META_FILE" ]; then
  echo "Missing $META_FILE"
  exit 1
fi

SPDX=$(jq -r '.spdx' $META_FILE)
COPYRIGHT=$(jq -r '.copyright' $META_FILE)

# file patterns to operate on
PATTERNS=("**/*.ts" "**/*.tsx" "**/*.js" "**/*.jsx" "**/*.py" "**/*.c" "**/*.cpp" "**/*.h" "**/*.go" "**/*.rs" "**/*.java" "**/*.rb")

# We'll only modify files that do not already contain the SPDX identifier.
changed=()
for p in "${PATTERNS[@]}"; do
  for f in $(git ls-files $p || true); do
    if [ -z "$f" ]; then continue; fi
    if grep -q "$SPDX" "$f"; then
      continue
    fi
    # Insert header at top
    echo "Patching $f"
    tmp=$(mktemp)
    echo "// SPDX-License-Identifier: $SPDX" > $tmp
    echo "// $COPYRIGHT" >> $tmp
    echo "" >> $tmp
    cat "$f" >> $tmp
    mv $tmp "$f"
    git add "$f"
    changed+=($f)
  done
done

if [ ${#changed[@]} -eq 0 ]; then
  echo "Nothing to fix"
  exit 0
fi

# Commit and push to the current branch
BRANCH=${GITHUB_HEAD_REF:-$(git rev-parse --abbrev-ref HEAD)}

msg="chore(spdx): add SPDX headers to ${#changed[@]} files"

git commit -m "$msg"

echo "Files patched: ${changed[*]}"

echo "To push the autofix commit, run: git push origin $BRANCH"