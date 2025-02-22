# To launch Hyprland with uwsm
if [ -z "$TMUX" ] && [ -t 1 ]; then
    if uwsm check may-start && uwsm select; then
        exec systemd-cat -t uwsm_start uwsm start default
    fi
fi

#Default editor config
export EDITOR="/usr/bin/nvim"
export VISUAL="$EDITOR"
