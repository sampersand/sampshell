setopt NO_CLOBBER    # Cannot use `>` to overwrite files; `>!`/`>|` needed.
setopt CLOBBER_EMPTY # However, you can clobber empty files.
setopt RM_STAR_WAIT  # Accidentally do `rm *`, wait 10s before doing it.
