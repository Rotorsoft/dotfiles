#!/usr/bin/env bash
set -euo pipefail

CONFIG_DIR="$HOME/.dotfiles/nvim"
PARSERS_DIR="$CONFIG_DIR/parsers"
QUERIES_DIR="$CONFIG_DIR/queries"
SRC_DIR="$PARSERS_DIR/sources"
mkdir -p "$PARSERS_DIR" "$QUERIES_DIR" "$SRC_DIR"

ensure_repo() {
  local repo="$1"
  local name="$2"
  local path="$SRC_DIR/$name"

  if [[ ! -d "$path" ]]; then
    echo "Cloning $repo → $path"
    git clone --depth 1 "$repo" "$path"
  else
    echo "Updating $name ..."
    git -C "$path" pull --ff-only
  fi
}

build_parser() {
  local path="$1"
  local lang="$2"
  local subpath="${3:-}"
  local target="$PARSERS_DIR/$lang.so"

  cd "$path"
  echo "Installing dependencies for $lang ..."
  npm install

  echo "Building parser for $lang ..."
  if [[ -n "$subpath" ]]; then
    cd "$subpath"
  fi
  tree-sitter generate

  cc -fPIC -I./src -c src/parser.c -o parser.o
  if [[ -f src/scanner.c ]]; then
    cc -fPIC -I./src -c src/scanner.c -o scanner.o
    cc -shared parser.o scanner.o -o "$target"
  else
    cc -shared parser.o -o "$target"
  fi
  echo "→ Installed $lang.so to $PARSERS_DIR"
  rm -f parser.o scanner.o || true

  # copy queries
  mkdir -p "$QUERIES_DIR/$lang"
  cd "$path"
  cp -r ./queries/* "$QUERIES_DIR/$lang"
  echo "→ Copied queries to $QUERIES_DIR/$lang"

  cd - >/dev/null
}

# --- Ensure repos ---
ensure_repo https://github.com/tree-sitter/tree-sitter-javascript tree-sitter-javascript
ensure_repo https://github.com/tree-sitter/tree-sitter-typescript tree-sitter-typescript
ensure_repo https://github.com/tree-sitter/tree-sitter-html tree-sitter-html
ensure_repo https://github.com/tree-sitter/tree-sitter-json tree-sitter-json

# --- Build parsers ---
build_parser "$SRC_DIR/tree-sitter-javascript" javascript
build_parser "$SRC_DIR/tree-sitter-typescript" typescript typescript
build_parser "$SRC_DIR/tree-sitter-typescript" tsx tsx
build_parser "$SRC_DIR/tree-sitter-html" html
build_parser "$SRC_DIR/tree-sitter-json" json

echo "✅ All parsers built successfully!"
