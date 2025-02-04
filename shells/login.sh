################################################################################
#                                                                              #
#                  Ensure $SampShell_ROOTDIR is set and valid                  #
#                                                                              #
################################################################################

if [ -n "${SampShell_ROOTDIR-}" ]; then
	# Already setup, nothing to do.
	:
elif [ -n "${ZSH_VERSION-}" ]; then
	# ZSH: just use the builtin `${0:P:h}` to find it; gotta use eval b/c
	# this isn't valid syntax.
	eval 'SampShell_ROOTDIR=${0:P:h}'
elif [ -n "${BASH_SOURCE-}" ]; then
	# BASH: Use `BASH_SOURCE` (the path to this file) to get it. We need to
	# use the `&& printf x` trick, because there's no nicer way to do it.
	eval '
	SampShell_ROOTDIR=$(dirname -- "$BASH_SOURCE" && printf x) || return
	SampShell_ROOTDIR=$(realpath -- "${SampShell_ROOTDIR%?x}" && printf x) || return
	SampShell_ROOTDIR=${SampShell_ROOTDIR%?x}'
else
	# We are interactive, guess a default (hope it works) and warn.
	SampShell_ROOTDIR=$HOME/.sampshell/shell
	printf >&2 '[WARN] Defaulting $SampShell_ROOTDIR to %s\n' "$SampShell_ROOTDIR"
fi

## Warn if `SampShell_ROOTDIR` isn't a directory, and we're in interactive mode.
if [ ! -d "$SampShell_ROOTDIR" ]; then
	printf >&2 '[WARN] $SampShell_ROOTDIR does not exist/isnt a dir: %s\n' "$SampShell_ROOTDIR"
fi

# Ensure `SampShell_ROOTDIR` is exported if it wasn't already.
export SampShell_ROOTDIR

################################################################################
#                                                                              #
#                           Other Exported Variables                           #
#                                                                              #
################################################################################

## SampShell Variables.
: "${SampShell_gendir:=${SampShell_ROOTDIR:-${HOME:-/tmp}}}"
export SampShell_EDITOR="${SampShell_EDITOR:-sublime4}"
export SampShell_TRASHDIR="${SampShell_TRASHDIR:-$SampShell_gendir/.trash}"
export SampShell_HISTDIR="${SampShell_HISTDIR-$SampShell_gendir/.history}"

## Disable homebrew analytics.
# If set, homebrew (the mac package manager) won't send any analytics. We set it
# in `login.sh` and not `interactive.sh` in case any config scripts decide to
# use homebrew themselves. (We _could_ check to see if homebrew is installed,
# but that significantly complicates things, and there's no harm in setting it.)
export HOMEBREW_NO_ANALYTICS=1

################################################################################
#                                                                              #
#                     Prepend SampShell's bin to the $PATH                     #
#                                                                              #
################################################################################

## Add SampShell scripts to the `$PATH`, but make sure it's not already there to
# begin with. (Not strictly necessary, but it helps prevent massive `$PATH`s in
# case SampShell's loaded multiple times.)
SampShell_scratch=$(dirname -- "$SampShell_ROOTDIR" && printf x) || return
SampShell_scratch=${SampShell_scratch%?x}

case :${PATH-}: in
*:"$SampShell_scratch/bin":*) :               ;; # Already there; do nothing
*) PATH=$SampShell_scratch/bin${PATH:+:}$PATH ;; # It doesn't exist. Prepend it.
esac

## Add in "experimental" scripts I'm working on and haven't quite completed.
[ -z "${SampShell_no_experimental-}" ] && case $PATH in
*:"$SampShell_scratch/experimental":*) : ;;
*) PATH=$SampShell_scratch/experimental:$PATH ;;
esac

unset -v SampShell_scratch

## Ensure `PATH` is exported so other programs we execute get our changes.
export PATH
