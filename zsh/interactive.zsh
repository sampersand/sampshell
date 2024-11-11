. ${0:P:h}/old/interactive.zsh

setopt CORRECT # Correct invalid command line arguments
setopt INTERACTIVE_COMMENTS # Allow comments on the command line

set +u # TODO: Why is this needed? what sets this

if [[ -n $SampShell_experimental ]]; then
	setopt PATH_DIRS # Let's you do `foo/bar` if `foo` is in $PATH
	setopt RM_STAR_WAIT # kinda annoying in all honesty
fi

# Safety First!!
todo: clobber
setopt NO_RM_STAR_SILENT # query before `rm *`

# others
setopt SHORT_LOOPS  # Enable short form of loops
setopt AUTO_CONTINUE # disown automatically continues commands
setopt CHECK_JOBS CHECK_RUNNING_JOBS    # ensure we won't accidentally close when we have jobs
setopt NO_IGNORE_EOF # in case this isn't there, make sure we can ctrl+d cause i do it
