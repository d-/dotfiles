function fish_prompt --description 'Minimal single-line prompt'
    set -l last_status $status

    # Conda env, rendered here rather than by conda: CONDA_CHANGEPS1=false in
    # config.fish keeps conda from wrapping this function. "base" is noise, so
    # it's omitted.
    if set -q CONDA_DEFAULT_ENV; and test "$CONDA_DEFAULT_ENV" != base
        set_color brblack
        printf '(%s) ' $CONDA_DEFAULT_ENV
    end

    set_color blue
    printf '%s' (prompt_pwd)

    # branch, with * for unstaged and + for staged
    set -l git_state (fish_git_prompt '%s')
    if test -n "$git_state"
        if string match -qr '[*+]' -- $git_state
            set_color yellow
        else
            set_color green
        end
        printf ' %s' (string trim -- $git_state)
    end

    # only appears when the last command failed
    if test $last_status -ne 0
        set_color red
        printf ' [%d]' $last_status
    end

    # The arrow carries the vi mode, replacing fish's default [I]/[N] block.
    switch $fish_bind_mode
        case default
            set_color --bold yellow
        case replace_one replace
            set_color --bold magenta
        case visual
            set_color --bold cyan
        case '*'
            set_color --bold green
    end
    printf ' ❯ '
    set_color normal
end
