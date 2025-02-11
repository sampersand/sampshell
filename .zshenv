#### Basic SampShell definitions for _all_ ZSH shell instances.
# Since this file is going to be `source`d for _every_ zsh instance, it should be kept short. Not
# only will this make it faster to load (which speeds up execution of scripts), but also keeps our
# config minimal. Again, this file is `source`d` for EVERY SINGLE ZSH INSTANCE, including scripts
# that we didn't write, so we don't want to do anything that's potentially disruptive!
#
# ZSH executes `.zshenv`s for _every_ script invocation, regardless of whether it's interactive or not.
####

# Load universal options.
emulate sh -c '. "$SampShell_ROOTDIR/env.sh"'

####################################################################################################
#                                  Enable Profiling if Requested                                   #
####################################################################################################

## If the `$SampShell_PROFILE` variable is defined and nonempty, then we enable profiling.
# (We eval it so we doesn't parse it if it's not profiling)
[[ -n ${SampShell_PROFILE:-} ]] && eval '
zshexit_functions+=(_SampShell_profile_exit)
function _SampShell_profile_exit { zprof }
zmodload zsh/zprof'

####################################################################################################
#                                         Set Debug Prompt                                         #
####################################################################################################

# Set the debug prompt to something a bit more informative. I'm still not sure how much I like this.
[[ -n ${Sampshell_EXPERIMENTAL:-} ]] && PS4='+%x:%N:%I> '

## Set sourcetrace prompt (temporary hack I think)
if [[ -o sourcetrace && -n ${SampShell_SOURCETRACE} ]]; then
	eval "
	typeset -Fg SECONDS
	setopt promptsubst
	PS4='+\$SECONDS:%x:%I> '"
fi

####################################################################################################
#                                       SampShell_{un,}debug                                       #
####################################################################################################
# I've had this around forever, and idk if I still need it?
if [[ -n ${Sampshell_EXPERIMENTAL:-} ]]; then
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
	eval '
	function SampShell_debug {
		setopt LOCAL_OPTIONS LOCAL_TRAPS
		export SampShell_XTRACE=1
		trap "setopt XTRACE VERBOSE WARN_CREATE_GLOBAL WARN_NESTED_VAR" EXIT
	}

	function SampShell_undebug {
		setopt LOCAL_OPTIONS LOCAL_TRAPS
		unset SampShell_XTRACE
		trap "unsetopt XTRACE VERBOSE WARN_CREATE_GLOBAL WARN_NESTED_VAR" EXIT
	}'
fi
