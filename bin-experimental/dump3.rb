#!/usr/bin/env ruby
# frozen_string_literal: true
require 'optparse'

OptParse.new do |op|
  op.on '-N', '--no-newline', 'Suppress final newline' do $no_newline = true end
  op.on '-F', '--files', 'Interpret parameters as filenames, not strings' do $files = true end
  op.parse! rescue abort "#{op.program_name}: #$!"
end

BLOCK_SIZE = 4096 * 4
OUTPUT_BUFFER = String.new(capacity: BLOCK_SIZE * 8)

def dump(line)
  OUTPUT_BUFFER.clear

  line = line.inspect
  line.slice! 0

  while backslash = line.index('\\')
    OUTPUT_BUFFER.concat line.slice!(0, backslash)
    case line[1]
    when '\\' then OUTPUT_BUFFER.concat '\\'; line.slice! 0, 2; next
    OUTPUT_BUFFER.concat("\e[7m",
      case (pre = line.slice! 0, 2)
      when '\\' then OUTPUT_BUFFER.concat '\\'; next
      when 'x' then
          when 'x' then
    # TODO: `\u`, `\x`,
     "\e[7m", line.slice!(0, 2), "\e[27m"
  end

  # each_grapheme_cluster do |char|
  #   q = char.inspect[1..-2]
  #   if q == char
  #     OUTPUT_BUFFER.concat char
  #   else
  #     OUTPUT_BUFFER.concat "\e[7m", q, "\e[27m"
  #   end
  # end

  OUTPUT_BUFFER
end

if !$*.empty? && !$files then
  $*.each_with_index do |arg, index|
    printf "%5d: %s\n", (index + 1), dump(arg)
  end
  exit
end

LINE = String.new(capacity: BLOCK_SIZE)

loop do
  $stdout.syswrite dump ARGF.readpartial(BLOCK_SIZE, LINE)
rescue EOFError
  puts unless $no_newline
  exit
end
