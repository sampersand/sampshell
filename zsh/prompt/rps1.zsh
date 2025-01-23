### Config for the `RPS1` prompt, i.e. the thing that's shown on the right-hand-side of the screen.
# This file isn't as nearly fleshed out as `ps1.zsh` is, and I may add or subtract to it over time.
#
# Like `ps1.zsh`, it also uses `zstyle` for displaying things.
#
# The `RPS1` is intended for things that are more transient (eg battery level), and don't need to be
# referenced later on after a command's been entered (unlike, eg, a history option.) However, this
# is not a hard-and-fast rule, and it's really just "newer ideas go into RPS1 as PS1 is filled up".
###

## Remove RPS1 when a line is accepted. (Makes it easier to copy stuff.)
setopt TRANSIENT_RPROMPT

## Mark `RPS1` as global (so functions can interact with it), but not exported (as then other shells
# would inherit it, and they certainly don't understand the formatting), and initialize it to an
# empty string (so we can construct it down below)
typeset -g +x RPS1=''

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

## Helper for whether wifi is even on.
function _SampShell-prompt-is-airport-power-on () {
	emulate -L zsh # Reset the shell to the default ZSH options

	zstyle -T ':sampshell:prompt:airport' display || return 0

	SampShell_does_command_exist networksetup || return 0 # networksetup must be defined

	if [[ "$(networksetup -getairportpower en0)" = *Off ||
	      "$(networksetup -getairportnetwork en0)" = "You are not associated with an AirPort network." ]]
	then
		print -n '%K{red}🚫🛜%G%k '
	fi
}

## Helper for the current ruby version
function _SampShell-prompt-ruby-version () {
	emulate -L zsh # Reset the shell to the default ZSH options

	zstyle -T ':sampshell:prompt:ruby-version' display || return 0
	SampShell_does_command_exist ruby || return 0 # ruby must be defined

	print -n "💎%F{red}$(ruby -v | awk '{print $2}')%f "
}

## Just construct the entire RPS1 whole-cloth.
RPS1='$(_SampShell-prompt-ruby-version)$(_SampShell-prompt-is-airport-power-on)$(_SampShell-prompt-current-battery)'
