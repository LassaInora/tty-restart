#!/bin/bash
# Uninstall tty-restart and its man page (GPLv3)

set -e  # Stopper en cas d'erreur

CMD_NAME="tty-restart"
BIN_PATH="/usr/local/bin/${CMD_NAME}"
MAN_PATH="/usr/share/man/man1/${CMD_NAME}.1.gz"

# Vérification des droits root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root (e.g. sudo ./uninstall.sh)"
    exit 1
fi

# Suppression du binaire si présent
if [ -f "$BIN_PATH" ]; then
    echo "Removing binary: $BIN_PATH"
    rm -f "$BIN_PATH"
else
    echo "Binary not found: $BIN_PATH"
fi

# Suppression de la page man si présente
if [ -f "$MAN_PATH" ]; then
    echo "Removing man page: $MAN_PATH"
    rm -f "$MAN_PATH"
    echo "Updating man database..."
    mandb -q
else
    echo "Man page not found: $MAN_PATH"
fi

echo "Uninstallation complete."
