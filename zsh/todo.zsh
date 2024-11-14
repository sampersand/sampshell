# TODO optoins to look into

## 16.2.3 Expansion and Globbing
setopt HIST_SUBST_PATTERN # TODO
setopt HIST_LEX_WORDS # Look into that
setopt MARK_DIRS
setopt APPEND_HISTORY
setopt PATH_DIRS
setopt FUNCTION_ARGZERO # DEFAULT; when to set this?
setopt LOCAL_LOOPS # ?? should this be set or not?
setopt LOCAL_PATTERNS # <-- look into

CORRECT_IGNORE=
CORRECT_IGNORE_FILE=
LISTMAX=30 # the default, i think; ask when listing more than this
TIMEFMT=$TIMEFMT # look into this
return

### These were borrowed from someone, and i want to look into using them myself
SampShell_exec-or-edit () if [[ -x $1 ]]; then
    $1
else
    subl $1
fi

alias -s {sh,zsh,py}=SampShell_exec-or-edit
alias -s {txt,json,ini,toml,yml,yaml,xml,html,md,lock,snap,rst,cpp,h,rs}=subl
alias -s {log,csv}=bat
alias -s git='git clone'
alias -s o='nm --demangle'
alias -s so='ldd'
###

location=$(readlink -f ${(%):-%N}) what lol
