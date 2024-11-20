autoload -U compinit; compinit

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
return
 You way wonder why you would want to ignore such functions at this point. After all, you're only likely to be doing completion when you've already typed the first character, which either is `_' or it isn't. It becomes useful with correction and approximation --- particularly since many completion functions are similar to the names of the commands for which they handle completion. You don't want to be offered `_zmodload' as a completion if you really want `zmodload'. The combination of labels and ignored patterns does this for you. 

   zstyle ':completion:*:*:-command-:*' tag-order \ 
  'functions:-non-comp:non-completion\ functions *' functions
# Don't complete functoins which start with underscores
  zstyle ':completion:*:*:-command-:*' tag-order 'functions:-non-comp'
    zstyle ':completion:*:functions-non-comp' ignored-patterns '_*'
# Colour kill red!
  zstyle ':completion:*:*:kill:*:processes' list-colors  \
    '=(#b) #([0-9]#)*=0=01;31'
## TODO: command replacement by one?

  zstyle ':completion:*:-command-' group-order \ 
      builtins functions commands
zstyle ':completion:*' completer _complete _approximate:-one \
 _complete:-extended _approximate:-four
zstyle ':completion:*:approximate-one:*' max-errors 1
zstyle ':completion:*:complete-extended:*' \
 matcher 'r:|[.,_-]=* r:|=*'
zstyle ':completion:*:approximate-four:*' max-errors 4

fignore+=(o) # ignore `.o` files
zstyle ':completion:*' completer _expand_alias _expand _correct _approximate
# zstyle ':completion:*:correct:*' max-errors 2
# zstyle ':completion:*:approximate:*' max-errors 5 numeric #
# zstyle ':completion:*:_expand:*' tag-order add-space

# zstyle ':completion:*' completer _expand:-add-space #_expand:-subst
# zstyle ':completion:*:expand-add-space:*' add-space yes
# zstyle ':completion:*:expand-subst:*' substitute yes


zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$SampShell_GENDIR/.zcompcache"
zstyle ':completion:*' menu select search

# zstyle 'completion::complete:-command-' <-- somehow do aliases first
zstyle ':completion:*:*:cd:*' file-sort modification
setopt MENU_COMPLETE

if false; then
	zstyle ':completion:*:*:cp:*' file-sort size
zstyle ':completion:*' file-sort modification
zstyle ':completion:*:*:*:*:corrections' format '%F{yellow}!- %d (errors: %e) -!%f'
zstyle ':completion:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'
fi
