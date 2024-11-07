#!/bin/sh


return
# Check if a command exists or not
SampShell_command_exists () { command -V "${1:?}" >/dev/null 2>&1; }

################################################################################
#                                   Aliases                                    #
################################################################################

## Shorthands for sublime text
alias s=subl ss=ssubl ssubl='subl --create'

# Misc shorthands
alias '%= ' # Let you paste prompts in; zsh lets you alias `$` too.
alias cpu='top -o cpu'

## Spellcheck
alias gti=git sbul=subl ssbul=ssubl

## Listing files
alias ls='ls -AFq' # Always print out `.` files, and for longform, human-readable sizes, and colours
alias ll='ls -l'   # Shorthand for `ls -al`

# Aliases for going up directories
alias ..='cd ..' ...='cd ../..' ....='cd ../../..' .....='cd ../../../..'


# set -m; echo 'todo: set -m'
alias j=jobs
alias k+='kill %+'


## Deleting files
# `rm -d` is in safety.
alias purge='command rm -ridP' ## Purge deletes something entirely
ppurge () { echo "todo: parallelize purging"; }

################################################################################
#                             Changing Directories                             #
################################################################################

# Change directories to the one that contains a file
# We have to do this `printf x` hack in case the dirname ends in a newline...
cdd () {
	if [ "$#" -eq 0 ] || [ "$1" = -h ] || [ "$1" = --help ]; then
		printf 'usage: cdd [-h/--help] [--] filename\n' >&"$(echo "$((1 + ! $#))")"
		return "$((! "$#"))"
	elif [ "$1" = -- ]; then
		shift
	fi

	echo "TODO: no cdpath"

	if SampShell_scratch="$(dirname -- "${1:?need a directory}" && printf x)"; then
		set -- "${SampShell_scratch%?}"
		unset -v SampShell_scratch
		cd -- "$1"
	else
		set -- "$?"
		unset -v SampShell_scratch
		return "$1"
	fi
}

cdtmp () { cd "${SampShell_TMPDIR?}"; }

# Make sure that CDPATH always starts with `:`, so we won't cd elsewhere on accident.
add_to_cd_path () {
	[ "$#" -eq 0 ] && set -- "${PWD}"

	SampShell_scratch=
	until [ "$#" -eq 0 ]; do
		SampShell_scratch="$(realpath -- "$1" && printf x)" || {
			printf 'add_to_cd_path: unable to get realpath of %s' "$1"
			return 1
		}
		CDPATH=":${SampShell_scratch%?x}${CDPATH}"
		shift
	done

	unset -v SampShell_scratch
}

################################################################################
#                                 Command Line                                 #
################################################################################

export PS1='[?$? !!!] $0 ${PWD##"${HOME:+$HOME/}"} $ '

# Clears the screen
cls () {
	SampShell_command_exists clear && { clear || return; }
	printf '\ec\e[3J'
}

################################################################################
#                                   History                                    #
################################################################################
# Make sure `fc` is even around.
if SampShell_command_exists fc; then
	# Set history argument sizes. I want them to be large so I can see them later.
	HISTSIZE=1000000 # how many lines to load into history originally

	# Set HISTFILE if it doesn't exist.
	: "${HISTFILE="${SampShell_HISTDIR:-"${HOME}"}/.sampshell_history"}"

	# Sets up `history` and `h` aliases
	SampShell_command_exists history || alias history='fc -l'
	alias h=history
fi

################################################################################
#                                    macOS                                     #
################################################################################
if SampShell_command_exists pbcopy; then
	# Same as `pbcopy` but will copy its arguments to the pastebin if given.
	pbcopy () {
		if [ "$#" = 0 ]; then
			command pbcopy
		else
			echo "$*" | command pbcopy
		fi
	}

	# Shorthand aliases
	pbcc () { "$@" | pbcopy; } # `pbcopy` execpt it runs a command
	alias pbc=pbcopy
	alias pbp=pbpaste
fi

echo 'todo: caffeinate'

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
#                                    Utils                                     #
################################################################################

# Prints out how many arguments were passed; used in testing expansion syntax.
nargs () { echo "$#"; }

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

ping () { curl --connect-timeout 10 ${1:-http://www.example.com}; }


export SampShell_WORDS="${SampShell_WORDS:-/usr/share/dict/words}"
[ -z "$words" ] && export words="$SampShell_WORDS" # Only set `words` if it doesnt exist

clean_sh () {
	[ -n "$TERM" ] && set -- "TERM=$TERM" "$@"
	env -i SHELL=/bin/sh "HOME=$HOME" "$@" /bin/sh
}

SampShell_reload () {
	if [ "$1" = -- ]; then
		shift
	elif [ "$1" = -h ] || [ "$1" = --help ]; then
		cat <<-EOS
		usage: $0 [--] [file=interactive.sh]
		        Reloads samp shell. \$SampShell_ROOTDIR should be
		        set if file is not absolute.
		EOS
		return 64
	fi

	# Make sure it's not set regardless of what we're loading.
	unset -v SampShell_noninteractive_loaded

	# If it's not an absolute path, then set it.
	if  [ "${1#/}" = "$1" ]; then
		set -- "${SampShell_ROOTDIR?}/${1:-interactive.sh}"
	fi

	. "$1" || return $?
	echo "Reloaded $1"
}

# Same as `.`, except only does it if the file exists.
SampShell_source_optional () {
	until [ "$#" = 0 ]; do
		[ -e "$1" ] && . "$1"
		shift
	done
}

# Same as `.`, except warns if it doesn't exist.
SampShell_source_or_warn () {
	until [ "$#" = 0 ]; do
		if [ -e "$1" ]; then
			. "$1"
		else
			echo "[WARN] Unable to source file: $1" >&2
		fi
		shift
	done
}
