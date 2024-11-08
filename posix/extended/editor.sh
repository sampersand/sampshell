## Setup Sublime Text commands, unless it's disabled.
if [ -z "${SampShell_no_subl-}" ]  ; then
	alias s=subl
	alias ss=ssubl
	alias ssubl='subl --create'

	## Spellchecks
	alias sbul=subl
	alias ssbul=ssubl
fi
