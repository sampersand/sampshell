function _SampShell-rps1-current-battery {
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

function _SampShell-rps1-is-airport-power-on () {
	zstyle -T ':sampshell:prompt:airport' display || return 0

	if [[ "$(networksetup -getairportpower en0)" = *Off ||
	      "$(networksetup -getairportnetwork en0)" = "You are not associated with an AirPort network." ]]
	then
		print -n '%K{red}🚫🛜%G%k '
	fi
}

function _SampShell-rps1-ruby-version () {
	zstyle -T ':sampshell:prompt:ruby-version' display || return 0

	print -n "💎%F{red}$(ruby -v | awk '{print $2}')%f "
}

RPS1='$(_SampShell-rps1-ruby-version)$(_SampShell-rps1-is-airport-power-on)$(_SampShell-rps1-current-battery)'
