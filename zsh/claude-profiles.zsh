# Claude Code profile switching — auto-selects work/personal based on cwd
CLAUDE_WORK_DIRS=(
    "$HOME/indecimal"
)

claude() {
    local current_dir profile config_dir
    current_dir=$(pwd -P)
    profile="personal"

    for work_dir in "${CLAUDE_WORK_DIRS[@]}"; do
        if [[ "$current_dir" == "$work_dir"* ]]; then
            profile="work"
            break
        fi
    done

    config_dir="$HOME/.config/claude/$profile"

    if [[ "$profile" == "work" ]]; then
        print -P "%F{red}%B[WORK PROFILE]%b%f" >&2
    fi

    CLAUDE_CONFIG_DIR="$config_dir" command claude "$@"
}

# Explicit overrides when you need to force a profile
alias claude-personal='CLAUDE_CONFIG_DIR=$HOME/.config/claude/personal command claude'
alias claude-work='CLAUDE_CONFIG_DIR=$HOME/.config/claude/work command claude'
