setopt NO_KSH_GLOB
setopt NO_PATH_DIRS # don't searrch subdirs of `PATH` for commands if `a/b` is specified.
setopt SHORT_LOOPS # Why would this be disabled? Also `SHORT_REPEAT`?
setopt NO_GLOB_SUBST # huzzah, this is osmething we shouldn't have anyumore!
setopt NO_ALIAS_FUNC_DEF
false && setopt CHASE_LINKS # TODO: would this be bad?
false && setopt NO_POSIX_CD       # Disable posix-cd features
false && setopt SH_GLOB GLOBAL_EXPORT NOMATCH
