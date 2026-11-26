#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_SRC="$SCRIPT_DIR/SKILL.md"

if [[ ! -f "$SKILL_SRC" ]]; then
  echo "Error: SKILL.md not found in $SCRIPT_DIR" >&2
  exit 1
fi

install_skill() {
  local target_dir="$1"
  mkdir -p "$target_dir"
  cp "$SKILL_SRC" "$target_dir/SKILL.md"
  echo "Installed skill -> $target_dir/SKILL.md"
}

install_command() {
  local cmd_dir="$1"
  mkdir -p "$cmd_dir"
  cat >"$cmd_dir/ops-bro.md" <<'EOF'
---
description: Re-explain the last reply or pasted DevOps/infra text in plain human language with all technical facts intact.
---
Read and apply the `ops-bro` skill in `/ops-bro` translation mode to the previous assistant response (or the text below if provided). Keep all commands, flags, file paths, and error codes verbatim.

$ARGUMENTS
EOF
  echo "Installed slash command -> $cmd_dir/ops-bro.md"
}

installed_any=false

# Claude Code
if [[ -d "$HOME/.claude" ]] || command -v claude >/dev/null 2>&1; then
  install_skill "$HOME/.claude/skills/ops-bro"
  install_command "$HOME/.claude/commands"
  installed_any=true
fi

# Cursor
if [[ -d "$HOME/.cursor" ]] || command -v cursor >/dev/null 2>&1; then
  install_skill "$HOME/.cursor/skills/ops-bro"
  installed_any=true
fi

# OpenCode (note: singular `command`, not `commands`)
if [[ -d "$HOME/.config/opencode" ]] || command -v opencode >/dev/null 2>&1; then
  install_skill "$HOME/.config/opencode/skills/ops-bro"
  install_command "$HOME/.config/opencode/command"
  installed_any=true
fi

# OpenAI Codex
if [[ -d "$HOME/.codex" ]] || command -v codex >/dev/null 2>&1; then
  install_skill "$HOME/.codex/skills/ops-bro"
  installed_any=true
fi

# Hermes Agent
if [[ -d "$HOME/.hermes" ]]; then
  install_skill "$HOME/.hermes/skills/ops-bro"
  installed_any=true
fi

if [[ "$installed_any" == false ]]; then
  echo "No supported agent directories found. Installed nothing." >&2
  echo "Supported: Claude Code (~/.claude), Cursor (~/.cursor), OpenCode (~/.config/opencode), Codex (~/.codex), Hermes (~/.hermes)" >&2
  exit 1
fi

echo "Done. Restart your agent session and use /ops-bro anytime."
