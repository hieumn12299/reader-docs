#!/bin/bash
# Sync docs từ reader-docs → push → sync cả be-reader & fe-reader
# Usage: ./sync-docs.sh
#        ./sync-docs.sh "docs: add API reference"

MSG="${1:-docs: update}"
ROOT="$(cd "$(dirname "$0")" && pwd)"
PARENT="$(dirname "$ROOT")"
BE="$PARENT/be-reader"
FE="$PARENT/fe-reader"

ok()   { echo -e "  \033[32m✅ $1\033[0m"; }
step() { echo -e "  \033[33m→ $1\033[0m"; }

echo -e "\n\033[36m📚 Sync docs từ reader-docs\033[0m"

# 1. Commit & push reader-docs
step "Commit & push reader-docs..."
cd "$ROOT"
git add -A
if [ -n "$(git status --porcelain)" ]; then
  git commit -m "$MSG"
  git push
  ok "reader-docs pushed"
else
  ok "Không có thay đổi"
  exit 0
fi

# 2. Sync be-reader
step "Sync be-reader/.document..."
cd "$BE"
git submodule update --remote .document
if [ -n "$(git status --porcelain .document)" ]; then
  git add .document
  git commit -m "chore: update docs submodule"
  ok "be-reader synced"
else
  ok "be-reader đã up-to-date"
fi

# 3. Sync fe-reader
step "Sync fe-reader/.document..."
cd "$FE"
git submodule update --remote .document
if [ -n "$(git status --porcelain .document)" ]; then
  git add .document
  git commit -m "chore: update docs submodule"
  ok "fe-reader synced"
else
  ok "fe-reader đã up-to-date"
fi

echo -e "\n\033[32m🎉 Done!\033[0m\n"
