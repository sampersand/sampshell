## 16.2.3 Expansion and Globbing
setopt CASE_GLOB CASE_PATHS # case-insensitive globbing??

setopt GLOB_ASSIGN # what's this
setopt HIST_SUBST_PATTERN # TODO

setopt MARK_DIRS
setopt APPEND_HISTORY
setopt PATH_DIRS

setopt RM_STAR_WAIT # Maybe? I find this annoyoing actually

setopt PROMPT_CR # ??
setopt FUNCTION_ARGZERO # DEFAULT; when to set this?
setopt LOCAL_LOOPS # ?? should this be set or not?
setopt LOCAL_PATTERNS # <-- look into

setopt CSH_JUNKIE_HISTORY # ??
setopt CSH_JUNKIE_LOOPS # I might do that lol

CORRECT_IGNORE=
CORRECT_IGNORE_FILE=
HISTORY_IGNORE=
KEYBOARD_HACK=\' # ignore an odd-number of `'`s
LISTMAX=30 # the default, i think; ask when listing more than this
TIMEFMT=$TIMEFMT # look into this
TMPPREFIX=$TMPPREFIX # todo; shoudl this be set to SampShell_TMPDIR?
WORDCHARS=$WORDCHARS # ooo, this can be hacky
return
_ <S>

    The last argument of the previous command. Also, this parameter is set in the environment of every command executed to the full pathname of the command. 
    uh its not set?

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
