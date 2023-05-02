
# >>> conda initialize >>>
eval ~/miniconda3/bin/conda "shell.fish" "hook" $argv | source
fish_vi_key_bindings
conda activate eq

export PYTHONPATH=$HOME/factset-db:$HOME/strat_manager:$HOME/bkln-data-service


