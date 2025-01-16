#!zsh

## Customizing the prompt
# The prompt can be customized using `zstyle`, eg `zstyle :sampshell:prompt:shlvl: display tue`
#

## Options for the prompt, only set the singular required one (prompt_subst)
setopt PROMPT_SUBST        # Lets you use variables and $(...) in prompts.
unsetopt PROMPT_BANG       # Don't make `!` mean history number; we do this with %!.
unsetopt NO_PROMPT_PERCENT # Ensure `%` escapes in prompts are enabled.
unsetopt NO_PROMPT_CR      # Ensure a `\r` is printed before a line starts

# The following are the zstyles that're used, and their defaults
if false; then
	# if `1`/`on`/`yes`/`true`, always display, if auto, do default as if it were unset. if
	# anything else, disable
	zstyle ':sampshell:prompt:*' display

	zstyle ':sampshell:prompt:time' format '%_I:%M:%S %p' # The time format

	zstyle ':sampshell:prompt:jobcount' display auto # true: always display. auto: only if > 0
	zstyle ':sampshell:prompt:shlvl'    display auto # true: always display. auto: only if > 1

	zstyle ':sampshell:prompt:userhost' display auto # true: always display. auto: dont display if expected equal
	zstyle ':sampshell:prompt:hostname' expected # not set by default; if it and username are set, and
	zstyle ':sampshell:prompt:username' expected # ..equal to the machine, nothing. if not, red & bold.

	zstyle ':sampshell:prompt:path' display # if set to `always`, display the full path. Unable to be disabled.
	zstyle ':sampshell:prompt:path' length $((COLUMNS * 2 / 5)) # length of paths before truncation

	zstyle ':sampshell:prompt:git' display auto # true: always display. auto: only if in a repo
	zstyle ':sampshell:prompt:git' pattern  # not set by default; if set, used when truncating repo paths.

fi

# zstyle ':sampshell:prompt:*' display 1


# Mark `PS1` and `RPS1` as global, but not exported, so other shells don't inherit them.
typeset -g +x PS1 RPS1

source ${0:P:h}/prompt-widgets.zsh
source ${0:P:h}/git_prompt.sh

