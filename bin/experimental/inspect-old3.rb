#!ruby

require 'optparse'

$standout = true
OptParse.new do |op|
  op.on '--no-standout', 'Disable standout' do $standout = false end
  op.on '-c', '--cstyle', 'Display escpaes with C-style `\r` etc' do $cstyle = true end
  op.on '-x', '--always-hex', 'Do not display C-style `\r`' do $cstyle = false end
  op.on '--escape-tabs-and-stuff' do $escape_tabs_and_stuff = true end
  op.on '--escape-backslash', 'Escape backslash itself' do $escape_backslash = true end
  op.on '--no-unicode', 'Escape upper bits too' do $no_unicode = true end
  op.on '-b', '--binary' do
    $no_unicode = true
    $escape_tabs_and_stuff = true
    $cstyle = false
  end

  op.parse!
  # op.on '-h'
end

BEGIN_STANDOUT = "\e[7m"
END_STANDOUT = "\e[27m"

def pre(...)
  $standout and if !@already_escaped then
    OUTPUT.concat BEGIN_STANDOUT
  end

  OUTPUT.concat(...)
  @already_escaped = true
end

def pr(...)
  $standout and if @already_escaped
    OUTPUT.concat END_STANDOUT
  end

  OUTPUT.concat(...)
  @already_escaped = false
end

C_CODEPOINTS = [0, 7, 8, 9, 10, 11, 12, 13, 27]
IS_TAB_OR_NEWLINE = [9, 10]
OUTPUT = String.new(encoding: 'binary')

ARGF.set_encoding 'binary'

line = String.new(capacity: 4096, encoding: 'binary')
while (ARGF.readpartial(4096, line) rescue nil)
  line.each_codepoint do |char|
    # If the character is a special graphic char
    if (char < 0x20 or char == 0x7F) and ($escape_tabs_and_stuff or !IS_TAB_OR_NEWLINE.include?(char))
      if $cstyle and C_CODEPOINTS.include?(char)
        if char == 0
          pre '\\0'
        else
          pre ("" << char).inspect[1..-2]
        end
      else
        pre "\\x%02X" % char
      end
    elsif char == '\\'.ord and $escape_backslash
      pre '\\\\'
    elsif char > 0x7F and $no_unicode
      pre "\\x%02X" % char
    else
      pr "" << char
    end
  end

  print OUTPUT
  OUTPUT.clear
end

pr ''
print OUTPUT

__END__
EA 1110 1010
AD 10 1011 01
B4 10 11 0100

__END__

s = "\u3042foo\u3043"

hash = {"\u3042" => 'xyzzy'}
hash.default = 'XYZZY'
s.encode('ASCII', fallback: hash) # => "xyzzyfooXYZZY"

def (fallback = "U+%.4X").escape(x)
  self % x.unpack("U")
end
INVALID_UTF8="\xC3\x28"#.force_encoding("US-ASCII")

puts INVALID_UTF8.scrub { _1.inspect[1..-2] }
exit

p "\u3042".encode("US-ASCII", fallback: ->x{"oops"}) # => "U+3042"
conv = Encoding::Converter.new('US-ASCII', 'UTF-8')
conv.ims

exit
# p .encode("UTF-8", fallback: proc{"oops"})

__END__
require 'optparse'
require 'pathname'

