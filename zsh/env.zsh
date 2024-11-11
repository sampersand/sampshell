typeset -Uxg path # make sure `path` is unique, and then export it

path+=${0:P:h}/bin

setopt EXTENDED_GLOB          # Add additional glob syntax in zsh
setopt NO_IGNORE_CLOSE_BRACES # Allow `}` to also be a `;`
setopt GLOB_STAR_SHORT        # **.c is an alias for **/*.c
false && setopt NO_ALIAS_FUNC_DEF MARK_DIRS noMULTI_FUNC_DEF # do we want no multi fn?
setopt NO_GLOB_ASSIGN # `a=*` won't expand out the `*
false && setopt warn_create_global warn_nested_var

function SampShell-debug {
	SampShell_debug && setopt {SOURCE_TRACE,UNSET,WARN_CREATE_GLOBAL,WARN_NESTED_VAR}
}

function {SampShell-,}undebug {
	SampShell_undebug && setopt NO_{SOURCE_TRACE,UNSET,WARN_CREATE_GLOBAL,WARN_NESTED_VAR}
}

setopt NO_KSH_GLOB
setopt NO_PATH_DIRS # don't searrch subdirs of `PATH` for commands if `a/b` is specified.
setopt SHORT_LOOPS # Why would this be disabled? Also `SHORT_REPEAT`?
setopt NO_GLOB_SUBST # huzzah, this is osmething we shouldn't have anyumore!
setopt NO_ALIAS_FUNC_DEF
false && setopt CHASE_LINKS # TODO: would this be bad?
false && setopt NO_POSIX_CD       # Disable posix-cd features
false && setopt SH_GLOB GLOBAL_EXPORT NOMATCH
