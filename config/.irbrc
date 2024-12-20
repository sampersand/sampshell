begin
  require 'bitint'
rescue LoadError
  warn "Can't load bitint"
else
  IRB::TOPLEVEL_BINDING.eval 'BEGIN{ using BitInt::Refinements }'
end

IRB.load_modules.concat %w[csv json set]

class Object
  def ims(all=false) = self.class.instance_methods(all)
  alias instance_methods ims
  def sl(method) = method(method).source_location
end

def subl(*files) = system('subl', '--no-create', '--', *files)
def ssubl(*files) = system('subl', '--create', '--', *files)
