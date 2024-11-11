setopt NO_CLOBBER        # Should already be set, but just in case.
setopt CLOBBER_EMPTY     # However, you can clobber empty files.
setopt NO_RM_STAR_SILENT # In case it's accidentally unset, force `rm *` to ask for confirmation
setopt RM_STAR_WAIT      # Accidentally do `rm *`, wait 10s before doing it.