## My "IRB" config I always want loaded.

if RUBY_VERSION < '3.3'
  # TODO: is this necessary? it was originally for cause `;` wasnt recognized at end of line
  IRB.conf[:ECHO_ON_ASSIGNMENT] = false
end

####################################################################################################
#                                                                                                  #
#                                             Includes                                             #
#                                                                                                  #
####################################################################################################

## Modules I want to always beloaded.
IRB.load_modules.concat %w[csv json set]

## Always load in `bitint` if possible, and then `use` its refinements.
# This isn't a part of `IRB.loaded_modules` because I want to have the `using BitInt::Refinements`,
# and this `using` is a per-file basis, so we need to run it based on the `IRB::TOPLEVEL_BINDING`.
# But, since we only want to run that if `bitint` was loaded, we do it here.
begin
  require 'bitint'
rescue LoadError
  warn "Can't load bitint for Ruby #{RUBY_VERSION}"
else
  # Since `using` is file-specific, we need to `eval` it to get it to work in the top-level.
  IRB::TOPLEVEL_BINDING.eval 'using BitInt::Refinements'
end

####################################################################################################
#                                                                                                  #
#                                           Sublime Text                                           #
#                                                                                                  #
####################################################################################################

## Always have `subl` and `ssubl` visible
public def subl(*files)  system('subl', '--no-create', '--', *files) end
public def ssubl(*files) system('subl',    '--create', '--', *files) end
public def pbc(input = noinput = true)
  if noinput
    if equal?(IRB::TOPLEVEL_BINDING)
      input = IRB.CurrentContext.last_value
    else
      input = to_s
    end
  end

  IO.pipe do |r, w|
    w.puts input.to_s
    w.close
    system('pbcopy', in: r)
  end
end

## Open up the method in sublime text. (Note the `sublm` won't )
class Method; def subl; TOPLEVEL_BINDING.subl(source_location.join(':')) end end
class Object
  def sublm(m)
    method(m).subl # TODO: DOESN'T WORK W/ REFINEMENTS
  end
end

####################################################################################################
#                                                                                                  #
#                                               Misc                                               #
#                                                                                                  #
####################################################################################################

class Object
  def ms = methods(false)
  def ims = instance_methods(false)
  alias m method

  def ims(all=false) = self.class.instance_methods(all)
  alias instance_methods ims
  def sl(method) = method(method).source_location
end

class Integer
  def hex = to_s(16)
  def bin = to_s(2)
  def oct = to_s(8)
end

class String
  def bin = to_i(2)
end

PRCHARS = (' '..'~')

# IRB.conf[:PROMPT_MODE] = :TOPLEVEL
# IRB.conf[:PROMPT][:TOPLEVEL] = {

# }
alias echo puts
