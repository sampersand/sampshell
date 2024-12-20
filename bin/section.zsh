#!/bin/zsh

set -o nounset -o noglob -o errexit

setopt extendedglob

readonly scriptname="${0##*/}"

die () {
	fmt="%s: $1\\n"
	shift
	printf >&2 "$fmt" "$scriptname" "$@"
	exit 1
}

usage () { cat; } <<USAGE
usage: $scriptname [options] [--] message here
                   -m [options] [--] lines here
options:
	-wN, --width=N         total width of the line
	-sC, --style=CHAR      print out in STYLE style
	-m, --multiline        interpret each argument as a separate line, instead of just one line.
	-b, --blank            Add a blank line before and after
	-pN, --pre=N           Add N blank characters first; modifies width
	-PN, --post=N          Add N blank characters after; modifies width
	-aN, --around=N        same as -pN -PN
USAGE

# typeset -A opts=(
# 	width 80
# 	style 
# )
set -- -m -s\*a
# zparseopts -D -E -F -K -A opts      \
zparseopts -D -F -A opts      \
	{w,-width}: \
	{h,-help}=h \
	{m,-multiline} \
	{b,-blank} \
	{p,-pre}: \
	{P,-post}: \
	{s,-style}:- \
	{a,-around}:

if (( $+opts[-h] || $+opts[--help] )) { usage; exit; }

readonly multiline=$(( $+opts[-m] || $+opts[--multiline] ))
readonly     blank=$(( $+opts[-b] || $+opts[--blank] ))
readonly style=$(( $+opts[-s] || $+opts[--style] ))

integer width=$(( opts[-w] || opts[--width] || 80 ))
echo $width
exit

echo $multiline
	# {h,-help}             \
	# {a,-all}              \
	# -pwd-max-len:         \
	# {l,-show-login-info}: \
	# {U,-user,-username}:  \
	# {H,-host,-hostname}:  \
	# -branch-pattern:      \

echo ${(kvq)opts}
exit

width=80
style=\#
multiline=
blank=
pre=0
post=0


while (( # != 0 )) do
	option=$1; shift

	case $option in
	--) break ;;

	-h | --help)
		echo $width
		exit
		usage
		exit 0 ;;

	-m | --multiline) multiline=1 ;;
	-b | --blank) blank=1 ;;

	-w) (( ! # ))
	((#b)-w(<->)(*))
		width=$match[1]
		[[ -n $match[2] ]] && set -- -$match[2] $@ 
		;;

	-s | --style) style=${1:?style expects an argument}; shift ;;
	-s?) style=${option#-s} ;;
	-s?*) style=$(printf %c "${option#-s}"); set -- "-${option#-s?}" "$@" ;;
	--style=?*) style=${option#--style} ;;
	--style=) die 'style expects an argument' ;;

	-a | --around) tmp=${1:?around expects an argument}; shift; set -- -p"$tmp" -P"$tmp"  ;;
	-a?*) set -- -a "${option#-a}" "$@" ;;
	--around=?*) set -- -a "${option#--around=}" "$@" ;;
	--around=) die 'around expects an argument' ;;

	-p | --pre) pre=$(printf %d "${1:?pre expects an argument}"); shift ;;
	-p?*) set -- -p "${option#-p}" "$@" ;;
	--pre=?*) set -- -p "${option#--pre=}" "$@" ;;
	--pre=) die 'pre expects an argument' ;;

	-P | --post) post=$(printf %d "${1:?post expects an argument}"); shift ;;
	-P?*) set -- -P "${option#-P}" "$@" ;;
	--post=?*) set -- -P "${option#--post=}" "$@" ;;
	--post=) die 'post expects an argument' ;;

	-[!-]?*)
		rest2=${option#-?}
		rest1=${option%"$rest2"}
		shift
		set -- "$rest1" "-$rest2" "$@"
		continue ;;

        -*) die 'unknown option given: %s' "$option" ;;

	*) set -- "$option" "$@"; break
	esac
done

for i in `seq -w 1 $((width + 1))`; do printf ${i#?}; done; echo 

[ $# -eq 0 ] && { usage >&2; exit 1; }

[ $multiline ] || set -- "$*"
[ $blank ] && set -- '' "$@" ''
width=$((width - pre - post))
echo $width

print_lines () {
	prefix=$1
	suffix=$2
	msg_width=$(($3 - ${#prefix} - ${#suffix}))
	shift 3
	for line; do
		spacing=$(( (${#line} + msg_width) / 2 - 1 ))
		remainder=$(( msg_width - spacing ))
		printf "${prefix}%${spacing}s%${remainder}s${suffix}\\n" "$line" ''
	done
}

case $style in
	\#)
		printf "%${pre}s"
		printf "%${width}s\n" | tr ' ' '#"'
		print_lines '#' '#' $width "$@"
		printf "%${width}s\n" | tr ' ' '#"' ;;
	/)
		printf "%${width}s\n" | tr ' ' '/'
		print_lines '//' '//' $width "$@"
		printf "%${width}s\n" | tr ' ' '/' ;;
	\*)
		printf "/%$((width-2))s\n" | tr ' ' "$style"
		print_lines ' *' '*' $((width - 1)) "$@"
		printf ' '
		printf "%$((width-2))s/\n" | tr ' ' "$style" ;;
	*) die 'unknown style %s' "$style" ;;
esac