## The function to create the prompt. Takes no arguments, as everything's done via zstyle.
function SampShell-create-prompt {
	local tmp
	################################################################################
	#                                                                              #
	#                                Bracket Prefix                                #
	#                                                                              #
	################################################################################
	PS1= # Clear PS1
	PS1+='%B%F{blue}[%b' # `[`

	# Current time
	zstyle -s ':sampshell:prompt:time' format tmp
	PS1+="%F{cyan}%D{${tmp:-%_I:%M:%S %p}} "

	PS1+='%U%f%!%u '                   # history
	PS1+='%B%F{blue}|%b '              # |
	PS1+='%(?.%F{green}.%F{red})%?'   # previous status code

	## JOB COUNT
	if zstyle -t ':sampshell:prompt:jobcount' display; then
		PS1+='%F{166} (%j job%2(1j.%(2j.s.).s))'
	elif zstyle -T ':sampshell:prompt:jobcount' display auto; then
		PS1+='%(1j.%F{166} (%j job%(2j.s.)).)'   # [jobs, if more than one]
	fi

	## SHLVL
	if zstyle -t ':sampshell:prompt:shlvl' display; then
		PS1+=' %F{red}SHLVL=%L'
	elif zstyle -T ':sampshell:prompt:shlvl' display auto; then
		PS1+='%(2L. %F{red}SHLVL=%L.)' # [shellevel, if more than 1]
	fi

	PS1+='%B%F{blue}]%b ' # ]

	################################################################################
	#                                                                              #
	#                            Username and Hostname                             #
	#                                                                              #
	################################################################################
	readonly hostname_snippet='%n@%m '
	readonly hostname_grey='%F{242}'

	zstyle -s ':sampshell:prompt:userhost' display tmp
	case $tmp in
	always|1|yes|on|true)
		PS1+=$hostname_grey$hostname_snippet ;;

	auto|default|)
		local hostname username
		if ! zstyle -s ':sampshell:prompt:userhost:hostname' expected hostname ||
		   ! zstyle -s ':sampshell:prompt:userhost:username' expected username
		then
			# One of the two `hostname`/`username` are missing, print out in grey.
			PS1+=$hostname_grey$hostname_snippet
		elif [[ $username != "$(print -P %n)" || $hostname != $(print -P %m) ]] then
			# One of the two doesn't match, uh oh!
			PS1+="%F{red}%B$hostname_snippet%b"
		fi ;;

	0|no|off|false)
		;; # Don't modify
	*)
		SampShell_log 'unknown display value: %s' $tmp
	esac

	################################################################################
	#                                                                              #
	#                                     Path                                     #
	#                                                                              #
	################################################################################

	PS1+='%F{11}' # Add the colour in. (There's no way to disable the path, so add it in here)

	if zstyle -t ':sampshell:prompt:path' display absolute; then
		PS1+='%d'
	else
		# Get the path length; default to `$COLUMNS / 5`. Shortening can be disabled by
		# setting the length to 0.
		zstyle -s ':sampshell:prompt:path' length tmp || tmp='$((COLUMNS / 5))'

		# (No need to check for `0`, as `%0</…<` disables truncation.)
		PS1+='%-1~'                            # always have the root component
		PS1+="%$tmp</…<"                       # start path truncation.
		PS1+='${(*)$(print -P ''%~'')##[^/]#}' # Everything but the root component
		PS1+='%<<'                             # stop truncation
	fi
	PS1+=' ' # Adda space after the path

	################################################################################
	#                                                                              #
	#                               Git information                                #
	#                                                                              #
	################################################################################

	# If we even are even displaying git in the first place? (default to yes with `-T`)
	if zstyle -T ':sampshell:prompt:git' display; then
		function _SampShell-ps1-git {
			psvar[1]= psvar[2]=

			# If we're just not displaying git at all, then return.
			if ! zstyle -T ":sampshell:prompt:git:$PWD" display; then
				echo oh
				return 0
			fi

			if zstyle -T ":sampshell:prompt:git:dirty:$PWD" display; then
				# Show `*` and `+` for untracted states
				local GIT_PS1_SHOWDIRTYSTATE=1
			fi

			# GIT_PS1_SHOWSTASHSTATE=1    # Don't show `$` when there's something stashed, as i do it a lot

			if zstyle -T ":sampshell:prompt:git:untracked:$PWD" display; then
				# Also show untracted files via `%`
				local GIT_PS1_SHOWUNTRACKEDFILES=1
			fi

			if zstyle -T ":sampshell:prompt:git:conflict:$PWD" display; then
				# Show when there's a merge conflict
				local GIT_PS1_SHOWCONFLICTSTATE=1
			fi

			if zstyle -T ":sampshell:prompt:git:hidepwd:$PWD" display; then
				# Don't show git when the PWD is ignored.
				local GIT_PS1_HIDE_IF_PWD_IGNORED=1
			fi

			if zstyle -t ":sampshell:prompt:git:upstream:$PWD" display; then
				# Show the difference fro upstream
				local GIT_PS1_SHOWUPSTREAM=1
			fi

			# Don't put anything after the branch name
			local GIT_PS1_STATESEPARATOR=${GIT_PS1_STATESEPARATOR:-}

			psvar[1]=$(__git_ps1 %s)
			[[ -z $psvar[1] ]] && return
			psvar[1]="⇄${psvar[1]/\%\%/!} "
			psvar[2]=$psvar[1]


			local pattern
			if zstyle -s ":sampshell:prompt:git:$PWD" pattern pattern; then
				psvar[2]=${psvar[2]/${~pattern}/…}
			fi
		}

		# Always run this function before a prompt, instead of adding it as part of the
		# prompt. (This is b/c they're run before the prompt is executed, so there's no
		# way to get the length)
		add-zsh-hook precmd _SampShell-ps1-git

		# Only expand the full thing if there's a significant amount of whitespace left.
		PS1+="%F{043}%\$((COLUMNS /3))(l.%2v.%1v)"

	fi

	################################################################################
	#                                                                              #
	#                                    Finale                                    #
	#                                                                              #
	################################################################################

	PS1+='%F{8}%#%f ' # ending %

	################################################################################
	#                                                                              #
	#                                     RPS1                                     #
	#                                                                              #
	################################################################################
}

	ps1_header () {
		local sep='%F{blue}%B|%f%b'

		echo
		echo -n $sep "$(ruby --version | awk '{print $2}')" $sep '%F{11}%d' $sep ''
		echo -n %y $sep %n@%M $sep "$(_SampShell-prompt-current-battery)" $sep
	}

	# PS1+='$(typeset -f ps1_header >/dev/null && { ps1_header; print })'$'\n'

SampShell-create-prompt
