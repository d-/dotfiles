
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
eval ~/miniconda3/bin/conda "shell.fish" "hook" $argv | source
conda activate eq

export PYTHONPATH=$HOME/factset-db:$HOME/strat_manager


if pgrep tmux >/dev/null 2>&1; then
  if [ -z "$TMUX" ]; then
    # Attach to the last session
    tmux attach-session -d || tmux new-session
  fi
fi

@source ~/.config/tmux/.tmux.conf
# <<< conda initialize <<<

