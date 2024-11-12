. ${0:P:h}/old/env.zsh

####################################################################################################
#                                            Setup Path                                            #
####################################################################################################

typeset -xgU path # Ensure `path` is unique, and export it.

path+=${0:P:h}/bin # add the ZSH bin in.

####################################################################################################
#                                        Universal Options                                         #
####################################################################################################

setopt EXTENDED_GLOB   # Always have extended globs enabled, without needing to set it.
setopt GLOB_STAR_SHORT # Enable the `**.c` shorthand for `**/*.c`
setopt RC_QUOTES       # Let you do type `''` within single quotes, eg `'let''s go to the store!'`

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
SampShell_log 'todo: SampShell-debug with xtrace'

####################################################################################################
#                                       SampShell Functions                                        #
####################################################################################################

## Options I want enabled for scripts I write; this should be put at the top of every script
function SampShell-use-strict {
	setopt WARN_CREATE_GLOBAL # Warn when an assignment in a function creates a global variable
	setopt WARN_NESTED_VAR    # Warn when an assignment to a function clobbers an enclosing one.
	setopt NO_GLOBAL_EXPORT   # `typeset -x foo` no longer makes variables global.
	setopt NO_ALIASES         # Do not use aliases at all.
	setopt NO_ALIAS_FUNC_DEF  # `alias a=b; a () ...`  will still define the function `a`, not `b`.
	setopt NO_MULTI_FUNC_DEF  # Disables `a b c () { ... }`; use `function x y z { ... }` instead.
}

## Enable debug mode.
# Note that `functions -c old new` copies the definition from `old` to `new`. We want this so that
# we can overwrite the `SampShell_debug` method to also set ZSH debugging options, but also be able
# to use its old definition within the new one. If ZSH had `super` like from OOP, we'd use that instead.
functions -c SampShell_debug SampShell_POSIX_debug
function SampShell{-,_}debug {
	SampShell_POSIX_debug && setopt SOURCE_TRACE WARN_CREATE_GLOBAL WARN_NESTED_VAR
}

## Disable debug mode
functions -c SampShell_undebug SampShell_POSIX_undebug
function SampShell{-,_}undebug {
	SampShell_POSIX_undebug && unsetopt SOURCE_TRACE WARN_CREATE_GLOBAL WARN_NESTED_VAR
}

####################################################################################################
#                                     Respect SampShell_TRACE                                      #
####################################################################################################

# Note we add `SOURCE_TRACE` in addition to the `-x` and `-v` POSIX shells have.
if [[ -n $SampShell_TRACE ]]; then
	setopt SOURCE_TRACE XTRACE VERBOSE
	export SampShell_TRACE # in case it's not already exported for some weird reason
fi

