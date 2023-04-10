
# >>> conda initialize >>>
eval ~/miniconda3/bin/conda "shell.fish" "hook" $argv | source
conda activate eq

export PYTHONPATH=$HOME/factset-db:$HOME/strat_manager


if pgrep tmux >/dev/null 2>&1;
    tmux attach-session -d || tmux new-session | nohup tmux source ~/.config/tmux/.tmux.conf >/dev/null 2>&1;
end

