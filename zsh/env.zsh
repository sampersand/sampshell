#### Basic SampShell definitions for _all_ ZSH shell instances.
# While this file is usually `.`d from the top-level `env.sh` file, it can be `.`d on its own.
#
# Since this file is going to be `source`d for _every_ zsh instance, it should be kept short. Not
# only will this make it faster to load (which speeds up execution of scripts), but also keeps our
# config minimal. Again, this file is `source`d` for EVERY SINGLE ZSH INSTANCE, including scripts
# that we didn't write, so we don't want to do anything that's potentially disruptive!
####

####################################################################################################
#                                           Setup $PATH                                            #
####################################################################################################

typeset -xgU path  # Ensure `path` is unique, and export it.
path+=${0:P:h}/bin # Add our ZSH-only shell functions in 

####################################################################################################
#                                        Universal Options                                         #
####################################################################################################

## Options that should always be set. While this _could_ theoretically break scripts I download, I
# think it's really their fault if they break on these two super simple options.
setopt EXTENDED_GLOB   # Always have extended globs enabled, without needing to set it.
setopt GLOB_STAR_SHORT # Enable the `**.c` shorthand for `**/*.c`

####################################################################################################
#                                         SampShell-script                                         #
####################################################################################################

## Define the `SampShell-script` alias, which is intended to be put at the very top of all scripts I
# write. It ensures some sane default options, turns on a lot of "guardrail" options, and provides 
# some util functions. See `zsh/scripting.zsh` for details.
#
# This is only enabled in non-interactive shells, as interactive shells aren't scripts.
[[ ! -o INTERACTIVE ]] && alias SampShell-script="source ${(q)0:P:h}/scripting.zsh"

####################################################################################################
#                                       SampShell_{un,}debug                                       #
####################################################################################################

## Re-define the `SampShell_debug` and `SampShell_undebug` functions that were previously declared
# in `posix/env.sh`. Because ZSH has more debugging options, we want to make sure we use the same
# name so that POSIX-compliant scripts run under ZSH will automatically use the enhanced debug fns.
#
# ZSH is annoying, however, as `setopt XTRACE` only lasts until the end of the function it's set in,
# and there's literally no way to change that. The best "solution" I have found is to set an EXIT
# trap, which are run within the calling function's context, and in the trap set the XTRACE option.
# Not great, especially since when the calling function returns `XTRACE` is unset :-/. Alas, ZSH.
# (We actually set all the options in the trap, as we `setopt LOCAL_OPTIONS` so we can have local
# traps.)
#
# Note that, just like the POSIX versions of these, these will not restore the options in their
# surrounding environment when `undebug` is called. While I could maybe do that one day (eg by using
# a stack for old options or something), I haven't used the `debug`/`undebug` functions enough to
# warrant delving into that. Possible future TODO?
function SampShell_debug {
	setopt LOCAL_OPTIONS LOCAL_TRAPS
	export SampShell_VERBOSE=1 SampShell_TRACE=1
	trap 'setopt XTRACE VERBOSE WARN_CREATE_GLOBAL WARN_NESTED_VAR' EXIT
}
function SampShell_undebug {
	setopt LOCAL_OPTIONS LOCAL_TRAPS
	unset SampShell_VERBOSE SampShell_TRACE
	trap 'unsetopt XTRACE VERBOSE WARN_CREATE_GLOBAL WARN_NESTED_VAR' EXIT
}

####################################################################################################
#                                     Respect SampShell_TRACE                                      #
####################################################################################################

## Respect `SampShell_TRACE` in all scripts, regardless of whether they're a SampShell script.
# We want this as the last thing in this file, so we don't print traces for the other setup config.
if [[ -n $SampShell_TRACE ]]; then
	export SampShell_TRACE # in case it's not already exported for some weird reason
	setopt SOURCE_TRACE XTRACE VERBOSE
fi
