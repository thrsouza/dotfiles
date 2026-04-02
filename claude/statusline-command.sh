#!/usr/bin/env bash
# Claude Code statusLine command
# Line 1: ~/path/to/dir  git branch
# Line 2: model  context progress bar  cost

input=$(cat)

# --- Directory ---
cwd=$(echo "$input" | jq -r '.cwd // .workspace.current_dir // empty')
home="$HOME"
tilde='~'
if [ -n "$home" ] && [ -n "$cwd" ]; then
  dir="${cwd/#$home/$tilde}"
else
  dir="${cwd:-~}"
fi
dir_part="📂 \033[36m${dir}\033[0m"

# --- Git branch ---
branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null \
         || git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
if [ -n "$branch" ]; then
  branch_part="  🌿 \033[32m${branch}\033[0m"
else
  branch_part=""
fi

# --- Model ---
model=$(echo "$input" | jq -r '.model.display_name // empty')
if [ -n "$model" ]; then
  model_part="✨ \033[38;2;204;120;92m${model}\033[0m"
else
  model_part=""
fi

# --- Context usage: colored progress bar ---
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
reset="\033[0m"
if [ -n "$used_pct" ]; then
  pct_int=$(printf '%.0f' "$used_pct")
  filled=$(( (pct_int * 10 + 50) / 100 ))
  [ "$filled" -gt 10 ] && filled=10
  empty=$(( 10 - filled ))

  if [ "$pct_int" -lt 40 ]; then
    color="\033[32m"   # green
  elif [ "$pct_int" -lt 65 ]; then
    color="\033[33m"   # yellow
  else
    color="\033[31m"   # red
  fi

  bar=""
  for ((i=0; i<filled; i++)); do bar="${bar}▰"; done
  for ((i=0; i<empty; i++));  do bar="${bar}▱"; done

  context_part="  🔋 ${color}${bar} ${pct_int}%${reset}"
else
  # No data yet (before first API response): omit the context bar entirely
  context_part=""
fi

# --- Estimated cost (USD) ---
# Pricing (per 1M tokens, claude-sonnet-4 tier as baseline):
#   Input (uncached): $3.00   Output: $15.00
#   Cache write:      $3.75   Cache read: $0.30
total_input=$(echo "$input"  | jq -r '.context_window.total_input_tokens  // 0')
total_output=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
cache_write=$(echo "$input"  | jq -r '.context_window.current_usage.cache_creation_input_tokens // 0')
cache_read=$(echo "$input"   | jq -r '.context_window.current_usage.cache_read_input_tokens     // 0')

cost=$(awk -v ti="$total_input" -v to="$total_output" \
           -v cw="$cache_write" -v cr="$cache_read" \
       'BEGIN {
         cost = (ti / 1000000 * 3.00) \
              + (to / 1000000 * 15.00) \
              + (cw / 1000000 * 3.75) \
              + (cr / 1000000 * 0.30);
         printf "%.4f", cost
       }')

if [ -n "$total_input" ] && [ "$total_input" != "0" ]; then
  cost_part="  💰 \033[33m\$${cost}\033[0m"
else
  cost_part=""
fi

# --- Render two lines ---
# Line 1: ~/path/to/dir  git branch
# Line 2: model  context bar  cost
line1="${dir_part}${branch_part}"
line2="${model_part}${context_part}${cost_part}"

printf '%b\n' "$line1"
if [ -n "$line2" ]; then
  printf '%b\n' "$line2"
else
  printf "...\n"
fi
