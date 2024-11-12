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
