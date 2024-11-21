# Note that we `unalias` all these functions right before defining them, just
# on the off chance that they were `alias`ed.
# unalias SampShell_unalias >/dev/null 2>&1
SampShell_unalias () {
   if [ "$#" = 0 ]; then
      echo 'usage: SampShell_unalias name [name ...]' >&2
      return 1
   fi

   while [ "$#" != 0 ]; do
      unalias "$1" >/dev/null 2>&1 || : # `:` to ensure we succeed always
      shift
   done
}

SampShell_unalias ping
ping () { curl --connect-timeout 10 "${1:-http://www.example.com}"; }

alias k+='kill %+'

## Creating files
alias touchd='mkdir -p' # alias incase i ever end up using it

SampShell_unalias ttouch
ttouch () for file; do  # Same as `touch`, except it will create directories as needed.
	mkdir -p $file:h && touch $file
done

## Creating Folders (& cding to them)
SampShell_unalias mkdircd
mkdircd () { mkdir -p $@ && cd $@; }
alias cdmkdir=mkdircd
alias cdm=mkdircd

SampShell_unalias mkd mkf
mkd () { mkdir -p $@; }
mkf () { mkdir -p ${@:h} && command touch $@; }

## Symlinks
symlink () {
	ln -s ${1?need existing file name} ${2?need name of destination}
}

