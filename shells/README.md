# Setup files
- `.profile ` is for login shells, but can be run idempotently. Unless the environment variable `ENV` already exists, it sets it to `interactive.sh`, so that shells without interactive-exclusive startup files (like dash, or yash in posix mode) will read the interactive.sh
- `interactive.sh` is for interactive stuff.
- `env.sh` contains things that shoudl be added to every invocation of a script. In bash, `BASH_ENV` should be set to it, and in zsh, `~/.zshenv` should source it. It's really just for debugging info so `SampShell_XTRACE=1` works, so isn't that critical

env.sh might be just flat-out removed in the future.

## Example $HOME files
```sh
# ZSH Config
~/.zshenv
	. ${SampShell_ROOTDIR:=~/.sampshell/shells}/env.sh
~/.zprofile
	# `$SampShell_ROOTDIR` was already set in `~/.zshenv`
	. $SampShell_ROOTDIR/.profile
~/.zshrc
	. $SampShell_ROOTDIR/interactive.sh

# BASH Config
~/.bash_profile
	# Bash doesn't have a "bash env" startup file, so add here and load it
	export BASH_ENV="${SampShell_ROOTDIR:=~/.sampshell/shells}/env.sh"
	. "$BASH_ENV"
	. "$SampShell_ROOTDIR/.profile"
~/.bashrc
	# `$SampShell_ROOTDIR` was already set in `~/.bash_profile`
	[ -e "$BASH_ENV" ] && . "$BASH_ENV" # Since it's the "universal config" stuff.
	. "$SampShell_ROOTDIR/.interactive.sh"

# Other shells
~/.profile
	. "${SampShell_ROOTDIR:=~/.sampshell/shells}/env.sh"
	. "$SampShell_ROOTDIR/login.sh"

	[ -e "$ENV" ] && . "$ENV" # Load interactive stuff, even tho this is login code.
```
