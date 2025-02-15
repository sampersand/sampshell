#!/usr/bin/env ruby
require 'optparse'
$*.replace %w[ -mw80 Hello World --justify=left ]
OPTIONS={}
OptParse.new nil, 20 do |op|
  op.banner.concat ' message [...]'
  op.on '-w', '--width=N', Integer, 'Total line width'
  op.on '-p', '--pre=N', Integer, 'Length to add before the line'
  op.on '-s', '--style=STYLE', 'Use STYLE instead of default `#`'
  op.on '-m', '--multiline', 'Interpret each arg as a separate line'
  op.on '-b', '--blank', 'Add a blank line before and after input'
  op.on '-p', '--pbcopy', 'Pipe output to pbcopy command'
  op.on       '--justify=HOW', %w[left center right], 'left, center, or right justify'
  op.parse! into: OPTIONS rescue op.abort $!
  $*.empty? and abort op.help
end

args = $*
args.replace [args.join(' ')] unless OPTIONS[:multiline]
args = ['', args, ''] if OPTIONS[:blank]

width = OPTIONS.fetch(:width, 80) - OPTIONS.fetch(:pre, 0)
__END__
def print_lines(prefix, suffix, third, *lines)
  msg_width = third - prefix.length - suffix.length
  lines.each do |line|


__END__
# Calculate the width
width=$((width - pre))

print_lines () {
  prefix=$1
  suffix=$2
  msg_width=$(($3 - ${#prefix} - ${#suffix}))
  shift 3

  for line
  do
    spacing=$(( (${#line} + msg_width) / 2  ))
    remainder=$(( msg_width - spacing ))
    printf "%${pre}s"
    printf "${prefix}%${spacing}s%${remainder}s${suffix}\n" "$line"
  done
}

[ "$pre" = 0 ] && pre= # Make yash happy?

case $style in
  \#)
    printf "%${pre}s"
    printf "%${width}s\n" | tr ' ' "$style"
    [ -n "$single_line" ] && exit
    print_lines '#' '#' $width "$@"
    printf "%${pre}s"
    printf "%${width}s\n" | tr ' ' "$style" ;;
  /)
    printf "%${pre}s"
    printf "%${width}s\n" | tr ' ' "$style"
    [ -n "$single_line" ] && exit
    print_lines '//' '//' $width "$@"
    printf "%${pre}s"
    printf "%${width}s\n" | tr ' ' "$style" ;;
  \*)
    printf "%${pre}s"
    printf "/%$((width-2))s\n" | tr ' ' "$style"
    [ -n "$single_line" ] && exit
    print_lines ' *' '*' $((width - 1)) "$@"
    printf " %${pre}s"
    printf "%$((width-2))s/\n" | tr ' ' "$style" ;;
  *) die 'unknown style %s' "$style" ;;
esac
