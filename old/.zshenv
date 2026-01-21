# This is no longer necessary; it once also held definitions for "debug" stuff,
# but I didn't use those and removed them. now, I haven't used it in so long that
# it's kinda pointless

#### Basic SampShell definitions for _all_ ZSH shell instances.
# Since this file is going to be `source`d for _every_ zsh instance, it should be kept short. Not
# only will this make it faster to load (which speeds up execution of scripts), but also keeps our
# config minimal. Again, this file is `source`d` for EVERY SINGLE ZSH INSTANCE, including scripts
# that we didn't write, so we don't want to do anything that's potentially disruptive!
#
# ZSH executes `.zshenv`s for every script invocation, regardless of whether it's interactive.
####

# If SampShell_DISABLED is set to a non-empty value, then don't do any setup
[[ -n ${SampShell_DISABLED-} ]] && return

####################################################################################################
#                                  Enable Profiling if Requested                                   #
####################################################################################################

## If the `$SampShell_PROFILE` variable is defined and nonempty, then we enable profiling.
# (We eval it so we doesn't parse it if it's not profiling)
[[ -n ${SampShell_PROFILE-} ]] && eval '
zshexit_functions+=(_SampShell_profile_exit)
function _SampShell_profile_exit { zprof }
zmodload zsh/zprof'

####################################################################################################
#                                         Set Debug Prompt                                         #
####################################################################################################

# Set the debug prompt to something a bit more informative than the default
if [[ $PS4 == '+%N:%I> ' ]] then
	PS4='+%x:%N:%I> '
fi

####################################################################################################
#                                          Enable xtrace                                           #
####################################################################################################

## Enable XTRACE if the `SampShell_XTRACE` option was set.
if [[ -n ${SampShell_XTRACE-} ]] then
	export SampShell_XTRACE # Export it in case it's not already exported.
	setopt XTRACE
fi
