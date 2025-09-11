require 'optparse'
class SOpt < OptParse
  attr_reader :positional

  def initialize(...)
    @positional = []
    super
  end

  def req(name, into: name) = @positional << [name, :req, into]
  def opt(name, into: name) = @positional << [name, :opt, into]

    alias optional opt
    alias required req
  def remainder(name) @remainder = name end
  alias rem remainder

  alias flag on
  alias usage on_tail

  module AssignToGlobals
    def self.validate_and_transform(key)
      fail "bad key: #{key}" unless key.match? /\A[\w_-]+\z/
      key.gsub('-', '_')
    end

    def self.[]=(key, value)
      eval "$#{validate_and_transform(key.to_s)} = value"
    end

    def self.alias(new, old)
      eval "alias $#{validate_and_transform(new.to_s)} $#{validate_and_transform(old.to_s)}"
    end
  end
end

def opts(program_name=nil, opts: $*, &block)
  SOpt.new.instance_exec do
    self.program_name = program_name if program_name
    instance_exec(&block)

    banner.sub! /\AU/, 'u' # for `Usage` -> `usage`
    @positional.each do |name, what,|
      banner.concat ' '
      if what == :req
        banner.concat "#{name}"
      else
        banner.concat "[#{name}]"
      end
    end

    banner.concat "[...]" if @remainder

    parse! opts, into: SOpt::AssignToGlobals

    @positional.each_with_index do |(name, what, into), index|
      value = $*.shift or
        if what == :req
          raise OptionParser::ParseError, "missing required option #{name}"
        else
          next
        end

      SOpt::AssignToGlobals[into] = value
      SOpt::AssignToGlobals.alias(index + 1, into)
    end

    if @remainder
      SOpt::AssignToGlobals[@remainder] = $*
    elsif !$*.empty?
      raise OptionParser::ParseError, "too many arguments (#{$*.length} extra)"
    end
  rescue OptionParser::ParseError
    abort
  end
end
