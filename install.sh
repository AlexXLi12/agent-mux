#!/usr/bin/env bash
set -euo pipefail

AMUX_DIR="$(cd "$(dirname "$0")" && pwd)"
ZSHRC="$HOME/.zshrc"
TMUX_CONF="$HOME/.config/tmux/tmux.conf"
AMUX_BIN_LINE="set -g @amux-bin $AMUX_DIR/bin/amux"
AMUX_SOURCE_LINE="source-file $AMUX_DIR/tmux/amux.tmux.conf"

portable_sed_inplace() {
  local script="$1" file="$2"
  if sed --version >/dev/null 2>&1; then
    sed -i "$script" "$file"
  else
    sed -i '' "$script" "$file"
  fi
}

echo "Installing amux from $AMUX_DIR"
echo ""

mkdir -p "$(dirname "$TMUX_CONF")"
touch "$ZSHRC" "$TMUX_CONF"

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

# Refresh tmux config
portable_sed_inplace '/# amux - agent multiplexer/d' "$TMUX_CONF"
portable_sed_inplace '/@amux-bin/d' "$TMUX_CONF"
portable_sed_inplace '/amux.tmux.conf/d' "$TMUX_CONF"

if grep -q "run.*tpm/tpm" "$TMUX_CONF" 2>/dev/null; then
  # Insert before the TPM run line
  portable_sed_inplace "/run.*tpm\\/tpm/i\\
\\
# amux - agent multiplexer\\
$AMUX_BIN_LINE\\
$AMUX_SOURCE_LINE
" "$TMUX_CONF"
else
  {
    echo ""
    echo "# amux - agent multiplexer"
    echo "$AMUX_BIN_LINE"
    echo "$AMUX_SOURCE_LINE"
  } >> "$TMUX_CONF"
fi
echo "[ok] Refreshed tmux config in $TMUX_CONF"

echo ""
echo "Done! To activate now:"
echo "  source ~/.zshrc && tmux source-file ~/.config/tmux/tmux.conf"
