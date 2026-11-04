#!csh
# This file is the login file for sh.

# extract vars from ~/.profile
if ( -f ~/.profile ) then
	source "$SampShell_ROOTDIR"/tcsh-bin/extract_profile_exported_vars
endif

# Ignore a CTRL+D on login shells
set ignoreeof = 2
