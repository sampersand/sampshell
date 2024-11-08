################################################################################
#                                   Aliases                                    #
################################################################################

## Setup Sublime Text commands, unless it's disabled.
if [ -z "${SampShell_no_subl-}" ]  ; then
	alias s=subl
	alias ss=ssubl
	alias ssubl='subl --create'

	## Spellchecks
	alias sbul=subl
	alias ssbul=ssubl
fi

## Listing files
alias ls='ls -AFq' # Always print out `.` files, and for longform, human-readable sizes, and colours
alias ll='ls -l'   # Shorthand for `ls -al`

# set -m; echo 'todo: set -m'
alias j=jobs
alias k+='kill %+'

# Aliases for going up directories
alias cdd=SampShell_cdd
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
cdtmp () { cd "${SampShell_TMPDIR?}"; }

## Misc
alias '%= ' # Let you paste prompts in; zsh lets you alias `$` too.

################################################################################
#                                   CD Path                                    #
################################################################################

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

# [ -n "$SampShell_TMPDIR" ] && add_to_cd_path "$HOME"

################################################################################
#                                 Command Line                                 #
################################################################################

# Clear the screen; also uses the `clear` command if it exists
cls () {
	SampShell_command_exists clear && { clear || return; }
	printf '\ec\e[3J'
}

# Sets the prompt unless `SampShell_dont_set_PS1` is explicitly set
if [ -z "${SampShell_dont_set_PS1-}" ]; then
	export PS1='[?$? !!!] $0 ${PWD##"${HOME:+"$HOME"/}"} $ '
fi

################################################################################
#                                   History                                    #
################################################################################

# Make sure `fc` is even around.
SampShell_setup_history=1
if [ -n "${SampShell_setup_history-}" ]; then
	# Set history argument sizes. I want them to be large so I can see them later.
	# how many lines to load into history originally
	HISTSIZE=1000000

	# Setup the histfile only if it doesnt exist; if it exists and is empty,
	# do not set it up.
	if [ -z "${HISTFILE+1}" ]; then
		HISTFILE=${SampShell_HISTDIR:-"$HOME"}/.sampshell_history
	fi
fi

# Sets up `history` and `h` aliases
SampShell_command_exists history || alias history='fc -l'
alias h=history

################################################################################
#                                macOS-specific                                #
################################################################################
if SampShell_command_exists pbcopy; then
	# Same as `pbcopy` but will copy its arguments to the pastebin if given.
	pbc () {
		if [ "$#" = 0 ]; then
			command pbcopy
		else
			echo "$*" | command pbcopy
		fi
	}

	# Shorthand aliases
	pbcc () { "$@" | pbcopy; } # `pbcopy` execpt it runs a command
	alias pbp=pbpaste
fi

[ -n "${SampShell_print_todos-}" ] && echo 'todo: caffeinate'

################################################################################
#                                Safety First!                                 #
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

ping () { curl --connect-timeout 10 ${1:-http://www.example.com}; }


export SampShell_WORDS="${SampShell_WORDS:-/usr/share/dict/words}"
[ -z "$words" ] && export words="$SampShell_WORDS" # Only set `words` if it doesnt exist

clean_shell () {
	env -i SHELL="${clean_sh_shell:-/bin/sh}" "HOME=$HOME" "$@" "${clean_sh_shell:-/bin/sh}"
}

clean_sh () {
	[ -n "$TERM" ] && set -- "TERM=$TERM" "$@"
	env -i SHELL="${clean_sh_shell:-/bin/sh}" "HOME=$HOME" "$@" "${clean_sh_shell:-/bin/sh}"
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
