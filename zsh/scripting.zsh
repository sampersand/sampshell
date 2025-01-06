	#### Setup for ZSH script files
# All SampShell ZSH scripts should start with the line `SampShell-script`, which loads in this
# file; it's defined within `env.zsh`.
#
# This file does the following:
#  1. Resets ZSH options relevant to scripting to their defaults
#  2. Removes the `SampShell-script` alias (as it's only needed once)
#  3. Enables "guardrail" features, which disable some potentially dangerous behaviours
#  4. Enables additional features, such as `EXTENDED_GLOB`
#  5. Defines utility functions
####

## Todo, should this always be used? or even be here?
[[ -n ${SampShell_no_experimental-} && -n $SampShell_ROOTDIR ]] && hash -d ss=$SampShell_ROOTDIR

####################################################################################################
#                                            Reset ZSH                                             #
####################################################################################################

## Reset ZSH options to their expected default values, in case something messed with them.
emulate zsh

## Remove the `SampShell-script` alias, as it's only needed once per script.
unalias SampShell-script

####################################################################################################
#                                        Guardrail Options                                         #
####################################################################################################
setopt NO_ALIASES         # Do not use aliases at all when scripting. 
setopt NO_MULTI_FUNC_DEF  # Disables `a b () { ... }`; use `function a b { ... }` instead.
setopt NO_SHORT_LOOPS     # Disallow short-forms of commands in scripts, as they lead to subtle bugs
setopt NO_GLOBAL_EXPORT   # Exporting variables via `typeset -x foo` doesn't also make them global in the script.
setopt WARN_CREATE_GLOBAL # Warn when an assignment in a function creates a global variable
setopt WARN_NESTED_VAR    # Warn when an assignment to a function clobbers an enclosing one.
setopt LOCAL_LOOPS        # Disallow `break`/`continue` from propagating to the parent scope
# setopt NO_UNSET         # Unset variables are errors; I use this often enough it's better to not set it.


####################################################################################################
#                                    Additional Feature Options                                    #
####################################################################################################
setopt RC_QUOTES       # Let you do type `''` within single quotes, eg `'let''s go, friend!'`a
setopt EXTENDED_GLOB   # Enable additional globbing patterns
setopt GLOB_STAR_SHORT # Enable `**.foo` as an alias for `**/*.foo`
setopt SHORT_REPEAT    # Enable short `repeat` form, as it's convenient occasionally

####################################################################################################
#                                        Utility Functions                                         #
####################################################################################################

## Warns the user that something happened; `$ZSH_SCRIPT` is the path to the script, not of this file
function warn {
	print -r -- "[WARN] ${ZSH_SCRIPT:t}:" $@
}

## Prints out an error and then aborts the script. `die` and `abort` are the same fn.
function die abort {
	print -r -- "${ZSH_SCRIPT:t}:" $@
	exit 1
}

## Make the `debug` and `undebug` functions; We need `functions -c` because aliases are disabled.
functions -c SampShell_debug debug
functions -c SampShell_undebug undebug
