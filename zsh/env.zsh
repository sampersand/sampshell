. ${0:P:h}/old/env.zsh

[[ -n $SampShell_TRACE ]] && setopt XTRACE VERBOSE

## Setup `path`
typeset -Uxg path # make sure `path` is unique, and then export it
path+=${0:P:h}/bin


## Options I always want set.
setopt EXTENDED_GLOB   # Always have extended globs without needing to set it
setopt GLOB_STAR_SHORT # Shorthand of `**.c`
setopt RC_QUOTES       # let you do `''` within `'`s to put single quote

## Options I want enabled for scripts I write
function SampShell-use-strict {
	setopt WARN_CREATE_GLOBAL # Warn when an assignment in a function creates a global variable
	setopt WARN_NESTED_VAR    # Warn when an assignment to a function clobbers an enclosing one.
	setopt NO_GLOBAL_EXPORT   # `typeset -x foo` no longer makes variables global.
	setopt NO_ALIASES         # Do not use aliases at all.
	setopt NO_ALIAS_FUNC_DEF  # `alias a=b; a () ...`  will still define the function `a`, not `b`.
	setopt NO_MULTI_FUNC_DEF  # Disables `a b c () { ... }`; use `function x y z { ... }` instead.
}

## Default options that really should be enabled. TODO: should i always set these?
if true || [[ -n $SampShell_set_defaults_i_want_set ]]; then
	setopt BAD_PATTERN     # bad patterns error out
	setopt NOMATCH         # non-matching globs error out.
	setopt EQUALS          # Do `=` expansion
	setopt GLOB            # Why wouldnt you
	setopt NO_{IGNORE_BRACES,IGNORE_CLOSE_BRACES} # make `a () { b }` valid.
	setopt SHORT_LOOPS     # I use this semi-frequently
fi

## Functions I always want visible
echo 'todo: SampShell-debug with xtrace'

## Enable debug mode.
# Note that `functions -c old new` copies the definition from `old` to `new`. We want this so that
# we can overwrite the `SampShell_debug` method to also set ZSH debugging options, but also be able
# to use its old definition within the new one. If ZSH had `super` like from OOP, we'd use that instead.
functions -c SampShell_debug SampShell_POSIX_debug
function SampShell{-,_}debug {
	SampShell_POSIX_debug && \
		setopt {SOURCE_TRACE,UNSET,WARN_CREATE_GLOBAL,WARN_NESTED_VAR}
}

## Disable debug mode
functions -c SampShell_undebug SampShell_POSIX_undebug
function SampShell{-,_}undebug {
	SampShell_POSIX_undebug && \
		setopt NO_{SOURCE_TRACE,UNSET,WARN_CREATE_GLOBAL,WARN_NESTED_VAR}
}
