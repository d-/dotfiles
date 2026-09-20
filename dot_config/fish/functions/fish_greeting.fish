function fish_greeting --description 'Compact status banner, replacing fish default greeting'
    set -l up (uptime \
        | string replace -r '^.*up\s+' '' \
        | string replace -r ',?\s*\d+\s+users?.*$' '' \
        | string replace -ra '\s+' ' ' \
        | string trim)

    set_color brblack
    printf '%s · fish %s · up %s\n' (prompt_hostname) $version $up
    set_color normal

    # Surfaces drift in the dotfile repo, which is otherwise easy to forget.
    if type -q chezmoi
        set -l pending (chezmoi status 2>/dev/null | string match -rv '^\s*$')
        set -l n (count $pending)
        if test $n -gt 0
            set_color yellow
            printf '%d dotfile item%s pending (chezmoi status)\n' $n (test $n -eq 1; and echo ''; or echo 's')
            set_color normal
        end
    end
end
