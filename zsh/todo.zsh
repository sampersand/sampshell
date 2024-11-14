
setopt MULTI_FUNC_DEF # unset what's in `env.zsh`, as i do this enough on the cmd line
setopt UNSET         # DEFAULT; allow variables to be empty
setopt ALIASES       # DEFAULT; I use them
setopt NO_IGNORE_EOF # DEFAULT;  use ctrl+d a lot;
setopt NOMATCH



# TODO optoins to look into

## 16.2.3 Expansion and Globbing
setopt CASE_GLOB CASE_PATHS # case-insensitive globbing??
setopt HIST_SUBST_PATTERN # TODO
setopt HIST_LEX_WORDS # Look into that
setopt MARK_DIRS
setopt APPEND_HISTORY
setopt PATH_DIRS
setopt FUNCTION_ARGZERO # DEFAULT; when to set this?
setopt LOCAL_LOOPS # ?? should this be set or not?
setopt LOCAL_PATTERNS # <-- look into
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
HISTFILESIZE=??

## DO we want these always enabled?
## Default options that really should be enabled. 
setopt BAD_PATTERN     # bad patterns error out
setopt NOMATCH         # non-matching globs error out.
setopt EQUALS          # Do `=` expansion
setopt GLOB            # Why wouldnt you
setopt NO_{IGNORE_BRACES,IGNORE_CLOSE_BRACES} # make `a () { b }` valid.
setopt SHORT_LOOPS     # I use this semi-frequently
setopt RC_QUOTES       # Let you do type `''` within single quotes, eg `'let''s go to the store!'`
