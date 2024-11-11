###
# Basic SampShell definitions for _all_ interactive POSIX-complaint shells.
#
# This file must be strictly POSIX-compliant, as it will be loaded for POSIX-
# compliant shells. However, unlike `env.sh`, we don't expect this file to be
# `.`d in the middle of scripts with arbitrary settings. As such, we can relax
# the restrictions somewhat (eg, we don't need to do `${var-}` in case the
# `set -u` is enabled).
#
# It's expected that this file will be `.`d after `env.sh` is; as such, all of
# the definitions within `env.sh` are expected to be visible here.
###

################################################################################
#                               Load Other Files                               #
################################################################################

## Load files that aren't "core" to SampShell, but are nice to have.
# These files are loaded only if some precondition is met, such as only loading
# the "git" config if the `git` command is found.

# Load the git config, if git is found
if SampShell_command_exists git; then
	SampShell_dot_if_exists "$SampShell_ROOTDIR/posix/extended/git.sh"
fi

# Load experimental changes, if experimental is defined
if [ -n "$SampShell_experimental" ]; then
	SampShell_dot_if_exists "$SampShell_ROOTDIR/posix/extended/experimental.sh"
fi

# Setup the editor if it exists
if [ -n "$SampShell_EDITOR" ]; then
	SampShell_dot_if_exists "$SampShell_ROOTDIR/posix/extended/editor.sh"
fi

################################################################################
#                                    Safety                                    #
################################################################################

# Don't clobber files with `>`; must use `>|`
set -o noclobber

# Override builtins with safer versions.
alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'

## Shorthand aliases for the "safer" options
alias r=trash
alias m=mv-safe

# Still let you do the builtins
alias rmm='rm -f'
alias mvv='mv -f'
alias cpp='cp -f'

################################################################################
#                                   Aliases                                    #
################################################################################
## Listing files
alias ls='ls -AFq' # Always print out `.` files, and for longform, human-readable sizes, and colours
alias ll='ls -l'   # Shorthand for `ls -al`

## Misc
alias '%= ' # Let you paste prompts in; zsh lets you alias `$` too.

alias parallelize_it=SampShell_parallelize_it
alias cdd=SampShell_cdd
alias debug=SampShell_debug
alias undebug=SampShell_undebug

# Aliases for going up directories
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# set -m; echo 'todo: set -m'
alias j=jobs

################################################################################
#                             Changing Directories                             #
################################################################################

## Changes to the SampShell tmp directory, creating it unless it exists already.
cdtmp () {
	if ! [ -e "${SampShell_TMPDIR:?}" ]; then
		mkdir -p -- "$SampShell_TMPDIR" || return
	fi

	CPATH= cd -- "$SampShell_TMPDIR/${1-}"
}

## CD to sampshell; if an arg is given it's the suffix to also go to
cdss () {
	CDPATH= cd -- "${SampShell_ROOTDIR?}/${1-}";
}

## Adds the arguments to the `CDPATH`. This function makes sure that `CDPATH`
# always starts with a `:`, so we won't accidentally cd elsewhere on accident.
add_to_cd_path () {
	if [ "$#" -eq 0 ]; then
		echo 'usage: add_to_cd_path path [more ...]' >&2
		return 64
	fi

	SampShell_scratch=
	while [ "$#" -ne 0 ]; do
		SampShell_scratch=$(realpath -- "$1" && printf x) || {
			printf 'add_to_cd_path: unable to get realpath of %s' "$1" >&2
			return 1
		}
		CDPATH=":${SampShell_scratch%?x}${CDPATH}"
		shift
	done

	unset -v SampShell_scratch
	return 0
}

################################################################################
#                                 Command Line                                 #
################################################################################

# Clear the screen; also uses the `clear` command if it exists
cls () {
	SampShell_command_exists clear && { clear || return; }
	printf '\ec\e[3J'
}

PS1='[!!! | ?$?] ${PWD##"${HOME:+"$HOME"/}"} ${0##*/}$ '

################################################################################
#                                   History                                    #
################################################################################

# Only default the history-related variables if they're unset; if they're set
# to an empty value, that indicates that history usage isn't desired.

