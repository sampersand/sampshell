#!csh
alias warn	'echo >/dev/stderr'

if ( $?prompt ) then
	# Set SHLVL, as CSH doesn't support it
	if ( $?SHLVL ) then
		@ tmp = $SHLVL + 1
		setenv SHLVL $tmp
		unset tmp
	else
		setenv SHLVL 1
	endif

	# Shell options
	set filec ignoreeof savehist notify
	set fignore     = ( .o .out )
	set cdpath      = ( ~ )
	set histchars   = '\!,'
	set history     = 500
	set time        = 5
	set path        = ( . ~/bin $path:x )

	# Set the prompt
	set prompt = "`tput smso`[\!"
	if ( $SHLVL != 1 ) set prompt = "$prompt L$SHLVL"
	set prompt = "$prompt] `whoami`>`tput rmso` "

	# Aliases
	alias mv mv -i
	alias cp cp -i
	alias rm rm -i
	alias reload source ~/.cshrc
	alias h      history
	alias edc    'ed \!:*:x ~/.cshrc'
	alias +x     chmod +x
	alias md     '\mkdir \!*:q && \cd \!*:q'
	alias m      'mkdir \!*:q && cd \!*:q'
	# alias rd     'rmdir \!:q'
	alias ls     'ls -AFq --color=auto'
	alias ..     cd ..

	alias cdd       'cd `dirname \!*`'
endif
