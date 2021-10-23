# irun

This script allows you to run commands from a file in an interactive way.

## Installation
This script depends on [tmux](https://github.com/tmux/tmux) and
[bat](https://github.com/sharkdp/bat) programs. To install:

```shell
# Installation instructions will depend on your distribution.
# For Arch linux (I use Arch, BTW!):
$ pacman -S tmux bat

# To download the irun.sh script:
$ curl -O -L https://raw.githubusercontent.com/sarvjeets/irun/main/irun.sh
$ chmod +x irun.sh
```
## Usage
To start:

```script
$ ./irun.sh file_containing_shell_commands
```

This will start a tmux session with the command file opened (and first line
highlighted) on the left side and your login shell on the right side.
You can then interactively run commands from the file using the following
keys:
- 'e': Execute the current line/command.
- 'E': Edit the current line before executing.
- 'j': Move to the next line.
- 'k': Move to the previous line.
- 'q': Quit

Anytime in between you can use the tmux session as usual. For example,
you can move to the shell by pressing Ctrl-B ; and then move back to the
command window by pressing Ctrl-B ; again.
