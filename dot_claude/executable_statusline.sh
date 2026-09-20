#!/bin/bash
# Claude Code status line. Receives session JSON on stdin.
#
# Design rules:
#  - Always show what you need to steer: where you are, how full the context is,
#    how much of the 5-hour limit is gone.
#  - Show exceptional state only when it IS exceptional (7-day limit, fast mode,
#    thinking off, a dirty tree). Constants are noise.
#  - Never fail. A status line that errors renders blank with no diagnostic, so
#    every field is optional and every lookup is guarded.
set -uo pipefail

input="$(cat 2>/dev/null || true)"

# One jq invocation, not one per field: this runs on every event.
# Separator is US (0x1f), NOT tab: tab is IFS whitespace, so runs of empty
# fields would collapse into one and shift every value left.
IFS=$'\037' read -r model effort ctx_pct ctx_size cost added removed \
    rl5 rl5_reset rl7 fast_mode thinking dir <<EOF
$(printf '%s' "$input" | jq -r '[
    (.model.display_name // ""),
    (.effort.level // ""),
    (.context_window.used_percentage // ""),
    (.context_window.context_window_size // ""),
    (.cost.total_cost_usd // ""),
    (.cost.total_lines_added // 0),
    (.cost.total_lines_removed // 0),
    (.rate_limits.five_hour.used_percentage // ""),
    (.rate_limits.five_hour.resets_at // ""),
    (.rate_limits.seven_day.used_percentage // ""),
    (.fast_mode // false),
    (.thinking.enabled // true),
    (.workspace.current_dir // .cwd // "")
] | map(tostring) | join("\u001f")' 2>/dev/null)
EOF

[[ -z "${dir:-}" ]] && dir="$PWD"

D=$'\033[2m'; R=$'\033[0m'
RED=$'\033[31m'; YEL=$'\033[33m'; GRN=$'\033[32m'; BLU=$'\033[34m'; CYA=$'\033[36m'
SEP="${D}  ·  ${R}"

# Green under 50, yellow under 80, red at or above.
heat() {
    local n="${1:-}"
    [[ "$n" =~ ^[0-9]+$ ]] || { printf '%s' "$D"; return; }
    if   (( n >= 80 )); then printf '%s' "$RED"
    elif (( n >= 50 )); then printf '%s' "$YEL"
    else                     printf '%s' "$GRN"
    fi
}

human() {  # 1000000 -> 1M, 200000 -> 200k
    local n="${1:-}"
    [[ "$n" =~ ^[0-9]+$ ]] || { printf ''; return; }
    if   (( n >= 1000000 )); then printf '%sM' "$(( n / 1000000 ))"
    elif (( n >= 1000 ));    then printf '%sk' "$(( n / 1000 ))"
    else                          printf '%s' "$n"
    fi
}

tilde='~'
out="${BLU}${dir/#$HOME/$tilde}${R}"

# Branch, with * for a dirty tree.
if branch="$(git -C "$dir" symbolic-ref --quiet --short HEAD 2>/dev/null)" && [[ -n "$branch" ]]; then
    if git -C "$dir" diff --quiet --ignore-submodules HEAD 2>/dev/null; then
        out+=" ${GRN}${branch}${R}"
    else
        out+=" ${YEL}${branch}*${R}"
    fi
elif sha="$(git -C "$dir" rev-parse --short HEAD 2>/dev/null)"; then
    out+=" ${D}@${sha}${R}"
fi

[[ -n "${CONDA_DEFAULT_ENV:-}" && "${CONDA_DEFAULT_ENV}" != base ]] && out+=" ${D}(${CONDA_DEFAULT_ENV})${R}"

# Model, with effort appended when it is set.
if [[ -n "${model:-}" ]]; then
    short="${model%% (*}"          # "Opus 5 (1M context)" -> "Opus 5"
    out+="${SEP}${CYA}${short}${R}"
    [[ -n "${effort:-}" ]] && out+="${D}·${effort}${R}"
fi

# Context: the number that decides when you get compacted.
if [[ -n "${ctx_pct:-}" ]]; then
    size="$(human "${ctx_size:-}")"
    out+="${SEP}$(heat "$ctx_pct")ctx ${ctx_pct}%${R}"
    [[ -n "$size" ]] && out+="${D}/${size}${R}"
fi

# 5-hour limit, always. Reset time only once it starts to matter.
if [[ -n "${rl5:-}" ]]; then
    out+="${SEP}$(heat "$rl5")5h ${rl5}%${R}"
    if [[ "${rl5:-0}" =~ ^[0-9]+$ ]] && (( rl5 >= 50 )) && [[ "${rl5_reset:-}" =~ ^[0-9]+$ ]]; then
        out+="${D}→$(date -r "$rl5_reset" +%H:%M 2>/dev/null)${R}"
    fi
fi

# 7-day limit only when it is the binding constraint.
if [[ "${rl7:-}" =~ ^[0-9]+$ ]] && (( rl7 >= 50 )); then
    out+="${SEP}$(heat "$rl7")7d ${rl7}%${R}"
fi

[[ -n "${cost:-}" ]] && out+="${SEP}${D}\$$(printf '%.2f' "$cost" 2>/dev/null || printf '?')${R}"

# Session diff, when anything has changed.
if [[ "${added:-0}" =~ ^[0-9]+$ ]] && [[ "${removed:-0}" =~ ^[0-9]+$ ]] && (( added + removed > 0 )); then
    out+="${SEP}${GRN}+${added}${R}${D}/${R}${RED}-${removed}${R}"
fi

# Exceptional modes only.
[[ "${fast_mode:-false}" == true ]] && out+="${SEP}${YEL}fast${R}"
[[ "${thinking:-true}" == false ]] && out+="${SEP}${D}think off${R}"

printf '%s' "$out"
