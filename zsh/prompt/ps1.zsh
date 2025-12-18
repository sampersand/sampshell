### Config for the `PS1` prompt, i.e. the thing that's shown on the left-hand-side of the screen.
# This file makes heavy use of `zstyle`, which is ZSH's alternative to environment variables. See
# the `zstyles.md` file in this folder for more details.
###

## Mark `PS1` as global (so functions can interact with it), but not exported (as then other shells
# would inherit it, and they certainly don't understand the formatting), and initialize it to an
# empty string (so we can construct it down below)
typeset -g PS1=''
1 () source ~ss/zsh/prompt/ps1.zsh
2 () source ~ss/zsh/prompt/ps12.zsh
3 () source ~ss/zsh/prompt/ps13.zsh

####################################################################################################
#                                          Bracket Prefix                                          #
####################################################################################################

() {
	local timefmt
	zstyle -s ':sampshell:prompt:time' format timefmt

	PS1+='%B%F{blue}[%b'                                        # [
	PS1+="%F{cyan}%D{${timefmt:-%_I:%M:%S.%. %p}} "             #   Current time
	PS1+='%f${_SampShell_history_disabled:+%F{red\}}%U%!%u '    #   History Number; red if disabled
	PS1+='%(?.%F{green}✔.%F{red}✘%B)%?%b'                       #   Previous exit code
	PS1+='%(2L. %F{red}SHLVL=%L.)'                              #   (SHLVL, if >1)
	PS1+='%(1j.%F{166} (%j job%(2j.s.)).)'                      #   (job count, if >0)
	PS1+='%f (${#_SampShell_stored_lines}) ' # amoutn of stored lines; todo, update this
	PS1+='%B%F{blue}]%b '                                       # ]
}

####################################################################################################
#                                      Username and Hostname                                       #
####################################################################################################

# By default, the user and host are always displayed. This can be disabled by
# setting their `display` to false, or by setting an `expected` value. If the
# expected value is set but none of its values are equal, the host/user will be
# displayed in bold and red.
() {
	# NOTE: Don't change the condition's orderings; the `elif` below relies
	# on `expected` being executed second.
	if ! zstyle -T ':sampshell:prompt:user' display ||
	     zstyle -t ':sampshell:prompt:user' expected $USER
	then
		# Do nothing; Either an explicit opt-out, or we matched.
	elif (( $? == 2 )) then
		PS1+='%F{242}%n' # `expected` was undefined, so use the default
	else
		PS1+='%F{red}%B%n%b' # ERR! `expected` didn't contain `$USER`
	fi

	# (Same layout as `user`)
	if ! zstyle -T ':sampshell:prompt:host' display ||
	     zstyle -t ':sampshell:prompt:host' expected $HOST
	then
		# Do nothing
	elif (( $? == 2 )) then
		PS1+='%F{242}@%M'
	else
		PS1+='%F{red}%B@%M%b'
	fi

	# Add a space if either a user or host were added.
	[[ ${PS1: -1} != ' ' ]] && PS1+=' '
}

####################################################################################################
#                                               Path                                               #
####################################################################################################

() {
	local len d='~'

	# Normally, we use relative paths (eg `~tmp/foo`), but by setting
	# `style absolute`, we use absolute paths (eg `/Users/me/tmp/foo`)
	zstyle -t ':sampshell:prompt:path' absolute-paths && d=/

	# Get the path length, which is dynamically evaluated each time the
	# prompt is rendered. default to `$((COLUMNS / 5))`. Shortening can be
	# disabled by setting the length to 0 or an empty string.
	zstyle -s ':sampshell:prompt:path' length len || len='$((COLUMNS / 5))'

	PS1+='%F{11}'                                # The path colour
	PS1+="%-1$d"                                 # always have the first component
	PS1+="%$len</…<"                             # start path truncation.
	PS1+="\${\${(*)\${(%):-%$d}##?[^/]#}/\%/%%}" # everything but first component
	PS1+='%<< '                                  # stop truncation
}

####################################################################################################
#                                         Git Information                                          #
####################################################################################################

# :sampshell:prompt:git:dirty:$PWD display      # Show `*` and `+` for untracted states
# :sampshell:prompt:git:stash:$PWD display      # Show `$` when there's something stashed
# :sampshell:prompt:git:untracked:$PWD display  # Also show untracted files via `!`
# :sampshell:prompt:git:conflict:$PWD display   # Show when there's a merge conflict
# :sampshell:prompt:git:hidepwd:$PWD display    # Don't show git when the PWD is ignored.
# :sampshell:prompt:git:upstream:$PWD display   # Show the difference for upstream

## Mark `__git_ps1` as an autoloaded function; we don't want to load it just yet in case we aren't
# going to be displaying the git prompt. (NOTE: The file must be named exactly `__git_ps1`, as the
# name of the function and the name of the file must match.) We use `emulate` to ensure that no
# weird options affect the way that we're autoloading.
emulate sh -c "autoload -RUk ${(q)0:P:h}/__git_ps1"

## The function that's used to fetch the git status.
function _SampShell-prompt-git-hook {
	emulate -L zsh # Reset the shell to the default ZSH options

	psvar[1]= psvar[2]= # Empty the variables

	## Ensure we're even displaying git
	zstyle -T ":sampshell:prompt:git:${(q)PWD}" display || return 0

	## Configure variables for the `__git_ps1` function
	local GIT_PS1_{HIDE_IF_PWD_IGNORED,SHOW{UNTRACKEDFILES,UPSTREAM,{DIRTY,CONFLICT}STATE}}
	zstyle -T ":sampshell:prompt:git:dirty:$PWD"     display && GIT_PS1_SHOWDIRTYSTATE=1
	zstyle -t ":sampshell:prompt:git:stash:$PWD"     display && GIT_PS1_SHOWSTASHSTATE=1
	zstyle -T ":sampshell:prompt:git:untracked:$PWD" display && GIT_PS1_SHOWUNTRACKEDFILES=1
	zstyle -T ":sampshell:prompt:git:conflict:$PWD"  display && GIT_PS1_SHOWCONFLICTSTATE=1
	zstyle -T ":sampshell:prompt:git:hidepwd:$PWD"   display && GIT_PS1_HIDE_IF_PWD_IGNORED=1
	zstyle -t ":sampshell:prompt:git:upstream:$PWD"  display && GIT_PS1_SHOWUPSTREAM=1

	## Perform the substitution
	local GIT_PS1_STATESEPARATOR= # Set to an empty string so there's no separator
	psvar[1]=${$(__git_ps1 '⇄%s ')/\%\%/!} # the `/%%/!` replaces `%` with my `!`
	psvar[2]=$psvar[1]

	## If there's a prefix pattern, then set `psvar[2]` to that replacement.
	local pattern
	if zstyle -s ":sampshell:prompt:git:$PWD" pattern pattern; then
		psvar[2]=${(*)psvar[2]/${~pattern}/…}
	fi
}

## Only add the hooks and the git prompt if we're even displaying git in the first place (which is
# true by default.)
if zstyle -T ':sampshell:prompt:git' display; then
	# Always run this function before a prompt, instead of adding it as part
	# of the prompt. (`$()` and `${}` are done before prompt expansions, and
	# so there's no way to get a length.)
	add-zsh-hook precmd _SampShell-prompt-git-hook

	# Only expand the full thing if there's a significant amount of space left.
	PS1+='%F{43}%$((COLUMNS / 5))(l.%2v.%1v)'
fi

####################################################################################################
#                                             Ending %                                             #
####################################################################################################

PS1+='%F{8}%#%f ' # ending %
