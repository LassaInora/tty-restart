# tty-restart

A safe and flexible Bash script to restart a TTY console session using another TTY.

## Features

* Restart a frozen or unresponsive TTY
* Automatically finds a free alternative TTY
* Supports manual override
* Comes with a man page

## Installation

```bash
git clone https://github.com/LassaInora/tty-restart.git
cd tty-restart
./install.sh
```

## Usage

```Bash
tty-restart            # Restart current TTY using available alternate
tty-restart 2          # Restart tty2 using another TTY
tty-restart 2 5        # Restart tty2 using tty5
tty-restart --help     # Show help
```

## License

*GPLv3*
