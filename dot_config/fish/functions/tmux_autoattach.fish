function tmux_autoattach --description 'Attach to the most recently used detached tmux session, else start one'
    argparse 'n/dry-run' -- $argv; or return 1

    type -q tmux; or return 1
    if set -q TMUX
        return 0
    end

    # Rank by session_last_attached (when you last used it), falling back to
    # session_activity for sessions never attached -- session_activity does not
    # advance while a session is detached, so it alone means "newest created".
    # Only unattached sessions are considered, so a second terminal window opens
    # its own session instead of mirroring the one already on screen.
    set -l best ''
    set -l best_time -1
    for line in (tmux list-sessions -F '#{session_last_attached}|#{session_activity}|#{session_attached}|#{session_name}' 2>/dev/null)
        # -m3 keeps any '|' in the session name intact, since name is last.
        set -l parts (string split -m3 '|' -- $line)
        test (count $parts) -eq 4; or continue
        test "$parts[3]" = 0; or continue

        set -l key $parts[2]
        if test -n "$parts[1]"; and test "$parts[1]" -gt 0 2>/dev/null
            set key $parts[1]
        end
        if test "$key" -gt "$best_time"
            set best_time $key
            set best $parts[4]
        end
    end

    if set -q _flag_dry_run
        if test -n "$best"
            echo "would: tmux attach-session -t '$best'"
        else
            echo "would: tmux new-session"
        end
        return 0
    end

    # Deliberately not `exec`: if tmux fails to start, exec would replace the
    # shell with nothing and the terminal would close instantly, leaving no way
    # to set NO_AUTO_TMUX and recover. Running it normally and exiting only on
    # success gives the same "detach closes the window" behaviour, but keeps a
    # usable shell when tmux errors.
    if test -n "$best"
        tmux attach-session -t $best
    else
        tmux new-session
    end
    and exit
end
