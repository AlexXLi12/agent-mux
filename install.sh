#!/usr/bin/env bash
set -euo pipefail

AMUX_DIR="$(cd "$(dirname "$0")" && pwd)"
ZSHRC="$HOME/.zshrc"
TMUX_CONF="$HOME/.config/tmux/tmux.conf"

echo "Installing amux from $AMUX_DIR"
echo ""

# Make script executable
chmod +x "$AMUX_DIR/bin/amux"

# Add to PATH
if ! grep -qF "$AMUX_DIR/bin" "$ZSHRC" 2>/dev/null; then
  {
    echo ""
    echo "# amux - agent multiplexer"
    echo "export PATH=\"$AMUX_DIR/bin:\$PATH\""
    echo "fpath=(\"$AMUX_DIR/completions\" \$fpath)"
  } >> "$ZSHRC"
  echo "[ok] Added PATH and fpath to $ZSHRC"
else
  echo "[skip] PATH already configured in $ZSHRC"
fi

# Source tmux config
if ! grep -qF "amux.tmux.conf" "$TMUX_CONF" 2>/dev/null; then
  if grep -q "run.*tpm/tpm" "$TMUX_CONF" 2>/dev/null; then
    # Insert before the TPM run line
    sed -i '' "/run.*tpm\/tpm/i\\
\\
# amux - agent multiplexer\\
source-file $AMUX_DIR/tmux/amux.tmux.conf
" "$TMUX_CONF"
  else
    {
      echo ""
      echo "# amux - agent multiplexer"
      echo "source-file $AMUX_DIR/tmux/amux.tmux.conf"
    } >> "$TMUX_CONF"
  fi
  echo "[ok] Added source-file to $TMUX_CONF"
else
  echo "[skip] tmux config already configured in $TMUX_CONF"
fi

echo ""
echo "Done! To activate now:"
echo "  source ~/.zshrc && tmux source-file ~/.config/tmux/tmux.conf"
