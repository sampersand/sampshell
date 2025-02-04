### Config for the `RPS1` prompt, i.e. the thing that's shown on the right-hand-side of the screen.
# This file isn't as nearly fleshed out as `ps1.zsh` is, and I may add or subtract to it over time.
#
# Like `ps1.zsh`, it also uses `zstyle` for displaying things.
#
# The `RPS1` is intended for things that are more transient (eg battery level), and don't need to be
# referenced later on after a command's been entered (unlike, eg, a history option.) However, this
# is not a hard-and-fast rule, and it's really just "newer ideas go into RPS1 as PS1 is filled up".
###

####################################################################################################
#                                              Setup                                               #
####################################################################################################

## Remove RPS1 when a line is accepted. (Makes it easier to copy stuff.)
setopt TRANSIENT_RPROMPT

## Mark `RPS1` as global (so functions can interact with it), but not exported (as then other shells
# would inherit it, and they certainly don't understand the formatting), and initialize it to an
# empty string (so we can construct it down below)
typeset -g +x RPS1=''

## Don't indent the right prompt. (Normally set to `1` b/c some terminals don't handle it properly,
# but Terminal.app on macOS does, so I've set it to 0.)
# ZLE_RPROMPT_INDENT=0 <-- actually, it does screw up sometimes afaict... lol

####################################################################################################
#                                         Current Battery                                          #
####################################################################################################

## Helper for the current battery status
function _SampShell-prompt-current-battery {
	emulate -L zsh # Reset the shell to the default ZSH options

	zstyle -T ':sampshell:prompt:battery' display || return 0

	local bat perc how remain

	bat=$(pmset -g batt | sed 1d)
	IFS=' ;' read -r perc how remain <<<${bat#*$'\t'}
	perc=${perc%'%'}

	if   (( perc <= 10 )) then print -n '%F{red}%S'
	elif (( perc <= 20 )) then print -n '%F{red}'
	elif (( perc <= 40 )) then print -n '%F{yellow}'
	else                       print -n '%F{green}'
	fi

	if [[ $how = charging ]] then print -n 🔌
	elif (( perc <= 20 ))    then print -n 🪫
	else                          print -n 🔋
	fi

	print -n "$perc%%%k%s" #$remain
}

####################################################################################################
#                                         Is Wifi Enabled                                          #
####################################################################################################

## Helper for whether wifi is even on.
function _SampShell-prompt-is-airport-power-on () {
	emulate -L zsh # Reset the shell to the default ZSH options

	zstyle -T ':sampshell:prompt:airport' display || return 0

	whence networksetup >/dev/null || return 0 # networksetup must be defined

	if [[ "$(networksetup -getairportpower en0)" = *Off ||
	      "$(networksetup -getairportnetwork en0)" = "You are not associated with an AirPort network." ]]
	then
		print -n '%K{red}🚫🛜%G%k '
	fi
}

####################################################################################################
#                                       Current Ruby Version                                       #
####################################################################################################

## Helper for the current ruby version
function _SampShell-prompt-ruby-version () {
	emulate -L zsh # Reset the shell to the default ZSH options

	zstyle -T ':sampshell:prompt:ruby-version' display || return 0
	whence ruby >/dev/null || return 0 # ruby must be defined

	print -n "💎%F{red}$(ruby -v | awk '{print $2}')%f "
}

####################################################################################################
#                                    Previous Command Duration                                     #
####################################################################################################

zmodload -F zsh/datetime p:EPOCHREALTIME # <-- todo, could this be worthwhile for `strftime`
typeset -FH _SampShell_last_exec_time=0

# Add this to the end of preexec so we don't get all the other functions
preexec_functions+=(_SampShell-prompt-set-start-time-hook)
function _SampShell-prompt-set-start-time-hook {
	_SampShell_last_exec_time=$EPOCHREALTIME
}

# Add this as the very first precmd function, so that we get more accurate timing.
precmd_functions[1,0]=_SampShell-prompt-display-time-hook
function _SampShell-prompt-display-time-hook {
	# Get the current duration as soon as possible
	float now=$EPOCHREALTIME

	(( _SampShell_last_exec_time )) || return
	float diff='now - _SampShell_last_exec_time'

	# Make it red if the difference is more than 3s
	psvar[4]=
	(( diff > 1 )) && psvar[4]=1

	float -F5 seconds='diff % 60'
	integer minutes='(diff /= 60) % 60'
	integer hours='(diff /= 60) % 24'
	integer days='(diff /= 24)'

	local tmp
	(( days )) && tmp+=${days}d
	(( hours )) && tmp+=${tmp:+ }${hours}h
	(( minutes )) && tmp+=${tmp:+ }${minutes}m
	psvar[3]=${tmp:+ }${seconds}s

	_SampShell_last_exec_time=
}

## Just construct the entire RPS1 whole-cloth.
RPS1='$(_SampShell-prompt-ruby-version)$(_SampShell-prompt-is-airport-power-on)$(_SampShell-prompt-current-battery)'
RPS1+=" %f[%F{%(4V.red.green)}%3v%f]"
