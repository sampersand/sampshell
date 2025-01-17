#!zsh

PS1= # Reset ps1

################################################################################
#                                                                              #
#                                Bracket Prefix                                #
#                                                                              #
################################################################################

() {
	local timefmt
	zstyle -s ':sampshell:prompt:time' format timefmt

	PS1+='%B%F{blue}[%b'                           # [
	PS1+="%F{cyan}%D{${timefmt:-%_I:%M:%S %p}} "   #   Current time
	PS1+='%F{15}%U%!%u '                           #   History Number
	PS1+='%(?.%F{green}✔.%F{red}✘%B)%?%b'          #   Previous exit code
	PS1+='%(2L. %F{red}SHLVL=%L.)'                 #   (SHLVL, if >1)
	PS1+='%(1j.%F{166} (%j job%(2j.s.)).)'         #   (job count, if >0)
	PS1+='%B%F{blue}]%b '                          # ]
}

################################################################################
#                                                                              #
#                            Username and Hostname                             #
#                                                                              #
################################################################################

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

################################################################################
#                                                                              #
#                                     Path                                     #
#                                                                              #
################################################################################

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

################################################################################
#                                                                              #
#                               Git information                                #
#                                                                              #
################################################################################

# :sampshell:prompt:git:dirty:$PWD display -T      # Show `*` and `+` for untracted states
# :sampshell:prompt:git:stash:$PWD display -t      # Show `$` when there's something stashed
# :sampshell:prompt:git:untracked:$PWD display -T  # Also show untracted files via `!`
# :sampshell:prompt:git:conflict:$PWD display -T   # Show when there's a merge conflict
# :sampshell:prompt:git:hidepwd:$PWD display -T    # Don't show git when the PWD is ignored.
# :sampshell:prompt:git:upstream:$PWD display -t   # Show the difference for upstream

# If we even are even displaying git in the first place? (default to yes with `-T`)
if zstyle -T ':sampshell:prompt:git' display; then
	source ${0:P:h}/git_prompt.sh # Load the git PS1 script.

	function _SampShell-ps1-git {
		psvar[1]= psvar[2]=

		# If we're just not displaying git at all, then return.
		zstyle -T ":sampshell:prompt:git:${(q)PWD}" display || return 0

		local GIT_PS1_SHOW{UNTRACKEDFILES,{DIRTY,CONFLICT}STATE,UPSTREAM}
		local GIT_PS1_HIDE_IF_PWD_IGNORED
		local p=${(q)PWD}

		zstyle -T :sampshell:prompt:git:dirty:$p     display && GIT_PS1_SHOWDIRTYSTATE=1
		zstyle -t :sampshell:prompt:git:stash:$p     display && GIT_PS1_SHOWSTASHSTATE=1
		zstyle -T :sampshell:prompt:git:untracked:$p display && GIT_PS1_SHOWUNTRACKEDFILES=1
		zstyle -T :sampshell:prompt:git:conflict:$p  display && GIT_PS1_SHOWCONFLICTSTATE=1
		zstyle -T :sampshell:prompt:git:hidepwd:$p  display && GIT_PS1_HIDE_IF_PWD_IGNORED=1
		zstyle -t :sampshell:prompt:git:upstream:$p  display && GIT_PS1_SHOWUPSTREAM=1

		local GIT_PS1_STATESEPARATOR= # Set to an empty string so there's no separator
		psvar[1]=${"$(__git_ps1 '⇄%s ')"/\%\%/!} # the `/%%/!` replaces stash `%` with my `!`
		psvar[2]=$psvar[1]

		local pattern
		if zstyle -s :sampshell:prompt:git:$p pattern pattern; then
			psvar[2]=${psvar[2]/${~pattern}/…}
		fi
	}

	# Always run this function before a prompt, instead of adding it as part
	# of the prompt. (`$()` and `${}` are done before prompt expansions, and
	# so there's no way to get a length.)
	add-zsh-hook precmd _SampShell-ps1-git

	# Only expand the full thing if there's a significant amount of space left.
	PS1+='%F{43}%$((COLUMNS / 3))(l.%2v.%1v)'
fi

################################################################################
#                                                                              #
#                                   Ending %                                   #
#                                                                              #
################################################################################

PS1+='%F{8}%#%f ' # ending %
