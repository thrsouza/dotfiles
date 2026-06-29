#!/usr/bin/env bash
#
# Kowalski — complete status line for the Claude Code interface.
#
# Claude Code pipes a JSON session payload on stdin and renders whatever this
# script prints to stdout at the bottom of the TUI. Each printed line becomes one
# status row. See https://code.claude.com/docs/en/statusline.
#
# Wire it up in settings.json (see README / the plugin docs):
#   "statusLine": { "type": "command", "command": "/abs/path/scripts/statusline.sh", "padding": 0 }
#
# Dependencies: jq (required for full output; degrades to a minimal line without it).

set -uo pipefail

input="$(cat)"

# ---------------------------------------------------------------------------
# Colors. Disabled automatically when output is not a styled context or when
# NO_COLOR is set (https://no-color.org).
# ---------------------------------------------------------------------------
if [[ -n "${NO_COLOR:-}" ]]; then
  C_RESET=""; C_DIM=""; C_BOLD=""
  C_MODEL=""; C_DIR=""; C_GIT=""; C_GIT_DIRTY=""; C_CTX=""; C_CTX_WARN=""
  C_COST=""; C_ADD=""; C_DEL=""; C_RL=""; C_PR=""; C_SEP=""; C_ACCENT=""
else
  C_RESET=$'\033[0m'; C_DIM=$'\033[2m'; C_BOLD=$'\033[1m'
  C_MODEL=$'\033[38;5;75m'      # blue
  C_DIR=$'\033[38;5;180m'       # tan
  C_GIT=$'\033[38;5;114m'       # green
  C_GIT_DIRTY=$'\033[38;5;215m' # orange
  C_CTX=$'\033[38;5;141m'       # purple
  C_CTX_WARN=$'\033[38;5;203m'  # red
  C_COST=$'\033[38;5;108m'      # muted green
  C_ADD=$'\033[38;5;114m'       # green
  C_DEL=$'\033[38;5;203m'       # red
  C_RL=$'\033[38;5;245m'        # gray
  C_PR=$'\033[38;5;176m'        # magenta
  C_SEP=$'\033[38;5;240m'       # dim gray
  C_ACCENT=$'\033[38;5;250m'    # light gray
fi

SEP=" ${C_SEP}│${C_RESET} "

