#!ruby
require 'optparse'
require 'pathname'

# $* << '-x' << '--bytes' << '--' <<
if $*.empty? then $* << 'heツl👍🏿lo' end
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
