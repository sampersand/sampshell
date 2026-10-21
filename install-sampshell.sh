#!/bin/sh

set -euC
: "${SampShell_ROOTDIR:?SampShell_ROOTDIR is required}"
readonly prog_name=${0##*/}

usage () { cat; } <<EOS
usage: $prog_name [options]
options:
	-h     Show usage
	-v     Enable verbose outputs
	-a     Install all options
	-s     Install sh hooks (i.e. '.profile')
	-z     Install zsh hooks
	-b     Install bash hooks
	-t     Install tcsh hooks
	-g     Install git options
	-p     Install scripts into PATH
EOS

all= shell= verbose= git= scripts=
while getopts 'hvaszbtgp' opt; do
	case $opt in
	h) usage; exit ;;
	v) verbose=1 ;;
	a) all=1 ;;
	s) shell=sh ;;
	z) shell=zsh ;;
	b) shell=bash ;;
	t) shell=tcsh ;;
	g) git=1 ;;
	p) scripts=1 ;;
	?) exit 2 ;;
	esac
done

shift `expr $#`

if [ $# -ne 0 ]; then
	usage >&2; exit 1
fi

# if [ $verbose ]; then
# 	log () { echo "$@"; }
# else
# 	log () { :; }
# fi


################################################################################
#                                  Git Setup                                   #
################################################################################
if [ ${git:-$all} ]; then
echo --- Setting up git configurations ---

# Add our config in to gitconfig.
if ! git config --get-all --global include.path | grep -F -q -x "$SampShell_ROOTDIR/.gitconfig"; then
	echo "\tAdding $SampShell_ROOTDIR/.gitconfig to git\'s global include"
	git config --add --global include.path "$SampShell_ROOTDIR/.gitconfig"
else
	[ $verbose ] && echo "\tGit config of $SampShell_ROOTDIR/.gitconfig already set"
fi

# Unfortunately, we can't set this in the sampshell `.gitconfig` file since the
# install location might change.
echo "\tSetting global excludesFile to $SampShell_ROOTDIR/.gitignore_global"
git config set --global core.excludesFile "$SampShell_ROOTDIR/.gitignore_global"

fi

################################################################################
#                                 Shell Setup                                  #
################################################################################
if [ ${shell:-$all} ]; then
add_to_file_if_doesnt_exist () {
	[ -f "${1:?}" ] || touch -- "$1"
	if ! grep -F -q -x "${2:?}" "$1"; then
		printf '# Added by `%s` at %s\n%s\n' \
			"$prog_name" "$(date)" "$2" >> "$1"
		echo "Installed setup to $1"
	else
		[ $verbose ] && echo "\tAlready in $2: $1"
	fi
}

echo --- Setting up shell-specific configurations ---

if [ $all ] || [ $shell = sh ] || [ $shell = bash ]; then
	add_to_file_if_doesnt_exist ~/.profile '. "${SampShell_ROOTDIR:-$HOME/sampshell}/.profile"'
fi

if [ $all ] || [ $shell = bash ]; then
	add_to_file_if_doesnt_exist ~/.bashrc 'source "${SampShell_ROOTDIR:-$HOME/sampshell}/.bashrc"'
	add_to_file_if_doesnt_exist ~/.bash_profile 'source "${SampShell_ROOTDIR:-$HOME/sampshell}/.bash_profile"'
fi

if [ $all ] || [ $shell = zsh ]; then
	add_to_file_if_doesnt_exist ~/.zshrc 'source "${SampShell_ROOTDIR:-$HOME/sampshell}/.zshrc"'
	add_to_file_if_doesnt_exist ~/.zprofile 'source "${SampShell_ROOTDIR:-$HOME/sampshell}/.zprofile"'
fi

if [ $all ] || [ $shell = tcsh ]; then
	add_to_file_if_doesnt_exist ~/.tcshrc 'if ( ! $?SampShell_ROOTDIR ) setenv SampShell_ROOTDIR ~/sampshell'
	add_to_file_if_doesnt_exist ~/.tcshrc 'source "$SampShell_ROOTDIR/.tcshrc"'
fi

fi

################################################################################
#                     Install scripts into /usr/local/bin                      #
################################################################################
if [ ${scripts:-$all} ]; then
echo --- Installing scripts into path ---

readonly INSTALL_LOCATION=${INSTALL_LOCATION:-/usr/local/bin}
readonly p_install_location=$INSTALL_LOCATION/p
if ! mviz_location=$(command -v mviz 2>/dev/null); then
	echo cannot install p, mviz doesnt exist
elif [ "$p_install_location" -ef "$mviz_location" ]; then
	[ $verbose ] && echo p already installed
elif [ -e "$p_install_location" ] || [ -L "$p_install_location" ]; then
	echo p installed but isntmviz, uh oh
else
	sudo mkdir -p -- "$INSTALL_LOCATION" &&
		sudo ln -s "$mviz_location" "$p_install_location"
fi

fi
