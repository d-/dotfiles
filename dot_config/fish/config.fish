
<<<<<<< HEAD
# >>> conda initialize >>>
eval ~/miniconda3/bin/conda "shell.fish" "hook" $argv | source
fish_vi_key_bindings
conda activate eq

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
export PYTHONPATH=$HOME/factset-db:$HOME/strat_manager:$HOME/bkln-data-service
export LYNX_CFG=~/.config/lynx/.lynxrc
fzf_configure_bindings --directory=\cf --git_log=\cg --git_status=\cs --variables=\ce
=======
eval ~/opt/miniconda3/bin/conda "shell.fish" "hook" $argv | source
conda activate eq

export PYTHONPATH=$HOME/factset-db:$HOME/strat_manager

>>>>>>> 277b5f0 (add kitty)
