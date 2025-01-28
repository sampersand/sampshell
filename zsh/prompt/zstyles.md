# Styles used
(TODO: Make it pretty)

```zsh
# The following are the zstyles that're used
if false; then
	# The time string that's printed out; inserted into the `%D{...}` prompt string.
	zstyle ':sampshell:prompt:time' format '%_I:%M:%S.%I %p'

	# By default, `user@home` is printed. If `display` is set to false, they can be individually
	# disabled. If not disabled, `expected` is checked for a list of expected users/hosts. If
	# expected is set, and one of its values match, then the user/host isn't printed. If it's
	# set, but _doesnt_ match, it's printed in red and bold.
	zstyle ':sampshell:prompt:user' display 1
	zstyle ':sampshell:prompt:home' display 1
	zstyle ':sampshell:prompt:user' expected (unset)
	zstyle ':sampshell:prompt:home' expected (unset)

	# Normally the path prints out relative paths (eg `~foo/bar`); set the style to `absolute`
	# to instead use absolute paths.
	zstyle ':sampshell:prompt:path' absolute-paths 0
	# The maximum length that the path can be. if it's larger than this, the rootmost dir is
	# preserved, and everything afte rit is trucnated. Set to `0` or an empty string to disable
	# truncation.
	zstyle ':sampshell:prompt:path' length '$(( COLUMS * 2 / 5))'


	# If set to 0, completely disables git
	zstyle ':sampshell:prompt:git' display 1
	# Unlike other styles, the git one uses the pwd as part of it, so that different values can
	# be set for different repos. Enable with true/false. Defaults are shown in parens
	zstyle ':sampshell:prompt:git:dirty:*'     display 1 # Show `*` and `+` for untracted states
	zstyle ':sampshell:prompt:git:stash:*'     display 0 # Show `$` when there's a stash
	zstyle ':sampshell:prompt:git:untracked:*' display 1 # Also show untracted files via `!`
	zstyle ':sampshell:prompt:git:conflict:*'  display 1 # Show when there's a merge conflict
	zstyle ':sampshell:prompt:git:hidepwd:*'   display 1 # Don't show git when the PWD's ignored
	zstyle ':sampshell:prompt:git:upstream:*'  display 0 # Show the difference for upstream

	# If set, displays the battery on the right-hand-side of the srceen
	zstyle ':sampshell:prompt:battery' display 1

	# If set, displays the airport status on the right-hand-side of the srceen
	zstyle ':sampshell:prompt:airport' display 1
fi
```
