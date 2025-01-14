#!zsh


r () {
	source ~ss/zsh/prompt/ps1.zsh
}

zstyle ':ss:prompt:username' expected 'sampersand'
zstyle ':ss:prompt:hostname' expected 'Sampbook-Pro'
zstyle ':ss:prompt:*' display auto
zstyle ':ss:prompt:time' format '%_I:%M:%S %p'
zstyle ':ss:prompt:git' pattern '[[:alnum:]]##/??-??-??/'

## Options for the prompt, only set the singular required one (prompt_subst)
setopt PROMPT_SUBST        # Lets you use variables and $(...) in prompts.
unsetopt PROMPT_BANG       # Don't make `!` mean history number; we do this with %!.
unsetopt NO_PROMPT_PERCENT # Ensure `%` escapes in prompts are enabled.
unsetopt NO_PROMPT_CR      # Ensure a `\r` is printed before a line starts

# zstyle ':ss:prompt:*' display 1

################################################################################
#                                                                              #
#                                Bracket Prefix                                #
#                                                                              #
################################################################################
PS1=
PS1+='%B%F{blue}[%b' # `[`; notably no space as the time fmt should have a space

() {
	local timefmt
	zstyle -s ':ss:prompt:time' format timefmt
	PS1+="%F{cyan}%D{${timefmt:-%_I:%M:%S %p}} "
}
PS1+='%U%f%!%u '                   # history
PS1+='%B%F{blue}|%b '              # |
PS1+='%(?.%F{green}.%F{red})%? '   # previous status code

## JOB COUNT
if zstyle -t ':ss:prompt:jobcount' display; then
	PS1+='%F{166}(%j job%2(1j.%(2j.s.).s)) '
elif zstyle -T ':ss:prompt:jobcount' display auto; then
	PS1+='%(1j.%F{166}(%j job%(2j.s.)) .)'   # [jobs, if more than one]
fi

## SHLVL
if zstyle -t ':ss:prompt:shlvl' display; then
	PS1+='%F{red}SHLVL=%L '
elif zstyle -T ':ss:prompt:shlvl' display auto; then
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

	if zstyle -t ':ss:prompt:hostname' display; then
		# Explicitly requested to always print the hostname
		PS1+=$hostname_grey$hostname_snippet

	elif ! zstyle -T ':ss:prompt:hostname' display auto; then
		# It's found and false, so that means let's never display the hostname

	elif ! zstyle -s ':ss:prompt:hostname' expected hostname ||
		 ! zstyle -s ':ss:prompt:username' expected username; then
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

# Add ~path, possibly limiting it if $pathlen is nonzero
[[ $pathlen != 0 ]] && PS1+="%$pathlen>..>"
PS1+='%F{11}';
if [[ $all = 1 ]]; then PS1+='%d'; else PS1+='%~'; fi # ~path
[[ $pathlen != 0 ]] && PS1+='%<<'
PS1+=' '

################################################################################
#                                                                              #
#                               Git information                                #
#                                                                              #
################################################################################

() {
	local always
	if ! zstyle -b ':ss:prompt:git' display always &&
	   ! zstyle -T ':ss:prompt:git' display auto
	then
		return 0
	fi

	GIT_PS1_SHOWDIRTYSTATE=1      # Show `*` and `+` for untracted states
	GIT_PS1_SHOWSTASHSTATE=1      # Show `$` when there's something stashed
	GIT_PS1_SHOWUNTRACKEDFILES=1  # Also show untracted files via `%`
	GIT_PS1_SHOWCONFLICTSTATE=1   # Show when there's a merge conflict
	GIT_PS1_HIDE_IF_PWD_IGNORED=1 # Don't show git when the PWD is ignored.
	GIT_PS1_STATESEPARATOR=       # Don't put anything after the branch name

	[[ -n $SampShell_no_experimental ]] && GIT_PS1_SHOWUPSTREAM=auto    # IDK IF I need this

	function _SampShell-ps1-git {
		local always git_info

		psvar[1]= psvar[2]= psvar[3]=

		if ! zstyle -b ':ss:prompt:git' display always &&
		   ! zstyle -T ':ss:prompt:git' display auto
		then
			# don't display git info ever, so return.
			return
		fi

		git_info=$(__git_ps1 %s)
		if [[ -z $git_info ]] then
			[[ $always = yes ]] && psvar[3]='(no repo) '
			return
		fi

		psvar[1]="$git_info "
		if [[ $always != yes ]] && zstyle -s ':ss:prompt:git' pattern pattern; then
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
