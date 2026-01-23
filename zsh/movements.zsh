

################################################################################
#                                                                              #
#                          Cursor Movement & Deletion                          #
#                                                                              #
################################################################################
autoload -Uz select-word-style
# zstyle ':zle:*' word-style shell


# if false; then
autoload -Uz select-word-style
zstyle ':zle:SampShell-*-argument' word-style shell

autoload -Uz backward-word-match
autoload -Uz forward-word-match
autoload -Uz backward-kill-word-match
autoload -Uz kill-word-match # `forward-kill` is actually just `kill`
zle -N SampShell-backward-argument backward-word-match
zle -N SampShell-forward-argument forward-word-match
zle -N SampShell-backward-kill-argument backward-kill-word-match
zle -N SampShell-forward-kill-argument kill-word-match

# All of these are shift+<normal value>, as i decided shift is the argument one
bindkey '^[[1;2D' SampShell-backward-argument
bindkey '^[[1;2C' SampShell-forward-argument
bindkey '^[[3;2~' SampShell-forward-kill-argument
bindkey '^[[79;2~' SampShell-backward-kill-argument # `79` is arbitrary code i picked that seems unused


# Overwrite builtins here, as theyre just aliases for lower-cases
SampShell-bracketed-paste () {
	local content
	local wantraw=${NUMERIC:-0}
	local start=$#LBUFFER

	zle .$WIDGET -N content

	if (( $wantraw == 0 )) then
		content=${content%%$'\n'##}

		# Taken from `bracketed-paste-url-magic`
		local -a schema
		zstyle -a :bracketed-paste-url-magic schema schema || schema=(http:// https:// ftp:// ftps:// file:// ssh:// sftp:// magnet:)

		if [[ $content = (${(~j:|:)schema})* ]] then
			content=${(q-)content}
		fi
	fi

	LBUFFER+=$content
	YANK_START=$start
	YANK_END=$#LBUFFER
	zle -f yank
}
zle -N bracketed-paste SampShell-bracketed-paste

