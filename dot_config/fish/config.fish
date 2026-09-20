# Synced via chezmoi -- keep this machine-agnostic.
# Anything tied to one machine (repo checkouts, PYTHONPATH, tokens) belongs in
# ~/.config/fish/config.local.fish, which is intentionally not managed here.

# ~/.local/bin holds claude and other user-installed binaries; on zsh this came
# from ~/.zshrc, which fish never reads.
for dir in $HOME/.local/bin $HOME/.cargo/bin
    if test -d $dir
        fish_add_path -g $dir
    end
end

# Docker Desktop CLI shims, appended to match ~/.zprofile's ordering.
if test -d $HOME/.docker/bin
    fish_add_path -g --append $HOME/.docker/bin
end

# Homebrew first. macOS path_helper appends /etc/paths.d/homebrew *after*
# /usr/bin, so without this the system Ruby 2.6 shadows brew's 3.3 and
# /usr/bin/bundle (Bundler 1.17.2) wins over the real one. zsh gets this from
# ~/.zprofile, which fish never reads.
for brewbin in /opt/homebrew/bin/brew /usr/local/bin/brew
    if test -x $brewbin
        $brewbin shellenv fish | source
        break
    end
end

# Stop conda touching the prompt at all -- CONDA_LEFT_PROMPT makes it wrap
# fish_prompt instead, which double-renders the env. fish_prompt shows
# $CONDA_DEFAULT_ENV itself.
set -gx CONDA_CHANGEPS1 false

# Left unguarded so `fish -c 'python ...'` in scripts still gets py11.
if test -x $HOME/miniconda3/bin/conda
    eval $HOME/miniconda3/bin/conda "shell.fish" "hook" | source
    if test -d $HOME/miniconda3/envs/py11
        conda activate py11
    end
end

# Interactive-only. Key bindings do nothing in a script, and (tty) evaluates to
# the literal string "not a tty" when stdin isn't a terminal -- which would hand
# gpg a bogus TTY path.
if status is-interactive
    fish_vi_key_bindings

    # Prompt settings; the prompt itself lives in functions/fish_prompt.fish.
    set -g fish_prompt_pwd_dir_length 0
    set -g __fish_git_prompt_showdirtystate 1
    set -g __fish_git_prompt_showuntrackedfiles 0
    set -g __fish_git_prompt_char_dirtystate '*'
    set -g __fish_git_prompt_char_stagedstate '+'
    set -g __fish_git_prompt_char_cleanstate ''
    set -g __fish_git_prompt_char_stateseparator ''

    set -gx GPG_TTY (tty)

    if type -q fzf_configure_bindings
        fzf_configure_bindings --directory=\cf --git_log=\cg --git_status=\cs --variables=\ce
    end
end

if test -f $__fish_config_dir/config.local.fish
    source $__fish_config_dir/config.local.fish
end

# Auto-attach to tmux. Last, so config.local.fish can set NO_AUTO_TMUX first.
# Skipped inside tmux, in editor-managed terminals, and in non-interactive
# shells. Escape hatch:  set -gx NO_AUTO_TMUX 1
if status is-interactive
    and not set -q TMUX
    and not set -q NO_AUTO_TMUX
    and not set -q INSIDE_EMACS
    and not set -q CLAUDECODE
    and test "$TERM_PROGRAM" != vscode
    and test "$TERM" != dumb
    and type -q tmux
    tmux_autoattach
end
