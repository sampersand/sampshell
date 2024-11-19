autoload -U compinit; compinit

zstyle ':completion:*' use-compctl false # never use old-style completion

if [[ $VENDOR = apple ]]; then
	zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # case-insensitive for tab completion
fi
