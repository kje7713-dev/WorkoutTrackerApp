
#!/usr/bin/env bash
# Quick helper to make a shell command alias called 'kevin-ffb'
# Usage:
#   bash install_kevin_ffb_lineup.sh
# Then, either:
#   - Follow the echo'd instructions to add the alias to your shell profile, or
#   - Call with: bash -lc 'python /path/to/kevin_ffb_lineup.py --week 1'
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TARGET="$SCRIPT_DIR/kevin_ffb_lineup.py"

echo ""
echo "Add this line to your shell profile (~/.bashrc or ~/.zshrc):"
echo "alias kevin-ffb='python \"$TARGET\"'"
echo ""
echo "Then reload your shell (e.g., 'source ~/.zshrc') and run:"
echo "kevin-ffb --week 1"
echo ""
