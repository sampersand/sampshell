# frozen_string_literal: true
require 'optparse'

=begin
These are the things that are annoying in optparse I want fixed:
- no hidden methods
- no default values
- no positional argument parsing
- no environment variable support really
=end

class OptParse2 < OptParse
  # Provide support for passing keyword arguments into `make_switch`
  def define(*opts, **, &block) top.append(*(sw = make_switch(opts, block, **))); sw[0] end
  alias def_option define
  def on(...) define(...); self end

  def define_head(*opts, **, &block) top.prepend(*(sw = make_switch(opts, block, **))); sw[0] end
  alias def_head_option define_head
  def on_head(...) define_head(...); self end

  def define_head(*opts, **, &block) base.append(*(sw = make_switch(opts, block, **))); sw[0] end
  alias def_tail_option define_tail
  def on_tail(...) define_tail(...); self end

  def initialize(*)
    @defaults = {}
    super
  end

  class ::OptParse::Switch
    def default(description=nil, &block)
      if block
        @default = block
        @default_description = description
        self
      elsif description
        fail ArgumentError, 'description given and no block given'
      else
        @default.call(switch_name)
      end
    end
  end

  # Update `make_switch` to support OptParse2's keyword arguments
  def make_switch(opts, block, hidden: false, key: nil, default: nodefault=true, default_description: nil)
    sw, *rest = super(opts, block)

    key and sw.define_singleton_method(:switch_name) { key }
    hidden and def sw.summarize(*) end

    unless nodefault
      unless default.respond_to? :call
        default1=default
        default = proc{ default1 }
      end

      @defaults[sw.switch_name] = default

      sw.define_singleton_method(:default) { default.(switch_name) }
      sw.define_singleton_method(:default_description){ default_description || self.default.inspect }
      sw.define_singleton_method(:desc) {
        x = super()
        x << '' if x.empty?
        x.last << " [default: #{self.default_description}]"
        x
      }
    end

    [sw, *rest]
  end

  def order!(argv = default_argv, into: nil, **keywords, &nonopt)
    if into.nil? && !@defaults.empty?
      raise "cannot call `order!` without an `into:` if there are default values"
    end

    already_done = {}
    already_done.define_singleton_method(:[]=) do |key, value|
      key = key.to_s
      super(key, value)
      into[key] = value
    end

    result = super(argv, into: already_done, **keywords, &nonopt)

    @defaults.each do |key, value|
      next if already_done.key? key
      into[key] = value.()
    end

    result
  end


  def parse_in_order(*)
    super
  end

  # Provide a "summary" field, which just puts the message at the end of the usage
  def summary(msg)
    on_tail("\n" + msg)
  end

  module Globals
    def self.[]=(key, value)
      key = key.to_s.gsub('-', '_')

      raise "invalid global name: #{key}" unless key.match? /\A[[:alpha:]_][[:alnum:]_]*\z/

      eval "$#{key} = value"
    end
  end

  # def env(name, value)
end
__END__
OptParse2.new nil, 20 do |op|
  # op.program_name = PROGRAM_NAME
  # op.banner = "usage: #{op.program_name} [options] [file] [start[-end]]"

  op.summary <<~USAGE
    Print the link to a repository, a file in the repo, or a range within it.
  USAGE

  op.on '-r', '--repo=REPO', 'Use REPO; if not specified, uses REPO containing FILE. If no FILE, uses PWD.' do |repo|
    $repo = repo
  end

  op.on '-b', '--branch=NAME', 'Explicitly use branch NAME', key: :branch
  op.on '-c', '--current', 'Use the current branch',         key: :branch do :current end
  op.on '-m', '--master', 'Use the master branch [default]', key: :branch do :master end
  op.on '-p', '--permalink', 'Use a permalink',              key: :branch do :permalink end
  op.on '--debug', hidden: true do $DEBUG = 1 end

  begin
    op.parse!
  rescue OptionParser::InvalidOption => err
    abort err
  end

  unless $*.length <= 2
    abort op.help
  end
end.parse! %w[--debug -hm -- -bq -c -m], into: q={}
p q