if [ -z "${HISTSIZE+1}" ]; then
	HISTSIZE=500 # How many history entries to keep
elif [ -z "$HISTSIZE" ]; then
	SampShell_log '[INFO] Not defaulting HISTSIZE; it is set to the empty string'
fi

if [ -z "${HISTFILE+1}" ]; then
	if [ -n "${SampShell_HISTDIR+1}" ] && [ -z "$SampShell_HISTDIR" ]; then
		SampShell_log '[INFO] Not setting HISTFILE; SampShell_HISTDIR is set to the empty string'
	else
		HISTFILE=${SampShell_HISTDIR-$HOME}/.sampshell_history
	fi
else
	SampShell_log '[INFO] Not defaulting HISTFILE; it is set to the empty string'
fi

SampShell_command_exists history || eval 'history () { fc -l "$@"; }'

# `h` is a shorthand for listing out history; we negate the arg because it goes
# from the end.
h () { fc -l "$(( -${1:-16} ))"; }

################################################################################
#                                    Utils                                     #
################################################################################
# Prints out how many arguments were passed; used in testing expansion syntax.
nargs () { echo "$#"; }

alias cpu='top -o cpu'

## Deleting files
# `rm -d` is in safety.
alias purge='command rm -ridP' ## Purge deletes something entirely
ppurge () { echo "todo: parallelize purging"; }

alias pargs=prargs
prargs () {
	SampShell_scratch=0

	until [ "$#" = 0 ]; do
		SampShell_scratch=$((SampShell_scratch + 1))
		printf '%3d: %s\n' "$SampShell_scratch" "$1"
		shift
	done

	unset -v SampShell_scratch
}

export SampShell_WORDS="${SampShell_WORDS:-/usr/share/dict/words}"
[ -z "$words" ] && export words="$SampShell_WORDS" # Only set `words` if it doesnt exist

clean_shell () {
	[ "$#" -eq 0 ] && set -- /bin/sh
	[ -n "${TERM+1}" ] && set -- "TERM=$TERM" "$@"
	[ -n "${HOME+1}" ] && set -- "HOME=$HOME" "$@"
	[ -n "${SHLVL+1}" ] && set -- "SHLVL=$SHLVL" "$@"
	env -i "$@"
}

## Reloads all configuration files
# This is the same as `SampShell_reload` so that it's easy to replace, as
# opposed to an alias.
reload () { SampShell_reload "$@"; }

## Reloads SampShell.
# If given an argument, it `.`s `$SampShell_ROOTDIR/<arg>` and returns. If
# given no arguments, it first `.`s `$ENV` if it exists, and then will `.` all
# of SampShell (via `$SampShell_ROOTDIR/both`).
SampShell_reload () {
	if [ "$1" = -- ]; then
		shift
	elif [ "$1" = -h ] || [ "$1" = --help ]; then
		cat <<-'EOS'
		usage: SampShell_reload [--] path
		       SampShell_reload [-h/--help]

		In the first form, sources '$SampShell_ROOTDIR/<path>' and returns.
		In the second, sources '$ENV' if it exists, then '$SampShell_ROOTDIR/both'
		EOS
		return 64
	fi

	: "${SampShell_ROOTDIR?SampShell_ROOTDIR must be supplied}"

	# If we're given an argument, then that's the only thing to reload; do that,
	# and return.
	if [ "$#" -ne 0 ]; then
		set -- "$SampShell_ROOTDIR/$1"
		printf 'Reloading SampShell file: %s\n' "$1"
		. "$1"
		return
	fi

	set -- "$SampShell_ROOTDIR/both"

	# We've been given no arguments. First off, reload `$ENV` if it's present.
	if  [ -n "$ENV" ]; then
		# On the off chance that `$ENV` is `$SampShell_ROOTDIR/both`, don't reload
		# SampShell twice.
		if [ "$1" -ef "$ENV" ]; then
			echo 'Not loading $ENV; same as SampShell'
		else
			printf 'Reloading $ENV: %s\n' "$ENV"
			. "$ENV" || return
		fi
	fi

	# Now reload all of sampshell
	printf 'Reloading SampShell: %s\n' "$1"
	. "$1"
}