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
	zstyle ':ss:prompt:*' display

	zstyle ':ss:prompt:time:' format '%_I:%M:%S %p' # The time format

	zstyle ':ss:prompt:jobcount:' display auto # true: always display. auto: only if > 0
	zstyle ':ss:prompt:shlvl:'    display auto # true: always display. auto: only if > 1

	zstyle ':ss:prompt:userhost:' display auto # true: always display. auto: dont display if expected equal
	zstyle ':ss:prompt:hostname:' expected # not set by default; if it and username are set, and
	zstyle ':ss:prompt:username:' expected # ..equal to the machine, nothing. if not, red & bold.

	zstyle ':ss:prompt:path:' display # true: always display full path
	zstyle ':ss:prompt:path:' display-partial # true: always display tilde path
	zstyle ':ss:prompt:path:' length $((COLUMNS * 2 / 5)) # length of paths before truncation

	zstyle ':ss:prompt:git:' display auto # true: always display. auto: only if in a repo
	zstyle ':ss:prompt:git:' pattern  # not set by default; if set, used when truncating repo paths.

fi

# zstyle ':ss:prompt:*' display 1


# Mark `PS1` and `RPS1` as global, but not exported, so other shells don't inherit them.
typeset -g +x PS1 RPS1

source ${0:P:h}/prompt-widgets.zsh

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
	zstyle -s ':ss:prompt:time:' format tmp
	PS1+="%F{cyan}%D{${tmp:-%_I:%M:%S %p}} "

	PS1+='%U%f%!%u '                   # history
	PS1+='%B%F{blue}|%b '              # |
	PS1+='%(?.%F{green}.%F{red})%? '   # previous status code

	## JOB COUNT
	if zstyle -t ':ss:prompt:jobcount:' display; then
		PS1+='%F{166}(%j job%2(1j.%(2j.s.).s)) '
	elif zstyle -T ':ss:prompt:jobcount:' display auto; then
		PS1+='%(1j.%F{166}(%j job%(2j.s.)) .)'   # [jobs, if more than one]
	fi

	## SHLVL
	if zstyle -t ':ss:prompt:shlvl:' display; then
		PS1+='%F{red}SHLVL=%L '
	elif zstyle -T ':ss:prompt:shlvl:' display auto; then
		PS1+='%(2L.%F{red}SHLVL=%L .)' # [shellevel, if more than 1]
	fi

	PS1+='%B%F{blue}]%b ' # ]

	################################################################################
	#                                                                              #
	#                            Username and Hostname                             #
	#                                                                              #
	################################################################################
	() {
		readonly hostname_snippet='%n@%m '
		readonly hostname_grey='%F{242}'

		local hostname username

		if zstyle -t ':ss:prompt:userhost:' display; then
			# Explicitly requested to always print the hostname
			PS1+=$hostname_grey$hostname_snippet

		elif ! zstyle -T ':ss:prompt:userhost:' display auto; then
			# It's found and false, so that means let's never display the hostname

		elif ! zstyle -s ':ss:prompt:hostname:' expected hostname ||
			 ! zstyle -s ':ss:prompt:username:' expected username; then
			# One of the two `hostname`/`username` are missing, print out in grey.
			PS1+=$hostname_grey$hostname_snippet

		elif [[ $username != "$(print -P %n)" || $hostname != $(print -P %m) ]] then
			# One of the two doesn't match, uh oh!
			PS1+="%F{red}%B$hostname_snippet%b"
		fi
	}

	################################################################################
	#                                                                              #
	#                                     Path                                     #
	#                                                                              #
	################################################################################


	() {
		PS1+='%F{11}'
		# IE display the full path
		if zstyle -t ':ss:prompt:path:' display; then
			PS1+='%d '
			return
		elif zstyle -t ':ss:prompt:path:' display-partial; then
			PS1+='%~ '
			return
		fi

		function _SampShell-ps1-path {
			local pathlen
			zstyle -s ':ss:prompt:path:' length pathlen
			(( ! pathlen )) && pathlen=$((COLUMNS * 2 / 5))

			psvar[4]=$(print -P '%~')
			(( $#psvar[4] <= $pathlen )) && return
			# TODO: what if the component itself is too large?
			local tilde_path=$psvar[4]
			local root_dir=${tilde_path[(ws:/:)1]}
			tilde_path=${tilde_path#$root_dir/}
			local remainder=$(( pathlen - $#root_dir - 2 ))
			local pre=${tilde_path:0:$((remainder / 5 + 1))}
			local post=${tilde_path: -$((remainder - (remainder / 5 + 1))) }

			tilde_path=${tilde_path#*/}
			# psvar[4]+=/$tilde_path[(ws:/:)1]

			psvar[4]=$root_dir/$pre..$post
		}

		add-zsh-hook precmd _SampShell-ps1-path

		PS1+='%4v '
	}

	################################################################################
	#                                                                              #
	#                               Git information                                #
	#                                                                              #
	################################################################################

	() {
		local always
		if ! zstyle -b ':ss:prompt:git:' display always &&
		   ! zstyle -T ':ss:prompt:git:' display auto
		then
			return 0
		fi

		function _SampShell-ps1-git {
			local always git_info display_type

			psvar[1]= psvar[2]= psvar[3]=

			if ! zstyle -b ':ss:prompt:git:' display always &&
			   ! zstyle -T ':ss:prompt:git:' display auto branch-only
			then
				# don't display git info ever, so return.
				return
			fi
			zstyle -s ':ss:prompt:git:' display display_type

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
			if [[ $always != yes ]] && zstyle -s ':ss:prompt:git:' pattern pattern; then
				git_info=${git_info/${~pattern}/..}
			fi
			psvar[2]="$git_info "
		}
		source $1/git_prompt.sh

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
