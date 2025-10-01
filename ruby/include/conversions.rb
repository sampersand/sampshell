# Defines a bunch of nice conversions methods top-level for basic-objects

class BlankSlate < BasicObject
  # Undo everything but `__send__`
  instance_methods.each do |im|
    undef_method(im) unless im == :__send__
  end
end

%i[
  to_i to_int
  to_a to_ary
  to_s to_str
  to_h to_hash

  to_sym
  to_r
  to_c
  to_f
  to_path
].each do |method|
  define_method(method) do |val|
    Class.new(BlankSlate){ define_method(method){ val } }.new
  end
end

class CustomRange < BlankSlate
  attr_reader :begin, :end

  def initialize(begin_, end_, exclude_end = false)
    @begin = begin_
    @end = end_
    @exclude_end = exclude_end
  end

  def exclude_end? = @exclude_end
end

class Each < BlankSlate
  def initialize(*args)
    @args = args
  end

  def each(&block)
    @args.each(&block)
  end
end

def range(...) = CustomRange.new(...)
