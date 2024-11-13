false && . ${0:P:h}/old/env.zsh # TODO: remove me

##
# Note that since this file is going to be `.`d from within _all_ ZSH scripts, including anything
# that we may have accidentally installed, we want to make sure we do the bare minimum possible here
# 

## Setup the path
typeset -xgU path # Ensure `path` is unique, and export it.
path+=${0:P:h}/bin # Add our ZSH-only shell functions in 

## Options that are universal 
setopt EXTENDED_GLOB   # Always have extended globs enabled, without needing to set it.
setopt GLOB_STAR_SHORT # Enable the `**.c` shorthand for `**/*.c`
setopt RC_QUOTES       # Let you do type `''` within single quotes, eg `'let''s go to the store!'`

## Define the `SampShell-script` function; It's intended to be put at the very top of all SampShell
# scripts. It turns on a lot of "guardrail" options, as well as some util functions, that we don't
# always want turned on (e.g. in case 3rd party apps dont expect it)
alias SampShell-script="source ${(q)0:P:h}/scripting.zsh"


# ZSH is annoying, in that `set -o xtrace` doesn't actually propagate out of the function that calls it.
# These functions are fairly fundementally flawed in zsh, as it always unsets XTRACE upon leaving a fn.
function SampShell_debug {
	setopt LOCAL_OPTIONS LOCAL_TRAPS

	export SampShell_{VERBOSE,TRACE}=1
	trap 'setopt XTRACE VERBOSE WARN_CREATE_GLOBAL WARN_NESTED_VAR' EXIT
}

function SampShell_undebug {
	setopt LOCAL_OPTIONS LOCAL_TRAPS

	unset SampShell_{VERBOSE,TRACE}
	trap 'unsetopt XTRACE VERBOSE WARN_CREATE_GLOBAL WARN_NESTED_VAR' EXIT
}

## Respect `SampShell_TRACE` in all scripts, regardless of whether they're a SampShell script or not
# Note we want this as the last thing in this file, so that we don't print the traces for the other
# setup.
if [[ -n $SampShell_TRACE ]]; then
	setopt SOURCE_TRACE XTRACE VERBOSE
	export SampShell_TRACE # in case it's not already exported for some weird reason
fi
