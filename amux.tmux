#!/usr/bin/env bash
# amux - TPM-compatible plugin entry point
# https://github.com/tmux-plugins/tpm/blob/master/docs/how_to_create_plugin.md

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AMUX_BIN="$CURRENT_DIR/bin/amux"

get_tmux_option() {
    local option="$1"
    local default_value="$2"
    local option_value
    option_value=$(tmux show-option -gqv "$option")
    if [ -z "$option_value" ]; then
        echo "$default_value"
    else
        echo "$option_value"
    fi
}

# Default keybindings — unbind these before applying user overrides
# so that changing a key option doesn't leave the old binding active.
AMUX_DEFAULT_PICKER_KEY="a"
AMUX_DEFAULT_NEW_KEY="A"
AMUX_DEFAULT_NEXT_KEY="M-]"
AMUX_DEFAULT_PREV_KEY="M-["
AMUX_DEFAULT_SCRATCH_KEY="M-a"

main() {
    # Expose the binary path so keybindings and user scripts can reference it
    tmux set-option -g @amux-bin "$AMUX_BIN"

    # Make the binary executable (idempotent)
    chmod +x "$AMUX_BIN"

    # Read user-configurable keybindings with defaults
    local picker_key new_key next_key prev_key scratch_key

    picker_key=$(get_tmux_option "@amux-picker-key" "$AMUX_DEFAULT_PICKER_KEY")
    new_key=$(get_tmux_option "@amux-new-key" "$AMUX_DEFAULT_NEW_KEY")
    next_key=$(get_tmux_option "@amux-next-key" "$AMUX_DEFAULT_NEXT_KEY")
    prev_key=$(get_tmux_option "@amux-prev-key" "$AMUX_DEFAULT_PREV_KEY")
    scratch_key=$(get_tmux_option "@amux-scratch-key" "$AMUX_DEFAULT_SCRATCH_KEY")

    # Clean up default bindings so changed keys don't leave stale binds
    tmux unbind-key "$AMUX_DEFAULT_PICKER_KEY" 2>/dev/null || true
    tmux unbind-key "$AMUX_DEFAULT_NEW_KEY" 2>/dev/null || true
    tmux unbind-key -n "$AMUX_DEFAULT_NEXT_KEY" 2>/dev/null || true
    tmux unbind-key -n "$AMUX_DEFAULT_PREV_KEY" 2>/dev/null || true
    tmux unbind-key -n "$AMUX_DEFAULT_SCRATCH_KEY" 2>/dev/null || true

    # Agent picker (list agents + actions)
    tmux bind-key "$picker_key" run-shell "'$AMUX_BIN' _pick"

    # New agent (interactive type menu)
    tmux bind-key "$new_key" run-shell "'$AMUX_BIN' _menu \"\$(tmux display -p '#{pane_current_path}')\""

    # Cycle agents (next/prev zoomed pane) — root table (-n) for modifier keys
    tmux bind-key -n "$next_key" run-shell "'$AMUX_BIN' next"
    tmux bind-key -n "$prev_key" run-shell "'$AMUX_BIN' prev"

    # Scratch popup
    tmux bind-key -n "$scratch_key" run-shell "'$AMUX_BIN' scratch"
}

main
