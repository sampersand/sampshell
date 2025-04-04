ping () { curl --connect-timeout 10 "${1:-http://www.example.com}"; }

alias k+='kill %+'

## Creating files
alias touchd='mkdir -p' # alias incase i ever end up using it

ttouch () for file; do  # Same as `touch`, except it will create directories as needed.
	mkdir -p $file:h && touch $file
done

## Creating Folders (& cding to them)
mkdircd () { mkdir -p $@ && cd $@; }
alias cdmkdir=mkdircd
alias cdm=mkdircd

mkd () { mkdir -p $@; }
mkf () { mkdir -p ${@:h} && command touch $@; }

## Symlinks
symlink () {
	ln -s ${1?need existing file name} ${2?need name of destination}
}

