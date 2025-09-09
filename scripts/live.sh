#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"
cd "$ROOT_DIR"

usage() {
  cat <<'USAGE'
Usage: scripts/live.sh <command>

Commands:
  dev             Run local preview (Hugo + Decap CMS proxy)
  build           Build production site to public/
  deploy-gh       Deploy to GitHub Pages (gh-pages branch)
  deploy-netlify  Deploy to Netlify using Netlify CLI

Examples:
  bash scripts/live.sh dev
  bash scripts/live.sh deploy-gh
USAGE
}

need_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Error: required command '$1' not found." >&2
    exit 1
  fi
}

dev() {
  need_cmd hugo
  echo "Starting local Decap CMS proxy (no login) and Hugo server..."
  echo "- CMS: http://localhost:1313/admin"
  echo "- Site: http://localhost:1313/"
  echo "Press Ctrl+C to stop."

  # Start CMS proxy in background using npx (downloads if needed)
  if command -v npx >/dev/null 2>&1; then
    npx decap-server >/dev/null 2>&1 &
    CMS_PID=$!
  else
    echo "Warning: npx not found, skipping CMS proxy. Edit via files or install Node.js." >&2
    CMS_PID=0
  fi

  trap '[[ $CMS_PID -ne 0 ]] && kill $CMS_PID || true' INT TERM EXIT
  hugo server -D
}

build() {
  need_cmd hugo
  echo "Building production site (minified) to ./public ..."
  hugo --minify
  echo "Done: public/"
}

deploy_gh() {
  need_cmd git
  need_cmd hugo

  BRANCH="gh-pages"
  WORKTREE_DIR=".gh-pages"

  echo "Building site..."
  hugo --minify

  echo "Preparing worktree $WORKTREE_DIR on branch $BRANCH ..."
  if [ -d "$WORKTREE_DIR" ]; then
    git worktree remove --force "$WORKTREE_DIR" || true
  fi
  git fetch origin "$BRANCH" || true
  git worktree add -B "$BRANCH" "$WORKTREE_DIR" "origin/$BRANCH" 2>/dev/null || git worktree add -B "$BRANCH" "$WORKTREE_DIR"

  echo "Publishing contents of public/ to $BRANCH ..."
  rsync -a --delete public/ "$WORKTREE_DIR"/
  pushd "$WORKTREE_DIR" >/dev/null
  git add -A
  COMMIT_MSG="Publish $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  if ! git diff --cached --quiet; then
    git commit -m "$COMMIT_MSG"
    git push -u origin "$BRANCH"
    echo "Deployed to GitHub Pages (branch $BRANCH)."
  else
    echo "No changes to deploy."
  fi
  popd >/dev/null
}

deploy_netlify() {
  need_cmd hugo
  if ! command -v npx >/dev/null 2>&1; then
    echo "Error: npx not found. Install Node.js to use Netlify CLI via npx" >&2
    exit 1
  fi
  echo "Building site..."
  hugo --minify
  echo "Deploying to Netlify (prod)..."
  npx netlify-cli deploy --dir=public --prod
}

cmd="${1:-}"
case "$cmd" in
  dev) dev ;;
  build) build ;;
  deploy-gh) deploy_gh ;;
  deploy-netlify) deploy_netlify ;;
  -h|--help|help|"" ) usage ;;
  *) echo "Unknown command: $cmd" >&2; usage; exit 1 ;;
esac

