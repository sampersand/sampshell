# old utilities from work laptop i dont need

# Create a tempfile
tmpf (){ export file=$(mktemp $@); tee $file }

# Get a "clear prompt", for debugging prompt stuff i think
_clprompt () {
	unset RPS1
	unset -mf '_SampShell*'
	unset -f update_terminal_cwd _zsh_highlight_preexec_hook _zsh_highlight_main__precmd_hook shell_session_save
}
alias clprompt='_clprompt; set -x'

# Both no longer needed as the `posix/chomp` now exists
function chomp () print -rnl -- "$(</dev/stdin)"
function chomp () ruby -lne 'print $l if $l; $l=$_; END{$>.write $l}'

