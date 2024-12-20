if RUBY_VERSION < '3.3'
  # TODO: is this necessary? it was originally for cause `;` wasnt recognized at end of line
  IRB.conf[:ECHO_ON_ASSIGNMENT] = false
end
IRB.load_modules.concat %w[csv json set]

def subl(*files) = system('subl', '--no-create', '--', *files)
def ssubl(*files) = system('subl', '--create', '--', *files)

begin
  require 'bitint'
rescue LoadError
  warn "Can't load bitint"
else
  IRB::TOPLEVEL_BINDING.eval 'BEGIN{ using BitInt::Refinements }'
end

class Object
  def ms = methods(false)
  def ims = instance_methods(false)
  alias m method

  def ims(all=false) = self.class.instance_methods(all)
  alias instance_methods ims
  def sl(method) = method(method).source_location
end


IRB.conf[:PROMPT_MODE] = :TOPLEVEL
IRB.conf[:PROMPT][:TOPLEVEL] = {

}
