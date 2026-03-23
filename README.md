# amux

`amux` is a small tmux wrapper that turns agent CLIs into pane-based "sub-tabs" inside the current tmux window.

It lets you spin up multiple coding agents side by side, keep them named, jump between them quickly, and manage them with a mix of CLI commands and tmux keybindings.

## What It Does

- Creates a new tmux pane running an agent CLI.
- Marks that pane as an `amux` agent and stores metadata on it.
- Zooms the active agent pane so switching feels closer to tabbing than pane juggling.
- Keeps agent panes named so you can jump to them by name.
- Exposes tmux menus for creating, picking, renaming, logging, killing, and respawning agents.

Out of the box, `amux` knows about these agent commands:

- `claude`
- `claude --dangerously-skip-permissions`
- `codex`
- `opencode`
- `cursor-agent`

Resume flows are implemented for:

- `claude --resume`
- `claude --dangerously-skip-permissions --resume`
- `codex --resume`

## Requirements

- `tmux`
- `zsh`
- One or more installed agent CLIs that match the command names above

`amux` must be run inside tmux. Running it outside tmux exits with an error.

## Install

Add the plugin to your `~/.tmux.conf` (or `~/.config/tmux/tmux.conf`):

```tmux
set -g @plugin 'AlexXLi12/agent-mux'
```

Then press `prefix + I` to install, or reload your config and restart tmux.

To get the `amux` CLI on your `PATH` and zsh completions, add to `~/.zshrc`:

```bash
# amux - agent multiplexer (adjust path if TPM plugins dir differs)
export PATH="$HOME/.tmux/plugins/agent-mux/bin:$PATH"
fpath=("$HOME/.tmux/plugins/agent-mux/completions" $fpath)
```

## Usage

### Create an Agent

```bash
amux new --type codex
amux new --type claude --name reviewer
amux new --type claude --trust
amux new --type codex --resume
amux new --type claude --prompt "review the failing tests"
```

Behavior:

- if `--name` is omitted, names auto-increment as `agent-1`, `agent-2`, ...
- if `--type` is omitted, `amux` opens the interactive tmux menu
- new agent panes inherit the current working directory unless `--dir` is provided
- agent panes are zoomed automatically after creation

### List Agents

```bash
amux ls
```

Shows:

- name
- type
- state
- pid

The active pane is marked with `*`.

### Switch Between Agents

```bash
amux go reviewer
amux next
amux prev
```

`next` and `prev` cycle only through panes marked as `amux` agents in the current tmux window.

### Send Input to an Agent

```bash
amux send reviewer "continue"
amux send reviewer Escape
```

This forwards keys through `tmux send-keys`.

### Rename an Agent

```bash
amux rename reviewer planner
```

### Kill Agents

```bash
amux kill reviewer
amux kill --dead
amux kill --all
```

For named or `--all` kills, `amux` first tries a graceful `/exit` before force-killing the pane.

### Respawn a Dead Agent

```bash
amux respawn reviewer
amux respawn reviewer -- codex --resume
```

### Capture Pane Output

```bash
amux log reviewer
```

This dumps the full pane scrollback to stdout using `tmux capture-pane`.

### Scratch Popup

```bash
amux scratch
amux scratch -- codex
```

This opens an ephemeral tmux popup. By default it launches `claude`.

## Configuration

All keybindings are configurable via tmux options. Set these in your `tmux.conf` before the plugin is loaded:

```tmux
set -g @amux-picker-key 'a'     # default: a (prefix table)
set -g @amux-new-key 'A'        # default: A (prefix table)
set -g @amux-next-key 'M-]'     # default: M-] (root table)
set -g @amux-prev-key 'M-['     # default: M-[ (root table)
set -g @amux-scratch-key 'M-a'  # default: M-a (root table)
```

## Tmux Keybindings

The default bindings are:

- `prefix a`: open the agent picker
- `prefix A`: open the new-agent menu
- `Alt-]`: next agent
- `Alt-[`: previous agent
- `Alt-a`: scratch popup

The picker menu also exposes actions for:

- creating a new agent
- renaming the current agent
- viewing the current agent log
- killing the current agent
- killing a selected agent
- respawning the current dead agent
- killing all dead agents
- killing all agents

## Agent Types

Supported `--type` values:

- `claude`
- `codex`
- `opencode`
- `cursor`

Extra flags:

- `--trust`: only changes `claude` to `claude --dangerously-skip-permissions`
- `--resume`: supported for `claude` and `codex`

If you pass `--resume` for a type without a configured resume command, `amux` exits with an error.

## Shell Completion

zsh completion is included in [completions/_amux](completions/_amux). The `fpath` line in the install instructions above enables it.

## Uninstall

Remove the `@plugin` line from your `tmux.conf`, then press `prefix + alt + u` (TPM uninstall) or delete `~/.tmux/plugins/agent-mux`. Remove the `PATH`/`fpath` lines from `~/.zshrc`.

## Notes

- The tool operates per tmux window. `amux ls`, `next`, `prev`, and picker actions only inspect panes marked as agents in the current window.
- Window titles are updated to the active agent name plus its position, for example `reviewer [2/4]`.
