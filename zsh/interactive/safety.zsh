### ZSH config for "safety"

## Set safety options
setopt NO_CLOBBER        # Should already be set, but just in case.
setopt CLOBBER_EMPTY     # However, you can clobber empty files.
setopt NO_RM_STAR_SILENT # In case it's accidentally unset, force `rm *` to ask for confirmation

# Note that the rest of the config for safety (eg `alias rm='rm -i`) are in `posix/interactive.sh`
