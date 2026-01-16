# BUFFER='echo hi there frienfriend'
# MARK=14
# CURSOR=20
# BUFFER[MARK,CURSOR]=''
# exit
autoload -U compinit
[[ ! -e $SampShell_CACHEDIR ]] && mkdir "$SampShell_CACHEDIR"
if [[ -f $SampShell_CACHEDIR/.zcompdump ]] then
  compinit -d $SampShell_CACHEDIR/.zcompdump
else
  compinit
fi

# ZLE_REMOVE_SUFFIX_CHARS
# ZLE_SPACE_SUFFIX_CHARS
zstyle ':completion:*' use-compctl false # never use old-style completion

if [[ $VENDOR = apple ]]; then
  zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # case-insensitive for tab completion
  fignore+=(DS_Store) # boo, DS_Store files!
fi

zmodload -i zsh/complist # May not be required
zstyle ':completion:*' list-colors '' # Add colours to completions
zstyle ':completion:*:*:cd:*' file-sort modification
zstyle ':completion:*:*:rm:*' completer _ignored
zstyle ':completion:*:files' ignored-patterns '(*/|).DS_Store'
# zstyle ':completion:*:files' file-sort '!ignored-patterns '*.DS_Store'

