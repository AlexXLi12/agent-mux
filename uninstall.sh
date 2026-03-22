#!/usr/bin/env bash
set -euo pipefail

AMUX_DIR="$(cd "$(dirname "$0")" && pwd)"
ZSHRC="$HOME/.zshrc"
TMUX_CONF="$HOME/.config/tmux/tmux.conf"

echo "Uninstalling amux"
echo ""

# Remove from zshrc (PATH, fpath, comment)
if grep -qF "$AMUX_DIR/bin" "$ZSHRC" 2>/dev/null; then
  sed -i '' "\|$AMUX_DIR/bin|d" "$ZSHRC"
  sed -i '' "\|$AMUX_DIR/completions|d" "$ZSHRC"
  sed -i '' '/# amux - agent multiplexer/d' "$ZSHRC"
  echo "[ok] Removed PATH and fpath from $ZSHRC"
else
  echo "[skip] Nothing to remove from $ZSHRC"
fi

# Remove from tmux config
if grep -qF "amux.tmux.conf" "$TMUX_CONF" 2>/dev/null; then
  sed -i '' '/amux.tmux.conf/d' "$TMUX_CONF"
  sed -i '' '/# amux - agent multiplexer/d' "$TMUX_CONF"
  echo "[ok] Removed source-file from $TMUX_CONF"
else
  echo "[skip] Nothing to remove from $TMUX_CONF"
fi

echo ""
echo "Done! To take effect now:"
echo "  source ~/.zshrc && tmux source-file ~/.config/tmux/tmux.conf"
