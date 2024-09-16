
# >>> conda initialize >>>
eval ~/miniconda3/bin/conda "shell.fish" "hook" $argv | source
fish_vi_key_bindings
conda activate py11

export PYTHONPATH=$HOME/equities_rebalancer/equities_rebalancer:$HOME/portfolio-management-system:$HOME/client-python:$HOME/equity_signals:$HOME/turbine:$HOME/skopos_py:$HOME/python-service-utils:$HOME/msci-barra:$HOME/shadow_benchmark:$HOME/quant:$HOME/equities_rebalancer:$HOME/atlas:$HOME/factset-db:$HOME/strat-manager:$HOME/bkln-data-service
set -gx PATH "$HOME/.cargo/bin" $PATH
set -x GPG_TTY (tty)

fzf_configure_bindings --directory=\cf --git_log=\cg --git_status=\cs --variables=\ce
