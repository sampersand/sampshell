#!zsh

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

	zstyle ':sampshell:prompt:time:' format '%_I:%M:%S %p' # The time format

	zstyle ':sampshell:prompt:jobcount:' display auto # true: always display. auto: only if > 0
	zstyle ':sampshell:prompt:shlvl:'    display auto # true: always display. auto: only if > 1

	zstyle ':sampshell:prompt:userhost:' display auto # true: always display. auto: dont display if expected equal
	zstyle ':sampshell:prompt:hostname:' expected # not set by default; if it and username are set, and
	zstyle ':sampshell:prompt:username:' expected # ..equal to the machine, nothing. if not, red & bold.

	zstyle ':sampshell:prompt:path:' display # true: always display full path
	zstyle ':sampshell:prompt:path:' display-partial # true: always display tilde path
	zstyle ':sampshell:prompt:path:' length $((COLUMNS * 2 / 5)) # length of paths before truncation

	zstyle ':sampshell:prompt:git:' display auto # true: always display. auto: only if in a repo
	zstyle ':sampshell:prompt:git:' pattern  # not set by default; if set, used when truncating repo paths.

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
	# PS1='%$((COLUMNS * 3 / 5))>..>'
	PS1+='%B%F{blue}[%b' # `[`

	# Current time
	zstyle -s ':sampshell:prompt:time:' format tmp
	PS1+="%F{cyan}%D{${tmp:-%_I:%M:%S %p}} "

	PS1+='%U%f%!%u '                   # history
	PS1+='%B%F{blue}|%b '              # |
	PS1+='%(?.%F{green}.%F{red})%?'   # previous status code

	## JOB COUNT
	if zstyle -t ':sampshell:prompt:jobcount:' display; then
		PS1+='%F{166} (%j job%2(1j.%(2j.s.).s))'
	elif zstyle -T ':sampshell:prompt:jobcount:' display auto; then
		PS1+='%(1j.%F{166} (%j job%(2j.s.)).)'   # [jobs, if more than one]
	fi

	## SHLVL
	if zstyle -t ':sampshell:prompt:shlvl:' display; then
		PS1+=' %F{red}SHLVL=%L'
	elif zstyle -T ':sampshell:prompt:shlvl:' display auto; then
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

	zstyle ':sampshell:prompt:userhost:' display false

	zstyle -s ':sampshell:prompt:userhost:' display tmp
	case $tmp in
	always|1|yes|on|true)
		PS1+=$hostname_grey$hostname_snippet ;;

	auto|default|)
		local hostname username
		if ! zstyle -s ':sampshell:prompt:userhost:hostname:' expected hostname ||
		   ! zstyle -s ':sampshell:prompt:userhost:username:' expected username
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

	PS1+='%F{11}' # We always print the path
	# IE display the full path
	if zstyle -t ':sampshell:prompt:path:' display absolute; then
		PS1+='%d'
	else
		# Get the path length; default to `$COLUMNS / 5`
		zstyle -s ':sampshell:prompt:path:' length tmp || tmp='$((COLUMNS / 5))'

		# No need to check for `0`, as truncation doesn't happen with 0 length.

		PS1+='%-1~'                            # always have the root component
		PS1+="%$tmp</..<"                      # When replacing, make sure to have `/...`
		PS1+='${(*)$(print -P ''%~'')##[^/]#}' # Everything but the root component
		PS1+='%<<'                            # stop replacing
	fi
	PS1+=' '

	################################################################################
	#                                                                              #
	#                               Git information                                #
	#                                                                              #
	################################################################################

	() {
		local always
		if ! zstyle -b ':sampshell:prompt:git:' display always &&
		   ! zstyle -T ':sampshell:prompt:git:' display auto
		then
			return 0
		fi

		function _SampShell-ps1-git {
			local always git_info display_type

			psvar[1]= psvar[2]= psvar[3]=

			if ! zstyle -b ':sampshell:prompt:git:' display always &&
			   ! zstyle -T ':sampshell:prompt:git:' display auto branch-only
			then
				# don't display git info ever, so return.
				return
			fi
			zstyle -s ':sampshell:prompt:git:' display display_type

			GIT_PS1_SHOWDIRTYSTATE=1      # Show `*` and `+` for untracted states
			# GIT_PS1_SHOWSTASHSTATE=1    # Don't show `$` when there's something stashed, as i do it a lot
			GIT_PS1_SHOWUNTRACKEDFILES=1  # Also show untracted files via `%`
			GIT_PS1_SHOWCONFLICTSTATE=1   # Show when there's a merge conflict
			GIT_PS1_HIDE_IF_PWD_IGNORED=1 # Don't show git when the PWD is ignored.
			GIT_PS1_STATESEPARATOR=       # Don't put anything after the branch name

			[[ -n $SampShell_no_experimental ]] && GIT_PS1_SHOWUPSTREAM=auto    # IDK IF I need this

			git_info=$(__git_ps1 %s)
			if [[ -z $git_info ]] then
				[[ $always = yes ]] && psvar[3]='(no repo) '
				return
			fi

			psvar[1]="$git_info "
			if [[ $always != yes ]] && zstyle -s ':sampshell:prompt:git:' pattern pattern; then
				git_info=${git_info/${~pattern}/..}
			fi
			psvar[2]="$git_info "
		}

		add-zsh-hook precmd _SampShell-ps1-git
		[[ $always = yes ]] && PS1+="%F{red}%3v"
		PS1+="%F{043}%\$((COLUMNS *3/ 4))(l.%1v.%2v)"
	} ${0:P:h}

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
