#!/bin/bash
# Install tty-restart and its man page (GPLv3)

CMD_NAME="tty-restart"
SRC_DIR="$(cd "$(dirname "$0")" && pwd)"
BIN_SRC="${SRC_DIR}/${CMD_NAME}.sh"
MAN_SRC="${SRC_DIR}/man/${CMD_NAME}.1"

BIN_DST="/usr/local/bin/${CMD_NAME}"
MAN_DST="/usr/local/man/man1/${CMD_NAME}.1.gz"

# Check for root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root (e.g. sudo ./install.sh)"
    exit 1
fi

echo "Installing ${CMD_NAME} to ${BIN_DST}"
install -m 755 "$BIN_SRC" "$BIN_DST" || exit 1

echo "Installing man page to ${MAN_DST}"
mkdir -p "$(dirname "$MAN_DST")"
gzip -c "$MAN_SRC" > "$MAN_DST" || exit 1

echo "Updating man database..."
if command -v mandb >/dev/null 2>&1; then
    mandb -q || echo "Warning: mandb failed, but install completed"
else
    echo "Warning: 'mandb' not found. Man page may not be indexed."
fi

echo "Installation complete. Use '${CMD_NAME} --help' or 'man ${CMD_NAME}'."

