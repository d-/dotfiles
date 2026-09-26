function fish_prompt --description 'Minimal single-line prompt'
    set -l last_status $status

    # Conda env, rendered here rather than by conda: CONDA_CHANGEPS1=false in
    # config.fish keeps conda from wrapping this function. "base" is noise, so
    # it's omitted.
    if set -q CONDA_DEFAULT_ENV; and test "$CONDA_DEFAULT_ENV" != base
        set_color 5e5e5e brblack
        printf '(%s) ' $CONDA_DEFAULT_ENV
    end

    set_color 00d400 green
    printf '%s' (prompt_pwd)

    # branch, with * for unstaged and + for staged
    set -l git_state (fish_git_prompt '%s')
    if test -n "$git_state"
        # Uncommitted work is worth a glance: yellow. Clean is quiet green.
        if string match -qr '[*+]' -- $git_state
            set_color e0c070 yellow
        else
            set_color 00a800 green
        end
        printf ' %s' (string trim -- $git_state)
    end

    # only appears when the last command failed
    if test $last_status -ne 0
        set_color e06c75 red
        printf ' [%d]' $last_status
    end

    # The arrow carries the vi mode, replacing fish's default [I]/[N] block.
    # Same tones as nvim's lualine: insert green, normal dimmed, visual a
    # reversed block, replace red.
    switch $fish_bind_mode
        case default
            set_color --bold b0b0b0 brwhite
        case replace_one replace
            set_color --bold e06c75 red
        case visual
            set_color --bold --reverse 00a800 green
        case '*'
            set_color --bold 00ff00 green
    end
    printf ' ❯ '
    set_color normal
end
