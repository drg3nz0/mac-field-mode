#!/bin/zsh
# Symlink field-mode tools into ~/.local/bin
set -e

SRC="$(cd "$(dirname "$0")/bin" && pwd)"
DEST="$HOME/.local/bin"
mkdir -p "$DEST"

for f in battery-save wifi-shield field-mode field-guard net-secure \
         field-on.command field-off.command; do
    ln -sf "$SRC/$f" "$DEST/$f"
    echo "  linked $f"
done

echo ""
echo "Done. Ensure ~/.local/bin is on your PATH:"
echo '  echo '\''export PATH="$HOME/.local/bin:$PATH"'\'' >> ~/.zshrc'
echo ""
echo "Try:  field-mode status"
