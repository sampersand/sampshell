#!csh
# This file is the login file for sh.

# extract vars from ~/.profile
if ( -f ~/.profile ) then
	source "$SampShell_ROOTDIR"/tcsh-bin/extract_profile_exported_vars
endif


# Add tcsh-bin to the path if it's not already there. TODO: find a better solution
# lol... (the reason it's here is because `extract_profile_exported_vars` would
# overwrite this one specific `path` change.)
set path = ( $path:x "$SampShell_ROOTDIR"/tcsh-bin )

# Ignore a CTRL+D on login shells
set ignoreeof = 2
