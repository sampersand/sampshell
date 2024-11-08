[[ $VENDOR != apple ]] && return

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # make tab completino case-insensitive
