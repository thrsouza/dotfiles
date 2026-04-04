#!/usr/bin/env bash

input=$(cat)

# --- Core fields ---
cwd=$(echo "$input"        | jq -r '.workspace.current_dir // .cwd // empty')
model=$(echo "$input"      | jq -r '.model.display_name // empty')
version=$(echo "$input"    | jq -r '.version // empty')
session=$(echo "$input"    | jq -r '.session_name // empty')

# --- Context window ---
used_pct=$(echo "$input"   | jq -r '.context_window.used_percentage // empty')

# --- Token counts ---
total_in=$(echo "$input"   | jq -r '.context_window.total_input_tokens // empty')
total_out=$(echo "$input"  | jq -r '.context_window.total_output_tokens // empty')

# --- Model ID (for pricing lookup) ---
model_id=$(echo "$input"   | jq -r '.model.id // empty')

# --- Output style ---
style=$(echo "$input"      | jq -r '.output_style.name // empty')

# --- Vim mode ---
vim_mode=$(echo "$input"   | jq -r '.vim.mode // empty')

# --- Agent ---
agent_name=$(echo "$input" | jq -r '.agent.name // empty')
agent_type=$(echo "$input" | jq -r '.agent.type // empty')

# --- Worktree ---
wt_name=$(echo "$input"    | jq -r '.worktree.name // empty')
wt_branch=$(echo "$input"  | jq -r '.worktree.branch // empty')

# --- Git branch (live, from cwd) ---
git_branch=""
if [ -n "$cwd" ]; then
  git_branch=$(GIT_DIR="$cwd/.git" GIT_WORK_TREE="$cwd" git --git-dir="$cwd/.git" \
    -c core.hooksPath=/dev/null rev-parse --abbrev-ref HEAD 2>/dev/null)
fi

# --- ANSI helpers ---
bold="\033[1m"
dim="\033[2m"
reset="\033[0m"
cyan="\033[36m"
yellow="\033[33m"
green="\033[32m"
magenta="\033[35m"
blue="\033[34m"
red="\033[31m"
claude_orange="\033[38;2;217;119;87m"

sep="${dim}|${reset}"

# ── Line 1: location + git + worktree + agent + vim ──────────────────────────
line1=""

# Directory
if [ -n "$cwd" ]; then
  short_cwd="${cwd/#$HOME/~}"
  line1+="📁 ${bold}${blue}${short_cwd}${reset}"
fi

# Git branch
if [ -n "$git_branch" ] && [ "$git_branch" != "HEAD" ]; then
  line1+=" ${sep} 🌿 ${green}${git_branch}${reset}"
fi

# Worktree
if [ -n "$wt_name" ]; then
  wt_display="${wt_name}"
  [ -n "$wt_branch" ] && wt_display+=" (${wt_branch})"
  line1+=" ${sep} 🌲 ${cyan}${wt_display}${reset}"
fi

# Agent
if [ -n "$agent_name" ]; then
  agent_display="${agent_name}"
  [ -n "$agent_type" ] && agent_display+=" (${agent_type})"
  line1+=" ${sep} 🤖 ${cyan}${agent_display}${reset}"
fi

# Vim mode
if [ -n "$vim_mode" ]; then
  vm_color="${green}"
  [ "$vim_mode" = "NORMAL" ] && vm_color="${yellow}"
  line1+=" ${sep} ⌨️  ${vm_color}${vim_mode}${reset}"
fi

# ── Line 2: model + context + tokens + cost + style + session ─────────────────
line2=""

# Model + version
if [ -n "$model" ]; then
  line2+="✨ ${claude_orange}${model}${reset}"
  [ -n "$version" ] && line2+=" ${dim}v${version}${reset}"
fi

# Context progress bar
if [ -n "$used_pct" ]; then
  used_int=${used_pct%.*}

  bar_color="${green}"
  if [ -n "$used_int" ] && [ "$used_int" -ge 64 ] 2>/dev/null; then
    bar_color="${red}"
  elif [ -n "$used_int" ] && [ "$used_int" -ge 36 ] 2>/dev/null; then
    bar_color="${yellow}"
  fi

  bar_width=10
  filled=$(awk "BEGIN {f=int(${used_int:-0}*${bar_width}/100); if(f>${bar_width})f=${bar_width}; print f}")
  empty=$((bar_width - filled))
  bar_filled=$(printf '%0.s█' $(seq 1 $filled))
  bar_empty=$(printf '%0.s░' $(seq 1 $empty))

  line2+=" ${sep} 🔋 ${dim}[${reset}${bar_color}${bar_filled}${reset}${dim}${bar_empty}]${reset}"
  line2+=" ${bar_color}${used_pct}%${reset}"
fi

# Token counts + estimated cost
if [ -n "$total_in" ] || [ -n "$total_out" ]; then
  in_k=$(awk "BEGIN {printf \"%.1f\", ${total_in:-0}/1000}")
  out_k=$(awk "BEGIN {printf \"%.1f\", ${total_out:-0}/1000}")
  line2+=" ${sep} 🔢 ${dim}in:${in_k}k out:${out_k}k${reset}"

  case "$model_id" in
    *claude-opus-4-6*|*claude-opus-4*)
      price_in="15"; price_out="75" ;;
    *claude-haiku-4-5*|*claude-haiku-4*)
      price_in="0.80"; price_out="4" ;;
    *) # claude-sonnet-4-6 and unknown models
      price_in="3"; price_out="15" ;;
  esac

  est_cost=$(awk "BEGIN {printf \"%.4f\", (${total_in:-0} * ${price_in} + ${total_out:-0} * ${price_out}) / 1000000}")
  line2+=" ${sep} 💰 ${yellow}~\$${est_cost}${reset}"
fi

# Output style
if [ -n "$style" ] && [ "$style" != "default" ]; then
  line2+=" ${sep} 🎨 ${yellow}${style}${reset}"
fi

# Session name
if [ -n "$session" ]; then
  line2+=" ${sep} 🏷️  ${dim}${session}${reset}"
fi

# ── Render ────────────────────────────────────────────────────────────────────
printf "%b\n%b\n" "$line1" "$line2"
