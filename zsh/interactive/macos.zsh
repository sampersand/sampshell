### ZSH config for macOS specifically
[[ $VENDOR != apple ]] && return # Ensure we're macos

## Add case-insensitive for tab completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'