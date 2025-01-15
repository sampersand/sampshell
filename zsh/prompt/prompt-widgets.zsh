function _SampShell-prompt-current-battery {
	emulate -L zsh -o EXTENDED_GLOB

	if ! zstyle -t ':ss:prompt:battery' display &&
	   ! zstyle -T ':ss:prompt:battery' display auto
	then
		return 0
	fi

	local bat perc how remain
	local bat=$(pmset -g batt | sed 1d)

	IFS=' ;' read -r perc how remain <<<${bat#*$'\t'}
	perc=${perc%'%'}

	if   (( perc <= 10 )) then print -n '%K{red}'
	elif (( perc <= 20 )) then print -n '%F{red}'
	elif (( perc <= 40 )) then print -n '%F{yellow}'
	else                       print -n '%F{green}'
	fi

	if [[ $how = charging ]] then print -n 🔌
	elif (( perc <= 20 ))    then print -n 🪫
	else                          print -n 🔋
	fi

	print -n "$perc%%%k" #$remain
}

function _SampShell-prompt-is-airport-power-on () {
	if [[ "$(networksetup -getairportpower en0)" = *Off ||
		"$(networksetup -getairportnetwork en0)" = "You are not associated with an AirPort network." ]]
	then
		print -n '%K{red}🚫🛜%G%k %F{blue}%B|%f%B'
	fi
	# networksetup -setairportpower en0 off
}

RPS1='$(_SampShell-prompt-is-airport-power-on)$(_SampShell-prompt-current-battery)'


