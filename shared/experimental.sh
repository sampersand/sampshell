[ -z "$SampShell_Experimental" ] && return

## Creating files
alias touchd='mkdir -p' # alias incase i ever end up using it

function ttouch () for file; do  # Same as `touch`, except it will create directories as needed.
	mkdir -p $file:h && touch $file
done

## Creating Folders (& cding to them)
function mkdircd () { mkdir -p $@ && cd $@; }
alias cdmkdir=mkdircd
alias cdm=mkdircd
function mkd () { mkdir -p $@; }
function mkf () { mkdir -p ${@:h} && command touch $@ }

## Symlinks
function symlink () {
	ln -s ${1?need existing file name} ${2?need name of destination}
}
