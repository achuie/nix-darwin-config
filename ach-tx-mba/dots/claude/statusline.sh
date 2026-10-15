#!/bin/sh
# Claude Code statusLine, mirroring the achuie zsh prompt theme
# (dots/zsh/prompts/achuie.zsh): "[user@host dir (branch)+] model · ctx · cost".
# Managed by Nix -- edit dots/claude/statusline.sh and rebuild, do not edit
# the deployed ~/.claude/statusline.sh copy directly.

input=$(cat)

BLUE=$(printf '\033[34m')
RED=$(printf '\033[31m')
GREEN=$(printf '\033[32m')
DIM=$(printf '\033[2m')
RESET=$(printf '\033[0m')

user=$(whoami)
host=$(hostname -s 2>/dev/null || hostname)

if [ "$(id -u)" = "0" ]; then
  user_color="$RED"
else
  user_color="$BLUE"
fi

dir=$(printf '%s' "$input" | jq -r '.workspace.current_dir // .cwd // empty')
shortdir=""
if [ -n "$dir" ]; then
  if [ "$dir" = "$HOME" ]; then
    shortdir="~"
  else
    shortdir=$(basename "$dir")
  fi
fi

# Mirror vcs_info: green "(branch)" with a trailing "+" (stagedstr) when
# there are staged changes. Skipped entirely outside a repo or in detached
# HEAD (branch --show-current prints nothing), matching the prompt's
# behavior of only showing vcs_info_msg_0_ when it has content.
branch=""
staged=""
if [ -n "$dir" ]; then
  branch=$(git -C "$dir" --no-optional-locks branch --show-current 2>/dev/null)
  if [ -n "$branch" ]; then
    if ! git -C "$dir" --no-optional-locks diff --cached --quiet 2>/dev/null; then
      staged="+"
    fi
  fi
fi

model=$(printf '%s' "$input" | jq -r '.model.display_name // empty')
remaining=$(printf '%s' "$input" | jq -r '.context_window.remaining_percentage // empty')
cost=$(printf '%s' "$input" | jq -r '.cost.total_cost_usd // empty')

prompt="[${user_color}${user}@${host}${RESET}"
[ -n "$shortdir" ] && prompt="${prompt} ${shortdir}"
[ -n "$branch" ] && prompt="${prompt} ${GREEN}(${branch})${staged}${RESET}"
prompt="${prompt}]"

right=""
[ -n "$model" ] && right="${model}"
if [ -n "$remaining" ]; then
  right="${right}${right:+ · }$(printf '%.0f' "$remaining")%"
fi
if [ -n "$cost" ]; then
  right="${right}${right:+ · }\$$(printf '%.2f' "$cost")"
fi

if [ -n "$right" ]; then
  printf '%s %s%s%s' "$prompt" "$DIM" "$right" "$RESET"
else
  printf '%s' "$prompt"
fi