# $* << '-x' << '--bytes' << '--' <<
if $*.empty? then $* << 'heツl👍🏿lo'
  $* << "x89PNG\r\n\u001A\n\u0000\u0000\u0000\rIHDR\u0000\u0000\u0005\xD8\u0000\u0000\u0003\x89\b\u0002\u0000\u0000\u0000\x81/\xD77\u0000\u0000\x80\u0000IDATx\xDA\xEC\xBDgw\xDBX\x9A\xAE\xCD\u007F\xA1\xCF\xFA\u0017\xF3\xAD\xFF͙*\x97-gYѲ\u0015H1K\xA4\u0018\xC1\x9C\xA9d\xBB쪮\xEE\xB2%1(ز,\xA7\n\x93;N\x9F鞮\x9E\x9Ep\xCE{f\xBA\xAA\u07BD\t\x89\x96D\u0012\xDC\e\xD8\u0000A\xE9\xE6\xBA\u0016\u0017D\u0002D H\u0013\x97\xEF\xE7ٖ\xF5\xBD\u001F\u0001\u0000@wv\xF5e\x8D\x8B\u001DM\fX,m\u001F_U\xC1\xF6\x8F\x83\u0016\v\xB9\xEFwV\xCE\a\xF5s\xC8\xF2E\xA0\xA6?\xE6\xD8\xD3ޟQ\xBD\xF8`\xF6\xD9\xF7\xE1\x8EyY\xEB\u0017x\xFEA\xD7\xFB\xD7\u0005~\xBF\u0001\u0000t\u0082C\u0000\u0000\x80\xD3\xE1r:TĈ\u0010:2\x83-ZǼ\xBF\xE3\xB7/\u0010\xF0J\x90J\xA6p\u001F\u0010\u001Fp\u0019}(Gz\xE6M\xF0\u0003\t\u0000\u0000\u0011\u0003\u0000\u0000\xE7\xD5\xE9\fX,\u0002C:\x83B\xB5\x8E\xA9X\xED\v\xA0\x96\xE0\x95z*>.\xA0\xF5\x80\xC50\x9Eu\u0013\x82_ \u0000\u0000\x88\u0018\u0000\u0000\u0000\xECP\u0011#N\xEB\f\xB2i\u001D\xC1\xC5Y\xA2\xB8\x90\xD7T\xB0K}\xAD\x96.\x8E\xF5\x80\xC88\xCF\u0016\u0003\xD2\u0004\u0000\u0000 b\u0000\u0000\u0000\"F5\x83,\xAFv\xF1~\xF7\xC3+A0\t\u0016L\u0017\xD9z@a@d\u0000\u0000\u0000\x80\x88\u0001\u0000\u0000\x88\u0018>\u0011\x83\xA20x%h\xA6\x8B';\xE0/\xA00\u0000"
#   $examples = array(
#     'Valid ASCII' => "a",
#     'Valid 2 Octet Sequence' => "\xc3\xb1",
#     'Invalid 2 Octet Sequence' => "\xc3\x28",
#     'Invalid Sequence Identifier' => "\xa0\xa1",
#     'Valid 3 Octet Sequence' => "\xe2\x82\xa1",
#     'Invalid 3 Octet Sequence (in 2nd Octet)' => "\xe2\x28\xa1",
#     'Invalid 3 Octet Sequence (in 3rd Octet)' => "\xe2\x82\x28",
#     'Valid 4 Octet Sequence' => "\xf0\x90\x8c\xbc",
#     'Invalid 4 Octet Sequence (in 2nd Octet)' => "\xf0\x28\x8c\xbc",
#     'Invalid 4 Octet Sequence (in 3rd Octet)' => "\xf0\x90\x28\xbc",
#     'Invalid 4 Octet Sequence (in 4th Octet)' => "\xf0\x28\x8c\x28",
#     'Valid 5 Octet Sequence (but not Unicode!)' => "\xf8\xa1\xa1\xa1\xa1",
#     'Valid 6 Octet Sequence (but not Unicode!)' => "\xfc\xa1\xa1\xa1\xa1\xa1",
# );

end

OptParse.new do |op|
  op.on '-E', ''
end

# $*.first.concat "\xc3\x28\xe2\x28\xa1"
# $*.first.each_grapheme_cluster do |char|
#   p char
# end

__END__
# $*[0] = '-h'

$base = nil
$mode = :bytes
$files = []
OptParse.new do |op|
  op.banner = "usage: #{op.program_name} [bases] [forms] [--] [...]"



# Supply these options
  op.on '-h', '--help', 'print this message, then exit' do
    puts op.help
    exit
  end

  # p op.environment 'HOME'

  op.on '-f', '--file=FILE', "Inspect FILE's contents" do |path|
    $files << path
    fail 'todo'
  end

  ## BASE REPRESENTATIONS
  op.on 'Bases:'
  op.on '-x', '--hex',     'Print things out in base 16' do $base = 16 end
  op.on '-d', '--decimal', 'Print things out in base 10' do $base = 10 end
  op.on       '--binary',  'Print things out in base 2'  do $base = 2 end
  op.on       '--octal',   'Print things out in base 8'  do $base = 8 end
  op.on       '--string',  'Print things out as strings' do $base = nil end
  op.on       '--base=NUM', Integer, 'Print things out in base NUM' do |n| $base = n end

  ## DISPLAY FORMS
  op.on 'Forms:'
  op.on '-u', '--unicode', 'Print out unicode characters' do $mode = :unicode end
  op.on '-g', '--grapheme', 'Print out grapheme clusters' do $mode = :grapheme end
  op.on '-c', '--chars', 'Print out bytes' do $mode = :chars end
  op.on '-b', '--bytes', 'Print out bytes' do $mode = :ascii end
  op.on '-a', '--ascii', 'Print out ascii bytes' do $mode = :ascii end

  op.on '-i', '--inspect', 'prints out in ruby inspect style' do $inspect = true end


  ## Which to escape
  op.on '--escape-which=(all,nonprint,none)', 'only escape whats' do $escape = _1 == 'all' end
  op.on '--escape-how=  (c,etc)', 'only escape whats' do $escape = _1 == 'all' end

  op.parse!

  # $files.empty?
