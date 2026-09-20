#!/bin/bash
# Claude Code status line. Receives session JSON on stdin.
# Every field is optional: unknown or missing keys must degrade to a shorter
# line rather than an error, since a failing status line is silently blank.
set -uo pipefail

input="$(cat 2>/dev/null || true)"

field() {
    printf '%s' "$input" | jq -r "$1 // empty" 2>/dev/null || true
}

model="$(field '.model.display_name')"
dir="$(field '.workspace.current_dir')"
[[ -z "$dir" ]] && dir="$(field '.cwd')"
[[ -z "$dir" ]] && dir="$PWD"

# ~-relative path, matching the fish prompt. The replacement goes through a
# variable because an inline \~ would emit a literal backslash.
tilde='~'
pretty_dir="${dir/#$HOME/$tilde}"

# Branch plus a * when the tree is dirty.
git_part=""
if branch="$(git -C "$dir" symbolic-ref --quiet --short HEAD 2>/dev/null)" && [[ -n "$branch" ]]; then
    dirty=""
    git -C "$dir" diff --quiet --ignore-submodules HEAD 2>/dev/null || dirty="*"
    git_part=" $branch$dirty"
elif sha="$(git -C "$dir" rev-parse --short HEAD 2>/dev/null)"; then
    git_part=" @$sha"
fi

env_part=""
[[ -n "${CONDA_DEFAULT_ENV:-}" && "${CONDA_DEFAULT_ENV}" != "base" ]] && env_part=" (${CONDA_DEFAULT_ENV})"

out="$pretty_dir$git_part$env_part"
[[ -n "$model" ]] && out="$out  ·  $model"
printf '%s' "$out"