# ---------------------------------------------------------------------------
# Fallback when jq is unavailable: print a single bare line and exit.
# ---------------------------------------------------------------------------
if ! command -v jq >/dev/null 2>&1; then
  cwd="$(printf '%s' "$input" | sed -n 's/.*"current_dir":"\([^"]*\)".*/\1/p')"
  printf '%s%s%s (install jq for full status line)\n' "$C_DIR" "${cwd##*/}" "$C_RESET"
  exit 0
fi

# ---------------------------------------------------------------------------
# Extract every field we care about in one jq pass, one value per line. We use
# newline (not @tsv) because bash collapses consecutive tabs when IFS is
# whitespace, which would silently shift all fields after an empty one. mapfile
# preserves empty lines, so optional fields stay aligned by index.
# ---------------------------------------------------------------------------
mapfile -t F < <(printf '%s' "$input" | jq -r '
  [
    .model.display_name // "Claude",
    .output_style.name // "",
    .effort.level // "",
    (.thinking.enabled // false),
    (.workspace.current_dir // .cwd // ""),
    (.workspace.project_dir // ""),
    (.worktree.name // ""),
    (.worktree.branch // ""),
    (.context_window.used_percentage // ""),
    (.context_window.context_window_size // ""),
    (.context_window.total_input_tokens // ""),
    (.exceeds_200k_tokens // false),
    (.cost.total_cost_usd // ""),
    (.cost.total_duration_ms // ""),
    (.cost.total_lines_added // ""),
    (.cost.total_lines_removed // ""),
    (.rate_limits.five_hour.used_percentage // ""),
    (.rate_limits.seven_day.used_percentage // ""),
    (.pr.number // ""),
    (.pr.review_state // ""),
    (.vim.mode // "")
  ] | .[] | tostring')

model="${F[0]}";        output_style="${F[1]}"; effort="${F[2]}";       thinking="${F[3]}"
current_dir="${F[4]}";  project_dir="${F[5]}";  worktree_name="${F[6]}"; worktree_branch="${F[7]}"
ctx_pct="${F[8]}";      ctx_size="${F[9]}";     ctx_in="${F[10]}";       exceeds_200k="${F[11]}"
cost_usd="${F[12]}";    dur_ms="${F[13]}";      lines_add="${F[14]}";    lines_del="${F[15]}"
rl_5h="${F[16]}";       rl_7d="${F[17]}"
pr_number="${F[18]}";   pr_state="${F[19]}"
vim_mode="${F[20]}"

# ---------------------------------------------------------------------------
# Helpers.
# ---------------------------------------------------------------------------

# Round a float to the nearest integer.
round() { printf '%.0f' "$1" 2>/dev/null || echo 0; }

# Compact token counts: 12345 -> 12.3k, 1500000 -> 1.5M.
human_tokens() {
  local n="$1"
  [[ -z "$n" || "$n" == "null" ]] && { echo ""; return; }
  awk -v n="$n" 'BEGIN{
    if (n>=1000000) printf "%.1fM", n/1000000;
    else if (n>=1000) printf "%.1fk", n/1000;
    else printf "%d", n;
  }'
}

# Milliseconds -> 1h2m, 3m4s, 12s.
human_duration() {
  local ms="$1"
  [[ -z "$ms" || "$ms" == "null" ]] && { echo ""; return; }
  awk -v ms="$ms" 'BEGIN{
    s=int(ms/1000); h=int(s/3600); m=int((s%3600)/60); sec=s%60;
    if (h>0) printf "%dh%dm", h, m;
    else if (m>0) printf "%dm%ds", m, sec;
    else printf "%ds", sec;
  }'
}

# A 10-cell progress bar for a 0-100 percentage.
ctx_bar() {
  local pct="$1" filled i out=""
  filled=$(round "$(awk -v p="$pct" 'BEGIN{print p/10}')")
  (( filled < 0 )) && filled=0; (( filled > 10 )) && filled=10
  for ((i=0; i<10; i++)); do
    if (( i < filled )); then out+="█"; else out+="░"; fi
  done
  printf '%s' "$out"
}

# ---------------------------------------------------------------------------
# Row 1 — identity & location: model · effort · thinking · dir · git.
# ---------------------------------------------------------------------------
row1="${C_MODEL}${C_BOLD}✨ ${model}${C_RESET}"

[[ -n "$output_style" && "$output_style" != "default" && "$output_style" != "null" ]] && \
  row1+="${SEP}${C_ACCENT}${output_style}${C_RESET}"

if [[ -n "$effort" && "$effort" != "null" ]]; then
  row1+="${SEP}${C_DIM}💪 effort:${C_RESET}${C_ACCENT}${effort}${C_RESET}"
fi

[[ "$thinking" == "true" ]] && row1+="${SEP}${C_ACCENT}💭 thinking${C_RESET}"

# Directory: show path relative to the project root when nested inside it.
dir_label="${current_dir##*/}"
if [[ -n "$project_dir" && "$project_dir" != "null" && "$current_dir" == "$project_dir"/* ]]; then
  dir_label="${project_dir##*/}/${current_dir#"$project_dir"/}"
fi
row1+="${SEP}${C_DIR}📁 ${dir_label:-?}${C_RESET}"

# Git: branch, dirty/staged markers, ahead/behind vs upstream.
if git_root="$(cd "$current_dir" 2>/dev/null && git rev-parse --show-toplevel 2>/dev/null)"; then
  branch="$(cd "$current_dir" && git symbolic-ref --short -q HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)"
  git_color="$C_GIT"; marks=""
  if ! (cd "$current_dir" && git diff --quiet --ignore-submodules HEAD 2>/dev/null); then
    git_color="$C_GIT_DIRTY"; marks+="●"   # unstaged/working changes
  fi
  if ! (cd "$current_dir" && git diff --cached --quiet --ignore-submodules 2>/dev/null); then
    git_color="$C_GIT_DIRTY"; marks+="+"   # staged changes
  fi
  # Untracked files present?
  if [[ -n "$(cd "$current_dir" && git ls-files --others --exclude-standard 2>/dev/null | head -1)" ]]; then
    git_color="$C_GIT_DIRTY"; marks+="?"
  fi
  ab=""
  if upstream="$(cd "$current_dir" && git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null)"; then
    counts="$(cd "$current_dir" && git rev-list --left-right --count HEAD..."$upstream" 2>/dev/null)"
    ahead="${counts%%[[:space:]]*}"; behind="${counts##*[[:space:]]}"
    [[ "${ahead:-0}" -gt 0 ]] && ab+="↑${ahead}"
    [[ "${behind:-0}" -gt 0 ]] && ab+="↓${behind}"
  fi
  git_seg="${git_color}🌿 ${branch:-detached}"
  [[ -n "$marks" ]] && git_seg+=" ${marks}"
  [[ -n "$ab" ]] && git_seg+=" ${C_DIM}${ab}"
  row1+="${SEP}${git_seg}${C_RESET}"
fi

# Worktree indicator (linked worktree sessions).
if [[ -n "$worktree_name" && "$worktree_name" != "null" ]]; then
  wt="$worktree_name"
  [[ -n "$worktree_branch" && "$worktree_branch" != "null" ]] && wt+="@${worktree_branch}"
  row1+="${SEP}${C_ACCENT}🔗 ${wt}${C_RESET}"
fi

# Vim mode (only present when vim bindings are on).
[[ -n "$vim_mode" && "$vim_mode" != "null" ]] && \
  row1+="${SEP}${C_DIM}[${vim_mode}]${C_RESET}"

# ---------------------------------------------------------------------------
# Row 2 — runtime metrics: context · cost · diff · rate limits · PR.
# ---------------------------------------------------------------------------
row2=""

# Context window usage with a bar and token count.
if [[ -n "$ctx_pct" && "$ctx_pct" != "null" ]]; then
  pct_r="$(round "$ctx_pct")"
  ctx_color="$C_CTX"
  (( pct_r >= 80 )) && ctx_color="$C_CTX_WARN"
  bar="$(ctx_bar "$ctx_pct")"
  used_tok="$(human_tokens "$ctx_in")"
  size_tok="$(human_tokens "$ctx_size")"
  seg="${ctx_color}🧠 ${bar} ${pct_r}%${C_RESET}"
  [[ -n "$used_tok" ]] && seg+=" ${C_DIM}${used_tok}"
  [[ -n "$size_tok" ]] && seg+="/${size_tok}"
  seg+="${C_RESET}"
  [[ "$exceeds_200k" == "true" ]] && seg+=" ${C_CTX_WARN}⚠️${C_RESET}"
  row2+="$seg"
fi

# Session cost and wall-clock duration.
if [[ -n "$cost_usd" && "$cost_usd" != "null" ]]; then
  cost_fmt="$(awk -v c="$cost_usd" 'BEGIN{printf "%.2f", c}')"
  seg="${C_COST}💰 \$${cost_fmt}${C_RESET}"
  dur="$(human_duration "$dur_ms")"
  [[ -n "$dur" ]] && seg+=" ${C_DIM}${dur}${C_RESET}"
  [[ -n "$row2" ]] && row2+="$SEP"
  row2+="$seg"
fi

# Lines added/removed this session.
if [[ ( -n "$lines_add" && "$lines_add" != "null" && "$lines_add" != "0" ) || \
      ( -n "$lines_del" && "$lines_del" != "null" && "$lines_del" != "0" ) ]]; then
  seg="${C_ADD}+${lines_add:-0}${C_RESET} ${C_DEL}-${lines_del:-0}${C_RESET}"
  [[ -n "$row2" ]] && row2+="$SEP"
  row2+="$seg"
fi

# Subscription rate limits (5-hour / 7-day windows).
if [[ -n "$rl_5h" && "$rl_5h" != "null" ]]; then
  seg="⏳ 5h $(round "$rl_5h")%"
  [[ -n "$rl_7d" && "$rl_7d" != "null" ]] && seg+=" · 7d $(round "$rl_7d")%"
  [[ -n "$row2" ]] && row2+="$SEP"
  row2+="${C_RL}${seg}${C_RESET}"
fi

# Open PR for the current branch.
if [[ -n "$pr_number" && "$pr_number" != "null" ]]; then
  seg="${C_PR}🔀 #${pr_number}${C_RESET}"
  [[ -n "$pr_state" && "$pr_state" != "null" ]] && seg+=" ${C_DIM}${pr_state}${C_RESET}"
  [[ -n "$row2" ]] && row2+="$SEP"
  row2+="$seg"
fi

# ---------------------------------------------------------------------------
# Emit. Row 2 only prints when it has content.
# ---------------------------------------------------------------------------
printf '%b\n' "$row1"
[[ -n "$row2" ]] && printf '%b\n' "$row2"
exit 0
