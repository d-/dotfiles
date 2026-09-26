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

# C++ toolchain. Homebrew's LLVM (clang 23) is the default compiler: it is
# keg-only, so put its bin dir at the front of PATH so `clang`, `clang++`,
# `clangd`, `clang-format` and `clang-tidy` all resolve there. Apple's older
# clang stays available as /usr/bin/clang++. --path matters: without it
# fish_add_path only edits fish_user_paths; --move keeps it at the front even
# if an earlier entry already contained it.
if set -q HOMEBREW_PREFIX; and test -d $HOMEBREW_PREFIX/opt/llvm/bin
    fish_add_path -g --path --move --prepend $HOMEBREW_PREFIX/opt/llvm/bin
end

# C++23 by default: ~/.config/clang/clang++.cfg adds -std=c++23 to every LLVM
# clang++ invocation (Homebrew builds clang with ~/.config/clang as its user
# config dir; Apple's clang ignores it). Config-file flags come first, so a
# project's own -std= or CMAKE_CXX_STANDARD still wins.
# CC/CXX are needed because PATH order alone does not reach build systems:
# CMake and make look for `c++`/`cc`, which LLVM does not ship, so they would
# silently fall back to Apple's /usr/bin/c++ (C++14 default). Presets,
# -DCMAKE_CXX_COMPILER and an explicit CXX= on the command line still win.
if set -q HOMEBREW_PREFIX; and test -x $HOMEBREW_PREFIX/opt/llvm/bin/clang++
    set -gx CC clang
    set -gx CXX clang++
end

# CMake defaults for ad-hoc `cmake -B build`: Ninja, and compile_commands.json
# so clangd can see every project. CMakePresets.json and -G still win.
if type -q ninja
    set -gx CMAKE_GENERATOR Ninja
end
set -gx CMAKE_EXPORT_COMPILE_COMMANDS ON

# vcpkg: the brew formula ships only the binary; the ports registry is a clone.
if test -d $HOME/.local/share/vcpkg
    set -gx VCPKG_ROOT $HOME/.local/share/vcpkg
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

    # `c++` is always Apple's driver (LLVM ships no such alias) and reads no
    # config file; expand it visibly so ad-hoc compiles still get C++23.
    abbr -a c++ 'c++ -std=c++23'

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
