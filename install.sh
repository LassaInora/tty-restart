#!/bin/bash
# Install tty-restart and its man page (GPLv3)

CMD_NAME="tty-restart"
SRC_DIR="$(cd "$(dirname "$0")" && pwd)"
BIN_SRC="${SRC_DIR}/${CMD_NAME}.sh"
MAN_SRC="${SRC_DIR}/${CMD_NAME}.1"

BIN_DST="/usr/local/bin/${CMD_NAME}"
MAN_DST="/usr/local/share/man/man1/${CMD_NAME}.1.gz"

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root (e.g. sudo ;/install.sh)"
    exit 1
fi

echo "Installing ${CMD_NAME} to ${BIN_DST}"
install -m 755 "$BIN_SRC" "$BIN_DST"

echo "Installing man page to ${MAN_DST}"
mkdir -p "$(dirname "$MAN_DST")"
gzip -c "$MAN_SRC" > "$MAN_DST"

echo "Updating man database..."
mandb -q

echo "Installation complete. Use '${CMD_NAME} --help' or 'man ${CMD_NAME}'."
