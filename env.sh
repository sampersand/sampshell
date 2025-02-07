#### Basic config universal to _all_ POSIX-compliant shells, interactive or not.
# This file should be `.`'d by both interactive and non-interactive shells.
# However, interactive shells should also `.` the `interactive` file as well,
# after this one.
#
# Not all shells have a concept of "startup files that are _always_ loaded."
# Thus, this file's only really useful for setting config options that we might
# want to be present, in a shell-specific manner.
#
# In bash, this setting the variable `BASH_ENV` to this file can cause it to
# always be executed in non-interactive scripts. In zsh, you can use `~/.zshenv`.
#
# This file really only enables `xtrace` (set -o xtrace) if the `SampShell_XTRACE`
# variable is defined; This way it can be used for


################################################################################
#                                                                              #
#                 Enable xtrace if $SampShell_XTRACE is enabled                #
#                                                                              #
################################################################################

if [ -n "${SampShell_XTRACE-}" ]; then
	export SampShell_XTRACE # Export it in case it's not already exported.
	set -o xtrace
fi

if [ -n "${ZSH_VERSION-}" ]; then
	eval '. "${SampShell_ROOTDIR-${0:P:h}}/zsh/zshenv"'
	return
fi
