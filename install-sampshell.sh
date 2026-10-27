#!/bin/sh

set -euC

: "${SampShell_ROOTDIR:?SampShell_ROOTDIR is required}"
readonly prog_name=${0##*/}
readonly SCRIPTS_INSTALL_LOCATION=${SCRIPTS_INSTALL_LOCATION:-/usr/local/bin}

################################################################################
#                                  Utilities                                   #
################################################################################

warn () {
	fmt="%s $1\n"
	shift
	printf >&2 "$fmt" "$prog_name" "$@"
}

die () { warn "$@"; exit 2; }

log () {
	if [ $verbose ]; then
		fmt="\t$1\n"
		shift
		printf "$fmt" "$@"
	fi
}

section () {
	echo "--- $* ---"
}

# Adds `$2` to `$1`, unless the exact line already exists.
add_to_file () {
	# Sanity check---the file exists and is valid
	if [ -e "${1:?}" ] && [ ! -f "${1:?}" ]; then
		warn "path %s exists but isn't a file; not adding to it." "$1"
		return 1
	fi

	# If it's already in the file, then do nothing
	if [ -f "$1" ] && grep -F -q -x "${2:?}" "$1"; then
		log 'Not adding to %s (already present): %s' "$1" "$2"
	elif [ $dry ]; then
		log 'Would add to %s: %s' "$1" "$2"
	else
		printf '\n# Added by `%s` at %s\n%s\n' \
			"$prog_name" "$(date)" "$2" >> "$1"
		echo "Installed setup to $1"
	fi
}

####################################################################################################
#                                            Git Setup                                             #
####################################################################################################

git_setup () {
	# Add our config in to gitconfig.
	if ! git config --get-all --global include.path | grep -F -q -x "$SampShell_ROOTDIR/.gitconfig"; then
		echo "\tAdding $SampShell_ROOTDIR/.gitconfig to git\'s global include"
		[ ! $dry ] && git config --add --global include.path "$SampShell_ROOTDIR/.gitconfig"
	else
		log "Git config of %s already set" "$SampShell_ROOTDIR/.gitconfig"
	fi

	# Unfortunately, we can't set this in the sampshell `.gitconfig` file since the
	# install location might change.
	echo "\tSetting global excludesFile to $SampShell_ROOTDIR/.gitignore_global"
	[ ! $dry ] && git config set --global core.excludesFile "$SampShell_ROOTDIR/.gitignore_global"
}

####################################################################################################
#                                           Shell Setup                                            #
####################################################################################################

install_shell_setup_sh () {
	add_to_file ~/.profile '. "${SampShell_ROOTDIR:-$HOME/sampshell}/.profile"'
}

install_shell_setup_bash () {
	install_shell_setup_sh
	add_to_file ~/.bashrc 'source "${SampShell_ROOTDIR:-$HOME/sampshell}/.bashrc"'
	add_to_file ~/.bash_profile 'source "${SampShell_ROOTDIR:-$HOME/sampshell}/.bash_profile"'
}

install_shell_setup_zsh () {
	add_to_file ~/.zshrc 'source "${SampShell_ROOTDIR:-$HOME/sampshell}/.zshrc"'
	add_to_file ~/.zprofile 'source "${SampShell_ROOTDIR:-$HOME/sampshell}/.zprofile"'
}

install_shell_setup_tcsh () {
	add_to_file ~/.tcshrc "$(
		echo 'if ( ! $?SampShell_ROOTDIR ) setenv SampShell_ROOTDIR ~/sampshell'
		echo 'source "$SampShell_ROOTDIR/.tcshrc"'
	)"
}


####################################################################################################
#                                         Install Scripts                                          #
####################################################################################################

install_scripts_p () {
	readonly p_install_location="$SCRIPTS_INSTALL_LOCATION"/p

	# Install mviz
	if ! mviz_location=$(command -v mviz 2>/dev/null); then
		echo cannot install p, mviz doesnt exist
		return 1
	fi

	if [ "$p_install_location" -ef "$mviz_location" ]; then
		if [ $force ]; then
			log 'Removing old p install: %s' "$p_install_location"

			if ! [ $dry ]; then
				rm "$p_install_location" || return
			fi
		else
			log 'p already installed at: %s' "$p_install_location"
			return
		fi
	fi

	if [ -e "$p_install_location" ] || [ -L "$p_install_location" ]; then
		echo p installed but isnt mviz, uh oh
		return 1
	fi

	if [ $dry ]; then
		echo "would make $SCRIPTS_INSTALL_LOCATION, and then" \
		"link $mviz_location to $p_install_location"
	else
		set -x
		sudo mkdir -p -- "$SCRIPTS_INSTALL_LOCATION" &&
			sudo ln -s "$mviz_location" "$p_install_location"
		set +x
	fi
}

