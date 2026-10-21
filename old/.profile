# No need to set FCEDIT---I don't use `fc` at all (up arrow is good enough lol),
# and the default most shells pick of `$VISUAL`/`$EDITOR` works good enough.
# AND, even the posix specified `ed` I know how to use, so there's really no
# need to set this anymore.
## Use `vim` for editing history commands. (This is only really needed for
# shells without better history mechanisms, which are quite rare---even dash has
# history if `set -o emacs` is enabled.)
export FCEDIT="${FCEDIT-vim}"


# Instead of setting them to default values, I just used the default instead.
################################################################################
#                                                                              #
#                   Ensure XDG Environment Variables Are Set                   #
#                                                                              #
################################################################################

## Make sure the XDG environment variables are set to valid values, and export
# them.
SampShell_ensure_xdg_variable () {
   eval "
   case \${$1-} in
   /*) ;; # already set
   '') $1=\$2 ;;
   *) printf >&2 '[WARN] \$$1 is a relative path (%s). using default: %s\n' \"\$$1\" \"\$2\"
      $1=\$2 ;;
   esac
   export $1"
}

SampShell_ensure_xdg_variable XDG_DATA_HOME "$HOME/.local/share"
SampShell_ensure_xdg_variable XDG_CONFIG_HOME "$HOME/.config"
SampShell_ensure_xdg_variable XDG_STATE_HOME "$HOME/.local/state"
SampShell_ensure_xdg_variable XDG_CACHE_HOME "$HOME/.cache"
[ -d /run/user ] && SampShell_ensure_xdg_variable XDG_RUNTIME_DIR "/run/user/$UID"
unset -f SampShell_ensure_xdg_variable


