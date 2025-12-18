# TODO: see if this is accurate
function prompt-length() {
  emulate -L zsh
  local -i COLUMNS=${2:-COLUMNS}
  local -i x y=${#1} m
  if (( y )); then
	 while (( ${${(%):-$1%$y(l.1.0)}[-1]} )); do
		x=y
		(( y *= 2 ))
	 done
	 while (( y > x + 1 )); do
		(( m = x + (y - x) / 2 ))
		(( ${${(%):-$1%$m(l.x.y)}[-1]} = m ))
	 done
  fi
  typeset -g REPLY=$x
}

function fill-line() {
  emulate -L zsh
  prompt-length $1
  local -i left_len=REPLY
  prompt-length $2 9999
  local -i right_len=REPLY
  local -i pad_len=$((COLUMNS - left_len - right_len - ${ZLE_RPROMPT_INDENT:-1}))
  if (( pad_len < 1 )); then
	 # Not enough space for the right part. Drop it.
	 typeset -g REPLY=$1
  else
	 local pad=${(pl.$pad_len..─.)}  # pad_len spaces
	 typeset -g REPLY=${1}${pad}${2}
  fi
}

# Sets PROMPT and RPROMPT.
#
# Requires: prompt_percent and no_prompt_subst.
function set-prompt() {
  emulate -L zsh
  local git_branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)"
  git_branch=${git_branch//\%/%%}  # escape '%'

  # ~/foo/bar                     master
  # % █                            10:51
  #
  # Top left:      Blue current directory.
  # Top right:     Green Git branch.
  # Bottom left:   '#' if root, '%' if not; green on success, red on error.
  # Bottom right:  Yellow current time.
  local top_left top_right bottom_left bottom_right

  top_left='┌─[%(?.%F{green}✔.%F{red}✘%B)%?%b%f]-[%F{yellow}%~%f]-[!%!]-[%n@%M]-[%y]-[J%j-L%L]'
  top_right='┐'
  bottom_left='└%F{%(?.green.red)}%#%f '
  PS1+='%F{11}'                                # The path colour
  PS1+="%-1$d"                                 # always have the first component
  PS1+="%$len</…<"                             # start path truncation.
  PS1+="\${\${(*)\${(%):-%$d}##?[^/]#}/\%/%%}" # everything but first component
  PS1+='%<< '                                  # stop truncation

  bottom_right='┘'

  # PS1+="%F{cyan}%D{${timefmt:-%_I:%M:%S.%. %p}} "
  # top_left='┌─⎨%F{red}%n@%M%f⎬'
  # top_left+='─⎨%F{blue}%~%f⎬'
  # # top_left+='%(1j.─⎨%F{166}%j job%(2j.s.)%f⎬─.)'

  # top_left+="%F{cyan}%D{${timefmt:-%_I:%M:%S.%. %p}} "             #   Current time
  # top_left+='%f${_SampShell_history_disabled:+%F{red\}}%U%!%u '    #   History Number; red if disabled
  # top_left+='%(?.%F{green}✔.%F{red}✘%B)%?%b'                       #   Previous exit code
  # top_left+='%(2L. %F{red}SHLVL=%L.)'                              #   (SHLVL, if >1)
  # top_left+='%(1j.%F{166} (%j job%(2j.s.)).)'                      #   (job count, if >0)
  # top_left+='%f (${#_SampShell_stored_lines}) ' # amoutn of stored lines; todo, update this

  # top_right="%F{green}${git_branch}%f┐"
  # bottom_left='└%F{%(?.green.red)}%#%f '
  # bottom_right='%F{yellow}%T%f┘'

  local REPLY
  fill-line "$top_left" "$top_right"
  PROMPT=$REPLY$'\n'$bottom_left
  RPROMPT=$bottom_right
}

typeset -aU precmd_functions
precmd_functions+=(set-prompt)
# unset RPS1
# PS1=

# PS1='%F{8}%#%f ' # ending %
