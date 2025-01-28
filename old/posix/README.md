# Posix-compliant setup

The config in this directory is designed to be POSIX-compliant, which allows it to be run from any POSIX-compliant shell (eg Bash, Zsh, or DASH). 

# TODO:
- cleanup top of env.sh
- finish interactive.sh
- `SampShell_XTRACE=1 clean-shell --none --var ZDOTDIR=/dne --shell =zsh -- -x f` fails

## Design goals
- Be POSIX compliant (lets me use different shells but still have my bare-minimum basic config)
- Be portable:
	- Keep lines 80 characters long
	- Use spaces instead of my normal tab (so copying config into dumb shells won't break their autocomplete)
	- Avoid using `\` as line terminators, in case random extra spaces are added to the ends of lines, or the backslashes are stripped by something
	- Try to keep everything within one file (especially relevant for `env.sh`), which means you only have to copy one or two files over when sshing to get your config (I might change this in the future.)