end

def format_base(val)
  return val.to_s $base
  case $base
  when 2 then "%08b" % val
  when 16 then "%04x" % val
  end
end

def iterator(word)
  case $mode
  when :unicode then word.each_codepoint
  when :bytes then word.each_byte
  when :grapheme then word.each_grapheme_cluster
  else raise "[bug] unknown mode: #$mode"
  end
end

class Printer
  def initialize(sep = 5)
    @byteno = 1
    @column = 1
    @sep = sep
  end

  def write_byte(byte, amount=1)
    if @column == 1
      puts if @byteno != 1
      @column += $stdout.write "%05d\t" % @byteno
    end


    @column += $stdout.write("%0#{@sep}s" % byte)
    @byteno += amount
    if @column > (@column %= 80) #=
      puts
      @column += $stdout.write "%05d\t" % @byteno
    end
  end
end
$writer = Printer.new

def handle(word)
  if $base == nil && $inspect
    p case $mode
      when :unicode  then word.chars
      when :ascii    then word.bytes.map(&:chr)
      when :grapheme then word.grapheme_clusters
      else raise "unknown mode: #{$mode.inspect}"
      end
    return
  end

  if $base == nil
    puts (case $mode
      when :unicode then word.chars
      when :ascii
        word.each_byte do |byte|
          if (chr=byte.chr) =~ /[[:print:]]/
            $writer.write_byte chr
          else
            $writer.write_byte byte.to_s(16)
          end
        end
        return
      when :grapheme then word.grapheme_clusters
      else raise "unknown mode: #{$mode.inspect}"
      end).join ' '
    return
  end

  if $base
    case $mode
    when :unicode
      puts word.each_codepoint.map { format_base _1 }.join ' '

    when :bytes, :ascii
      puts word.each_codepoint.map { format_base _1 }.join ' '

    when :grapheme
      puts word.each_grapheme_cluster.map { |cluster| cluster.each_codepoint.map {
        format_base _1
      }.join '_' }.join ' '
    else raise "unknown mode: #{$mode.inspect}"
    end
  end
end

INPUT = $*.empty? ? $stdin.to_a(chomp: true) : $*
INPUT.each do
  handle _1
end

if $mode == :ascii and false
  print "bytes:     ", INPUT[0].each_byte.map{ _1.to_s $base || 16 }.join(' '), "\n"
  print "codepoint: ", INPUT[0].each_codepoint.map{ p(_1).to_s $base || 16 }.join(' '), "\n"
  p 1
end
# $base = 16
# $mode = :bytes ; INPUT.each do puts handle _1 end
# $mode = :unicode; INPUT.each do puts handle _1 end
# $mode = :grapheme; INPUT.each do puts handle _1 end

__END__
iter_fn = {
  unicode:  :each_codepoint,
  grapheme: :each_grapheme_cluster,
  char:     :each_char,
  byte:     :each_byte,
}.fetch $mode

INPUT.each do |word|
  puts word.send(iter_fn).map {
    $base ? $1.to_i($base) : $1
  }.to_a.join ' '
end
p $base
__END__

$h || $_help and (puts <<EOS; exit)
usage: #{File.basename $0} [-h] [-u | -d | -b=num] [args...]
options:
  -u print out unicode numbers
  -d same as `-b=10`
  -b interpret args in base num, instead of the default 16
Prints the base-n ascii representation of its arguments, one line per arg.
If no args are given, defaults to stdin.
EOS

INPUT = ($*.empty? ? $stdin.map(&:chomp) : $*)

case
when $u, $_unicode then
if $u
  INPUT.each do |word|
    p word.chars#grapheme_clusters
    p word.grapheme_clusters
  end
end

BASE = ($b&.to_i) || ($d && 10) || 16

INPUT.each do |word|
  puts word.bytes.map{|byte| byte.to_s BASE}.join(' ')
end
