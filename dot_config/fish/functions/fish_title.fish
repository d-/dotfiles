function fish_title --description 'Hostname first, so an outer tmux can name the tab after this machine'
    # Inside tmux the title is replaced by set-titles-string; this matters for
    # a bare ssh shell seen from an outer tmux, whose tab takes the first word.
    echo (prompt_hostname) (status current-command) (prompt_pwd)
end
