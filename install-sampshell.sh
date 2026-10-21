#!/bin/sh

set -euC
: "${SampShell_ROOTDIR:?SampShell_ROOTDIR is required}"

shell=bash verbose=
while getopts 'zbtv' opt; do
	case $opt in
	z) shell=zsh ;;
	b) shell=bash ;;
	t) shell=tcsh ;;
	v) verbose=1 ;;
	?) exit 1;;
	esac
done
shift `expr $#`
p "$@"

################################################################################
#                                  Git Setup                                   #
################################################################################
echo --- Setting up git configurations ---

# Add our config in to gitconfig.
if ! git config --get-all --global include.path | grep -F -q -x "$SampShell_ROOTDIR/.gitconfig"; then
	echo Adding "$SampShell_ROOTDIR/.gitconfig" to git\'s global include
	git config --add --global include.path "$SampShell_ROOTDIR/.gitconfig"
else
	[ $verbose ] && echo Git config of "$SampShell_ROOTDIR/.gitconfig" already set
fi

# Unfortunately, we can't set this in the sampshell `.gitconfig` file since the
# install location might change.
echo Setting global excludesFile to $SampShell_ROOTDIR/.gitignore_global
git config set --global core.excludesFile "$SampShell_ROOTDIR/.gitignore_global"

################################################################################
#                                 Shell Setup                                  #
################################################################################
add_to_file_if_doesnt_exist () {
	[ -f "${1:?}" ] || touch -- "$1"
	if ! grep -F -q -x "${2:?}" "$1"; then
		printf "%s\n" "$2" >> "$1"
	fi
}

echo --- Setting up shell-specific configurations ---

if [ $shell = bash ]; then
	add_to_file_if_doesnt_exist ~/.bashrc '. "${SampShell_ROOTDIR:-$HOME/sampshell}/.bashrc"'
	add_to_file_if_doesnt_exist ~/.bash_profile '. "${SampShell_ROOTDIR:-$HOME/sampshell}/.bash_profile"'
	add_to_file_if_doesnt_exist ~/.profile '. "${SampShell_ROOTDIR:-$HOME/sampshell}/.profile"'
elif [ $shell = zsh ]; then
	add_to_file_if_doesnt_exist ~/.zshrc '. "${SampShell_ROOTDIR:-$HOME/sampshell}/.zshrc"'
	add_to_file_if_doesnt_exist ~/.zprofile '. "${SampShell_ROOTDIR:-$HOME/sampshell}/.zprofile"'
elif [ $shell == tcsh ]; then
	add_to_file_if_doesnt_exist ~/.tcshrc 'if ( ! $?SampShell_ROOTDIR ) setenv SampShell_ROOTDIR ~/sampshell'
	add_to_file_if_doesnt_exist ~/.tcshrc 'source "$SampShell_ROOTDIR/.tcshrc"'
else
	echo "unknown shell: $shekk"
fi
