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
fail() { echo -e "  \033[31m❌ $1\033[0m"; exit 1; }

sync_project() {
  local project_path="$1"
  local project_name="$2"
  local doc_path="$project_path/.document"

  step "Sync $project_name/.document..."
  cd "$project_path"
  git submodule update --remote --force .document || fail "Submodule update thất bại cho $project_name"

  if [ -n "$(git status --porcelain .document)" ]; then
    git add .document
    git commit -m "chore: update docs submodule"
    ok "$project_name synced"
  else
    ok "$project_name đã up-to-date"
  fi
}

echo -e "\n\033[36m📚 Sync docs từ reader-docs\033[0m"

# 1. Commit & push reader-docs
step "Commit & push reader-docs..."
cd "$ROOT"
git add -A
if [ -n "$(git status --porcelain)" ]; then
  git commit -m "$MSG"
  git pull --rebase || fail "Pull rebase thất bại, cần resolve conflicts thủ công"
  git push || fail "Push thất bại"
  ok "reader-docs pushed"
else
  ok "Không có thay đổi"
  exit 0
fi

# 2. Sync cả 2 project
sync_project "$BE" "be-reader"
sync_project "$FE" "fe-reader"

echo -e "\n\033[32m🎉 Done!\033[0m\n"
