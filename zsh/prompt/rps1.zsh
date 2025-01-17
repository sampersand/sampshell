function _SampShell-prompt-current-battery {
	emulate -L zsh -o EXTENDED_GLOB

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

function _SampShell-prompt-is-airport-power-on () {
	zstyle -T ':sampshell:prompt:airport' display || return 0

	if [[ "$(networksetup -getairportpower en0)" = *Off ||
	      "$(networksetup -getairportnetwork en0)" = "You are not associated with an AirPort network." ]]
	then
		print -n '%K{red}🚫🛜%G%k '
	fi
}

RPS1='$(_SampShell-prompt-is-airport-power-on)$(_SampShell-prompt-current-battery)'
