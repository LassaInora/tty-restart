#!/bin/bash
#
# Restart a Linux TTY from another TTY.
# Copyright (C) 2025 Picsel / LassaInora
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License.

# =-= =-= =< DEFAULT FLAGS >= =-= =-= #
DRY_RUN=false
VERBOSE=false

# =-= =-= =< USAGES / HELP >= =-= =-= #
show_help() {
  cat << EOF
Usage: $(basename "$0") [TARGET_TTY] [ALT_TTY] [options]
}
Restart a virtual console (TTY) from another TTY.
Command is injected into a different terminal to avoid self-restart.

Arguments
  TARGET_TTY  TTY to restart (e.g. 5 or tty5)
              0 or tty0 means "current TTY".
              If omitted, defaults to the current TTY.

  ALT_TTY     TTY used to send the restart command.
              0 or tty0 means "first free available TTY".
              Can be current TTY, but NOT the target one.

Options
  --dry-run   Print commands without executing.
  --verbose   Show detailed steps.
  --help      Display this help and exit.

Examples
  $(basename "$0")           # Restart current TTY using a free one.
  $(basename "$0") 5         # Restart tty5 via a free one.
  $(basename "$0") 5 3       # Restart tty5 via tty3.
  $(basename "$0") 0 2       # Restart current TTY via tty2.
  $(basename "$0") 4 --dry-run
EOF
}

# =-= =-= =< PARSE OPTIONS >= =-= =-= #
POSITIONAL=()
for arg in "$@"; do
    case "$arg" in
        --dry-run)  DRY_RUN=true ;;
        --verbose)  VERBOSE=true ;;
        --help)     show_help; exit 0 ;;
        *)          POSITIONAL+=("$arg") ;;
    esac
done
set -- "${POSITIONAL[@]}"

# =-= =-= =< RESOLVE TARGET TTY >= =-= =-= #
if [ -n "$1" ]; then
    case "$1" in
        0|tty0)       TARGET_TTY=$(tty | sed 's/dev/::') ;;
        tty[0-9]*)     TARGET_TTY="$1" ;;
        [0-9]*)        TARGET_TTY="tty$1" ;;
        *)            echo "Error: invalid TARGET_TTY"; exit 1 ;;
    esac
else
    TARGET_TTY$(tty | sed 's/dev/::')
fi

if [ ! -e "/dev/$TARGET_TTY" ]; then
    echo "Error: /dev/$TARGET_TTY does not exist."
    exit 1
fi

# =-= =-= =< RESOLVE ALTERN TTY >= =-= =-= #
ALT_TTY_FORCE=""
if [ -n "$2" ]; then
    case "$2" in
        0|tty0)       ALT_TTY_FORCE="" ;;
        tty[0-9]*)    ALT_TTY_FORCE="$2" ;;
        [0-9]*)       ALT_TTY_FORCE="tty$2" ;;
        *)            echo "Error: invalid ALT_TTY"; exit 1 ;;
    esac
fi

# =-= =-= =< HELPER >= =-= =-= #
run_restart() {
    local ALT="$1" TARGET="$2"
    local CMD="sudo systemctl restart getty@${TARGET}"

    if $DRY_RUN || $VERBOSE; then
        echo "[INFO] sending '$CMD' to /dev/${ALT}"
    fi
    if ! $DRY_RUN; then
        echo "$CMD" | sudo tee "/dev/${ALT}" > /dev/null
    fi
    echo "Restart of ${TARGET} scheduled via ${ALT}"
    exit 0
}

# =-= =-= =< FIND ALT TTY >= =-= =-= #
TTY_LIST=(tty1 tty2 tty3 tty4 tty5 tty6 tty7 tty8 tty9 tty10 tty11 tty12)

if [ -n "$ALT_TTY_FORCE" ]; then
    if [ "$ALT_TTY_FORCE" = "$TARGET_TTY" ]; then
        echo "Error: ALT_TTY must differ from TARGET_TTY."
        exit 1
    fi
    if [ ! -e "/dev/$ALT_TTY_FORCE" ]; then
        echo "Error: /dev/$ALT_TTY_FORCE does not exist."
        exit 1
    fi
    run_restart "$ALT_TTY_FORCE" "$TARGET_TTY"
else
    for ALT in "${TTY_LIST[@]}"; do
        [ "$ALT" = "$TARGET_TTY" ] && continue
        $VERBOSE && echo "[CHECK] /dev/${ALT}"
        if [ -e "/dev/$ALT" ] && ! sudo fuser "/dev/$ALT" 1>/dev/null 2>&1; then
            run_restart "$ALT" "TARGET_TTY"
        fi
    done
fi

echo "Error: no available TTY found to restart $TARGET_TTY."
exit 1
