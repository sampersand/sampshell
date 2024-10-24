export PS1='[$? !] ${PWD##"$HOME/"} $ '

return 

# There's some tomfoolery going on with ZSH and not accepting prompt expansions that are
# too long, so this stuff down here is ignored sadly
SampShell_ps1_njobs () {
    local jobs=$(jobs | wc -l)
    local suffix=

    if [ "$jobs" -ne 0 ]; then
        [ "$jobs" -ne 1 ] && suffix=s
        printf " %s(%d job%s)%s" $'\e[38;5;166m' "$jobs" "$suffix" "$reset"
    fi

    if [ "$SHLVL" -ne 0 ]; then
        printf " %sSHLVL=%d%s" "$red" "$SHLVL" "$reset"
    fi
}

cyan=$'\e[36m'
blue=$'\e[34m'
green=$'\e[32m'
red=$'\e[31m'
bold=$'\e[1m'
nobold=$'\e[0m'
underline=$'\e[4m'
nounderline=$'\e[24m'
reset=$'\e[39m'

SampShell_ps1_have_interpolation=1
export PS1=
PS1+="$blue$bold[$reset$nobold" # `[`
if [ $SampShell_ps1_have_interpolation ]; then
    PS1+="$cyan\$(SampShell_ps1_exit=\$?; date +'%_I:%M:%S %p'; exit \$SampShell_ps1_exit)$reset" # time
fi
PS1+=" $underline!$nounderline" # history
PS1+=" $blue$bold|$nobold$reset" # `|`
PS1+=$' \e[$(( 31+($?<=0) ))m$?'"$reset" # make sure not to use `!`
PS1+='$(SampShell_ps1_njobs)'
alias r='PS1=\$\ '
# PS1+=' $(SampShell_ps1_prev_stat_code "<$SampShell_ps1_prev_exit>")'


PS1+=' \$$reset '

#     if [[ $all = 1 ]]; then
#         PS1+=' %F{166}(%j job%2(1j.%(2j.s.).s))%f'         # job count
#         PS1+=' %F{red}SHLVL=%L'                            # shellevel
#     else
#         PS1+='%(1j. %F{166}(%j job%(2j.s.))%f.)'           # [jobs, if more than one]
#         PS1+='%(2L. %F{red}SHLVL=%L.)'                     # [shellevel, if more than 1]
#     fi
#     PS1+='%B%F{blue}]%b%f'                                 # ]

#     # Add in the hostname, if applicable
#     PS1+=$(_samp_shell_ps1_hostname_username "$show_login_info" "$username" "$hostname") 

#     # Add ~path, possibly limiting it if $pathlen is nonzero
#     [[ $pathlen != 0 ]] && PS1+="%$pathlen>..>"
#     PS1+=' %F{11}';
#     if [[ $all = 1 ]]; then PS1+='%d'; else PS1+='%~'; fi # ~path
#     [[ $pathlen != 0 ]] && PS1+='%<<'

#     # Add git branch in
#     PS1+="%F{043}\$(_samp_shell_ps1_git_branch $all ${(q)opts[--branch-pattern]})%f"        # git branch

#     # git status
#     PS1+='$(_samp_shell_rps1_git_status)'

#     # Trailing %
#     PS1+='%b %F{8}'

#     if [[ $all = 1 ]]; then
#         PS1+=$'\n'
#     fi
#     PS1+='%#%f '                                   # ending %
# }

# alias make-ps1=make-prompt
