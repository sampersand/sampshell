#!zsh


r () {
	source ~ss/zsh/prompt/ps1.zsh
}

zstyle ':ss:prompt:username' expected 'sampersand'
zstyle ':ss:prompt:hostname' expected 'Sampbook-Pro'

## Options for the prompt, only set the singular required one (prompt_subst)
setopt PROMPT_SUBST        # Lets you use variables and $(...) in prompts.
unsetopt PROMPT_BANG       # Don't make `!` mean history number; we do this with %!.
unsetopt NO_PROMPT_PERCENT # Ensure `%` escapes in prompts are enabled.
unsetopt NO_PROMPT_CR      # Ensure a `\r` is printed before a line starts

# zstyle ':ss:prompt:*' display 1

# function make-prompt make-ps1 { #} <-- `#}` is needed by sublime to not freak out... lol
#     local -A opts=(
#         --pwd-max-len 65
#         --branch-pattern '[[:alnum:]]##/??-??-??/'
#     )

#     zparseopts -F -K -A opts  \
#         {h,-help}             \
#         {a,-all}              \
#         -pwd-max-len:         \
#         {l,-show-login-info}: \
#         {U,-user,-username}:  \
#         {H,-host,-hostname}:  \
#         -branch-pattern:      \

#     if [[ $+opts[-h] = 1 || $+opts[--help] = 1 ]]; then
#         echo "usage: $0 [options]"
#         echo
#         echo '  -h,--help                   show this'
#         echo '  -a,--all                    enable all PS1 conditionals'
#         echo "     --pwd-max-len=LEN        max len for the pwd; defaults to $opts[--pwd-max-len]"
#         echo '  -l,--show-login-info={0,1}  when 1, always show login info; when 0, never'
#         echo '  -U,--user,--username=NAME   username to match against' # can use `whoami`
#         echo '  -H,--host,--hostname=NAME   hostname to match against' # can use `hostname -s`
#         echo "     --branch-pattern=PAT     branch prefix pattern; default: ${opts[--branch-pattern]}"
#         echo
#         echo "If --login-info is empty, then the login username and hostname of the machine"
#         echo "will be checked; if they're both as expected, the user@host field isn't printed"
#         return -1
#     fi

#     local all=$(( $+opts[-a] || $+opts[--all] ))
#     local show_login_info=${opts[-l]-$opts[--show-login-info]}
#     local username=${opts[-U]-${opts[--user]-$opts[--username]}}
#     local hostname=${opts[-H]-${opts[--host]-$opts[--hostname]}}
#     local pathlen=${opts[--pwd-max-len]-0}

#     # If all is given, always show login info and pathlengths
#     if [[ $all = 1 ]]; then
#         show_login_info=1
#         pathlen=0
#     fi
#     # if either username or hostname aren't given, and show_login_info is unset, set it to always.
#     [[ (-z $username || -z $hostname) && -z $show_login_info ]] && show_login_info=1

# PS1= #'%k' <-- used to reset
PS1=
PS1+='%B%F{blue}[%b'               # `[`
PS1+='%F{cyan}%D{%_I:%M:%S %p}'    #    time
PS1+=' %U%f%!%u'                   #    history
PS1+=' %B%F{blue}|%b'              #    |
PS1+=' %(?.%F{green}.%F{red})%?'   #    prev-stat-code

# JOB COUNT
if zstyle -t ':ss:prompt:jobcount' display; then
	PS1+=' %F{166}(%j job%2(1j.%(2j.s.).s))'
elif (( $? == 2 )) then
	PS1+='%(1j. %F{166}(%j job%(2j.s.)).)'   # [jobs, if more than one]

# else, never display job count if it's set to false.
fi


if zstyle -t ':ss:prompt:shlvl' display; then
	PS1+=' %F{red}SHLVL=%L'
elif (( $? == 2 )) then
	PS1+='%(2L. %F{red}SHLVL=%L.)' # [shellevel, if more than 1]
fi


PS1+='%B%F{blue}]%b'               # ]

################################################################################
#                                   Hostname                                   #
################################################################################
() {
	readonly hostname_snippet=' %n@%m'
	readonly hostname_grey='%F{242}'

	local hostname username

	if zstyle -t ':ss:prompt:hostname' display; then
		# Explicitly requested to always print the hostname
		PS1+=$hostname_grey$hostname_snippet

	elif (( $? != 2 )) then
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

# Add ~path, possibly limiting it if $pathlen is nonzero
[[ $pathlen != 0 ]] && PS1+="%$pathlen>..>"
PS1+=' %F{11}';
if [[ $all = 1 ]]; then PS1+='%d'; else PS1+='%~'; fi # ~path
[[ $pathlen != 0 ]] && PS1+='%<<'

# # Add git branch in
# PS1+="%F{043}\$(_SampShell_ps1_git_branch $all ${(q)opts[--branch-pattern]})%f"        # git branch

# # git status
# PS1+='$(_SampShell_rps1_git_status)'

# # Trailing %
# PS1+='%b %F{8}'

# PS1+='%#%f '                                   # ending %
# }
