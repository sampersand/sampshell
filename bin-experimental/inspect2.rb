#!ruby
require 'optparse'

$STANDOUT = true
$ESCAPE_WHITESPACE = true
$TRAILING_NEWLINE = true


OptParse.accept :ACCEPT_LONGFORM, /\A(always|yes|on|true|never|no|off|false|auto|default)\z/ do |option|
  case option
  when nil, 'always', 'yes', 'on', 'true' then true
  when 'never', 'no', 'off', 'false' then false
  when 'auto', 'default' then nil
  else fail
  end
end

OptParse.new do |op|
  op.on '-w', '--escape-whitespace', "Don't escape non-space whitespace" do
    $ESCAPE_WHITESPACE = false
  end

  op.on '-i', '--input-encoding=ENCODING', 'Set input encoding (default: UTF-8)' do |enc|
    if enc == '?'
      puts Encoding.name_list.join(', ')
      exit
    end

    begin
      $INPUT_ENCODING = Encoding.find enc
    rescue ArgumentError
      abort "#{op.program_name}: invalid encoding '#{enc}'; use '?' for a list"
    end
  end

  op.on '-o', '--output-encoding=ENCODING', 'Set output encoding (default: the input encoding)' do |enc|
    if enc == '?'
      puts Encoding.name_list.join(', ')
      exit
    end

    begin
      $OUTPUT_ENCODING = Encoding.find enc
    rescue ArgumentError
      abort "#{op.program_name}: invalid encoding '#{enc}'; use '?' for a list"
    end
  end

  op.on '-\\', 'Same as --escape-backslash but without the options' do
    $ESCAPE_WHITESPACE = true
  end

  op.on '--escape-backslash[=HOW]', :ACCEPT_LONGFORM, 'Also escape backslashes. Defaults to on when STANDOUT is enabled' do |bs|
    $ESCAPE_BACKSLASH = bs
  end

  op.on '-n', '--suppress-trailing-newline', :ACCEPT_LONGFORM 'Do not print out a trailing newline' do
    $TRAILING_NEWLINE = false
  end

  op.on '-x', '--always-hex', 'Do not display C-style `\r`' do
    $CSTYLE = false
  end

  op.on '-s', '--no-STANDOUT', 'Disable STANDOUT' do $STANDOUT = false end
  op.on '-c', '--cstyle', 'Display escpaes with C-style `\r` etc' do $CSTYLE = true end
  op.on '--escape-tabs-and-stuff' do $escape_tabs_and_stuff = true end
  # op.on '--escape-backslash', 'Escape backslash itself' do $escape_backslash = true end
  op.on '--no-unicode', 'Escape upper bits too' do $no_unicode = true end
  op.on '-b', '--binary' do
    $no_unicode = true
    $escape_tabs_and_stuff = true
    $CSTYLE = false
  end

  op.parse! rescue abort "#{op.program_name}: #$!"
  # op.on '-h'
end

$INPUT_ENCODING ||= 'UTF-8'
$OUTPUT_ENCODING ||= $INPUT_ENCODING
$CSTYLE = true unless defined? $CSTYLE
$ESCAPE_BACKSLASH = !$STANDOUT if $ESCAPE_BACKSLASH.nil?

BEGIN_STANDOUT = "\e[7m"
END_STANDOUT = "\e[27m"

def pre(...)
  $STANDOUT and if !@already_escaped then
    OUTPUT.concat BEGIN_STANDOUT
  end

  OUTPUT.concat(...)
  @already_escaped = true
end

def pr(...)
  $STANDOUT and if @already_escaped
    OUTPUT.concat END_STANDOUT
  end

  OUTPUT.concat(...)
  @already_escaped = false
end

C_CODEPOINTS = [0, 7, 8, 9, 10, 11, 12, 13, 27]
WHITESPACE = [9, 10]

ARGF.set_encoding $INPUT_ENCODING

OUTPUT = String.new(capacity: 4096 * 8, encoding: $OUTPUT_ENCODING)
line = String.new(capacity: 4096, encoding: $INPUT_ENCODING)

while (ARGF.readpartial(4096, line) rescue nil)
  line.each_codepoint do |char|

    # If the character is a special graphic char
    if char == 0x7F or (WHITESPACE.include?(char) ? $ESCAPE_WHITESPACE : char < 0x20)
      if $CSTYLE and C_CODEPOINTS.include?(char)
        if char == 0
          pre '\\0'
        else
          pre ("" << char).inspect[1..-2]
        end
      else
        pre "\\x%02X" % char
      end
    elsif char == '\\'.ord and $ESCAPE_BACKSLASH
      pre '\\\\'
    elsif char > 0x7F and $no_unicode

      pre (char <= 0xff ? "\\x%02X" : "\\u{%X}") % char
    else
      pr "" << char
    end
  end

  print OUTPUT
  ended_with_newline = OUTPUT.end_with? "\n"
  OUTPUT.clear
end

pr ''
print OUTPUT
puts if $TRAILING_NEWLINE and !ended_with_newline