install_scripts_clenv () (
	readonly clenv_install_location="$SCRIPTS_INSTALL_LOCATION/clenv"
	if [ -e "$clenv_install_location" ]; then
		if [ $force ]; then
			echo 'Removing old clenv file because -f was given'
			sudo rm -- "$clenv_install_location" || return
		else
			log 'clenv installed at: %s' "$clenv_install_location"
			return
		fi
	fi

	cd "${SampShell_ROOTDIR:?}/script-src"
	make -B
	sudo ln -s "$PWD/clenv" "$clenv_install_location"
)

install_scripts () {
	if [ ! -d "$SCRIPTS_INSTALL_LOCATION" ]; then
		printf 'Making %s\n' "$SCRIPTS_INSTALL_LOCATION"
		sudo mkdir -p -- "$SCRIPTS_INSTALL_LOCATION" || return
	fi
	install_scripts_p
	install_scripts_clenv
}

install_homebrew () {
	if ! command -v brew >/dev/null 2>&1; then
		warn 'Homebrew is not installed.'
		return 1
	fi

	brew install ${dry:+--dry-run} zsh-autosuggestions zsh-syntax-highlighting
}

################################################################################
#                                 Parse Config                                 #
################################################################################

readonly known_shells='sh bash zsh tcsh all'
usage () { cat; } <<EOS
usage: $prog_name [options]
options:
	-h       Show usage
	-d       Dry Run: Print what would happen but dont do it; implies -v
	-v       Enable verbose outputs
	-a       Install all options
	-s SHELL Install SHELL hooks. Valid: $known_shells. Can Repeat.
	-g       Install git options
	-p       Install SampShell scripts into PATH
	-b       Install homebrew features
	-f       Forcibly reinstall
EOS

sh_sh= sh_zsh= sh_bash= sh_tcsh=
all= dry= verbose= git= scripts= brew= force=
something_specified=

while getopts 'hdvas:gpbf' opt; do
	case $opt in
	h) usage; exit ;;
	v) verbose=1 ;;
	d) dry=1 verbose=1 ;;
	f) force=1 ;;
	a) all=1 ;;
	s)
		something_specified=1
		case $OPTARG in
		sh) sh_sh=1 ;;
		zsh) sh_zsh=1 ;;
		bash) sh_bash=1 ;;
		tcsh) sh_tcsh=1 ;;
		all)
			sh_sh=1
			command -v zsh >/dev/null 2>&1 && sh_zsh=1
			command -v bash >/dev/null 2>&1 && sh_bash=1
			command -v tcsh >/dev/null 2>&1 && sh_tcsh=1
			;;
		*) die "invalid shell: %s (valid: %s)" "$OPTARG" "$known_shells"
		esac ;;
	g) something_specified=1; git=1 ;;
	p) something_specified=1; scripts=1 ;;
	b) something_specified=1; brew=1 ;;
	?) exit 2 ;;
	esac
done

# If nothing is specified, then use `-a` as the default
[ -z "$something_specified" ] && all=1

shift `expr $#`

if [ $# -ne 0 ]; then
	usage >&2; exit 1
fi


####################################################################################################
#                                      Run Install Functions                                       #
####################################################################################################
error=0

## Git Installation
[ ${git:-$all} ] && { section Git Setup; git_setup || error=1; }

## Shell setup
[ -n "$all$sh_sh$sh_bash$sh_zsh$sh_tcsh" ] && section Shell Setup
[ ${sh_sh:-$all}   ] && { install_shell_setup_sh || error=1; }
[ ${sh_bash:-$all} ] && { install_shell_setup_bash || error=1; }
[ ${sh_zsh:-$all}  ] && { install_shell_setup_zsh || error=1; }
[ ${sh_tcsh:-$all} ] && { install_shell_setup_tcsh || error=1; }

## Install scripts
[ ${scripts:-$all} ] && { section Shell Scripts; install_scripts || error=1; }

[ ${brew:-$all} ] && { section Homebrew Installs; install_homebrew || error=1; }

exit "$error"
