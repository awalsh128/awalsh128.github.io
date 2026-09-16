#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

MODE="${1:-serve}"
PORT="${PORT:-4000}"
HOST="${HOST:-127.0.0.1}"

export BUNDLE_PATH="${ROOT_DIR}/.bundle/vendor"
export BUNDLE_APP_CONFIG="${ROOT_DIR}/.bundle"
export BUNDLE_CACHE_PATH="${ROOT_DIR}/.bundle/cache"

ensure_prereqs() {
  if command -v ruby >/dev/null 2>&1 && command -v bundle >/dev/null 2>&1; then
    return 0
  fi

  if ! command -v apt-get >/dev/null 2>&1; then
    echo "Ruby/Bundler is not installed and apt-get is unavailable on this system."
    exit 1
  fi

  echo "Ruby/Bundler not found. Installing via apt-get..."

  SUDO=""
  if [ "$(id -u)" -ne 0 ]; then
    if command -v sudo >/dev/null 2>&1; then
      SUDO="sudo"
    else
      echo "This machine needs root or sudo to install Ruby/Bundler via apt."
      exit 1
    fi
  fi

  $SUDO apt-get update

  if ! $SUDO DEBIAN_FRONTEND=noninteractive apt-get install -y ruby-full build-essential bundler; then
    echo "Initial apt installation failed. Attempting to repair broken package state..."
    $SUDO DEBIAN_FRONTEND=noninteractive apt --fix-broken install -y || true
    $SUDO DEBIAN_FRONTEND=noninteractive apt-get install -y ruby-full build-essential bundler
  fi

  if ! command -v ruby >/dev/null 2>&1 || ! command -v bundle >/dev/null 2>&1; then
    echo "Ruby/Bundler installation failed."
    exit 1
  fi
}

bundle_install_if_needed() {
  mkdir -p "${ROOT_DIR}/.bundle" "${ROOT_DIR}/.bundle/cache"
  bundle config set --local path "${ROOT_DIR}/.bundle/vendor"
  bundle config set --local cache_path "${ROOT_DIR}/.bundle/cache"
  bundle config set --local jobs 4
  bundle config set --local retry 3

  if bundle check >/dev/null 2>&1; then
    echo "Ruby gem dependencies are already satisfied."
    return 0
  fi

  echo "Installing Ruby gem dependencies into ${ROOT_DIR}/.bundle/vendor..."
  bundle install --jobs 4 --retry 3
}

ensure_prereqs
bundle_install_if_needed

case "$MODE" in
  serve)
    echo "Starting local Jekyll preview at http://${HOST}:${PORT}"
    bundle exec jekyll serve \
      --host "$HOST" \
      --port "$PORT" \
      --livereload \
      --drafts \
      --future \
      --unpublished
    ;;
  build)
    echo "Building site locally to _site-local"
    rm -rf "_site-local"
    bundle exec jekyll build --destination _site-local
    echo "Built successfully. Output is in ${ROOT_DIR}/_site-local"
    ;;
  *)
    echo "Usage: $0 [serve|build]"
    echo "  serve  -> run a local preview server (default)"
    echo "  build  -> produce a local static build without deploying"
    exit 1
    ;;
esac
