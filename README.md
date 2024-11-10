# sampshell
My shell startup files.

This repo contains all the standard definitions and configuration I use for my shells; it's intended to be `.`d from, any config file.

details:

# `env` vs `interactive` (vs `both`)
The `env.xx` files are intended to be `.`d from within scripts in addition to interactive shells; They only setup things like the PATH, variables which might be used in scripts, etc. These files make sure to always prefix their identifiers with `SampShell_`, so as to not conflict with anything that might already exist.
The `interactive.xx` files are intended to be `.`d only from within interactive shells (usually just in a shell's startup files), as they contain definitions/aliases which might conflict with things in a script. They also setup a lot of stuff for interactive use, such as the PS1, history storage, safer `mv` commands, etc

The `both.xx` file is intended to be used by languages which dont have separate startup files for interactive-or-not.
