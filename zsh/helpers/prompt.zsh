### Prompting in ZSH

## Options for the prompt, only set the singular required one (prompt_subst)
setopt PROMPT_SUBST                # Lets you use variables and $(...) in prompts.
unsetopt PROMPT_BANG               # Don't make `!` mean history number; we do this with %!.
unsetopt NO_PROMPT_PERCENT         # Ensure `%` escapes in prompts are enabled.
unsetopt NO_PROMPT_CR NO_PROMPT_SP # Ensure the inverted `%` is printed

function _SampShell_ps1_hostname_username {
    case $1 in
        (0)
            return ;;
        ( ) [[ $2 == "$(print -P %n)" && $3 == "$(print -P %m)" ]] && return
            echo -n ' %B%F{red}' ;;
        (^1)
            warn "unknown hostname kind $1; falling thru" ;&
        (1) 
            echo -n ' %F{242}';;
    esac

    echo -n '%n@%m%b%f'
}


function _SampShell_ps1_git_branch {
    local br=${"$(git branch --show-current 2>&-)":gs/%/%%} # branches can have `%` in them

    if [[ $1 = 1 ]]; then
        echo ' '${br:-'%F{red}(no branch)%f'}
    elif [[ -z $br ]]; then
        return
    else
        echo ' #'${br#${~${(e)2}}}
    fi
}

# TODO: handle rebasing and stuff
function _SampShell_rps1_git_status {
    local stat=0
    local line
    git status --porcelain 2>&- | while IFS= read -r line; do
        [[ $line[1] == ' ' ]] && (( stat |= 2 ))
        [[ $line[2] == ' ' ]] && (( stat |= 1 ))
        [[ $line[1] == '?' || $line[2] == '?' ]] && (( stat |= 4 ))
    done
    (( stat & 1 )) && echo -n '+'
    (( stat & 2 )) && echo -n '*'
    (( stat & 4 )) && echo -n '?'
    # TODO: rebasing and stuff
}

function make-prompt make-ps1 { #} <-- `#}` is needed by sublime to not freak out... lol
    local -A opts=(
        --pwd-max-len 65
        --branch-pattern '[[:alnum:]]##/??-??-??/'
    )

    zparseopts -F -K -A opts  \
        {h,-help}             \
        {a,-all}              \
        -pwd-max-len:         \
        {l,-show-login-info}: \
        {U,-user,-username}:  \
        {H,-host,-hostname}:  \
        -branch-pattern:      \

    if [[ $+opts[-h] = 1 || $+opts[--help] = 1 ]]; then
        echo "usage: $0 [options]"
        echo
        echo '  -h,--help                   show this'
        echo '  -a,--all                    enable all PS1 conditionals'
        echo "     --pwd-max-len=LEN        max len for the pwd; defaults to $opts[--pwd-max-len]"
        echo '  -l,--show-login-info={0,1}  when 1, always show login info; when 0, never'
        echo '  -U,--user,--username=NAME   username to match against' # can use `whoami`
        echo '  -H,--host,--hostname=NAME   hostname to match against' # can use `hostname -s`
        echo "     --branch-pattern=PAT     branch prefix pattern; default: ${opts[--branch-pattern]}"
        echo
        echo "If --login-info is empty, then the login username and hostname of the machine"
        echo "will be checked; if they're both as expected, the user@host field isn't printed"
        return -1
    fi

    local all=$(( $+opts[-a] || $+opts[--all] ))
    local show_login_info=${opts[-l]-$opts[--show-login-info]}
    local username=${opts[-U]-${opts[--user]-$opts[--username]}}
    local hostname=${opts[-H]-${opts[--host]-$opts[--hostname]}}
    local pathlen=${opts[--pwd-max-len]-0}

    # If all is given, always show login info and pathlengths
    if [[ $all = 1 ]]; then
        show_login_info=1
        pathlen=0
    fi
    # if either username or hostname aren't given, and show_login_info is unset, set it to always.
    [[ (-z $username || -z $hostname) && -z $show_login_info ]] && show_login_info=1

    # PS1+='%F{cyan}%D{%_m\/%d %_I:%M:%S %p}%f' # time
    PS1= # Don't export it if it's not already exported.
    PS1='%k'
    PS1+='%B%F{blue}[%b'                                   # [
    PS1+='%F{cyan}%D{%_I:%M:%S %p}%f'                      #    time
    PS1+=' %U%!%u'                                         #    history
    PS1+='%B%F{blue} |%b%f'                                #    |
    PS1+=' %(?.%F{green}.%F{red})%?%f'                     #    prev-stat-code

    if [[ $all = 1 ]]; then
        PS1+=' %F{166}(%j job%2(1j.%(2j.s.).s))%f'         # job count
        PS1+=' %F{red}SHLVL=%L'                            # shellevel
    else
        PS1+='%(1j. %F{166}(%j job%(2j.s.))%f.)'           # [jobs, if more than one]
        PS1+='%(2L. %F{red}SHLVL=%L.)'                     # [shellevel, if more than 1]
    fi
    PS1+='%B%F{blue}]%b%f'                                 # ]

    # Add in the hostname, if applicable
    PS1+="$(_SampShell_ps1_hostname_username "$show_login_info" "$username" "$hostname")"

    # Add ~path, possibly limiting it if $pathlen is nonzero
    [[ $pathlen != 0 ]] && PS1+="%$pathlen>..>"
    PS1+=' %F{11}';
    if [[ $all = 1 ]]; then PS1+='%d'; else PS1+='%~'; fi # ~path
    [[ $pathlen != 0 ]] && PS1+='%<<'

    # Add git branch in
    PS1+="%F{043}\$(_SampShell_ps1_git_branch $all ${(q)opts[--branch-pattern]})%f"        # git branch

    # git status
    PS1+='$(_SampShell_rps1_git_status)'

    # Trailing %
    PS1+='%b %F{8}'

    PS1+='%#%f '                                   # ending %
}

typeset -aU preexec_functions
preexec_functions+=(_SampShell-preexec-clear-formatting)
function _SampShell-preexec-clear-formatting { print -nP '%b%u%s%f' } # Reset formatting, though i cant figure out how to unset background colours

