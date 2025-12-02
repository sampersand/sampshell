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

  # Update `make_switch` to support OptParse2's keyword arguments
  def make_switch(opts, block, hidden: false, key: nil)
    sw, *rest = super(opts, block)

    key and sw.define_singleton_method(:switch_name) { key }
    hidden and def sw.summarize(*) end

    [sw, *rest]
  end

  # Provide a "summary" field, which just puts the message at the end of the usage
  def summary(msg)
    on_tail("\n" + msg)
  end

  # def env(var, *opts, hidden: false, &)
  #   fail if hidden
  #   sw, = make_switch(['-_X', *opts])

  #   p sw
  #   exit
  #   on_tail(var)
  # end

  # def positional
end

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
