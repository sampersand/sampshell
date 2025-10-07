# Defines a bunch of nice conversions methods top-level for basic-objects
module ToI
  def to_i = @value
end

class BlankSlate < BasicObject
  # Undo everything but `__send__` and `__id__`
  instance_methods.each do |im|
    undef_method(im) unless im == :__send__ or im == :__id__
  end

  def __with_Kernel_method__(*methods)
    dsm = ::Kernel.instance_method(:define_singleton_method).bind(self)

    methods.each do |method|
      dsm.call(method, ::Kernel.instance_method(method))
    end

    self
  end

  def self.__with_Kernel_method__(*methods)
    if ::BlankSlate.equal?(self)
      raise ArgumentError, 'Cannot call `__with_Kernel_method__` on BlankSlate, as that will affect all blank slates'
    end

    methods.each do |method|
      define_method(method, ::Kernel.instance_method(method))
    end

    self
  end

  def self.blank(&block)
    ::Class.new(self, &block).new
  end

  module To
    module_function

    private def to_helper(to_method, value, *kernel_methods, &block)
      BlankSlate.blank {
        define_method(to_method) { value }
        __with_Kernel_method__(*kernel_methods)
        class_exec(&block) if block
      }
    end

    def i(...)    = to_helper(:to_i, ...)
    def int(...)  = to_helper(:to_int, ...)
    def s(...)    = to_helper(:to_s, ...)
    def str(...)  = to_helper(:to_str, ...)
    def a(...)    = to_helper(:to_a, ...)
    def ary(...)  = to_helper(:to_ary, ...)
    def h(...)    = to_helper(:to_h, ...)
    def hash(...) = to_helper(:to_hash, ...)

    def sym(...)  = to_helper(:to_sym, ...)
    def r(...)    = to_helper(:to_r, ...)
    def c(...)    = to_helper(:to_c, ...)
    def f(...)    = to_helper(:to_f, ...)
    def path(...) = to_helper(:to_path, ...)
    def io(...)   = to_helper(:to_io, ...)

    def range(begin_, end_, exclude_end = false)
      BlankSlate.blank {
        define_method(:begin){ begin_ }
        define_method(:end){ end_ }
        define_method(:exclude_end?){ exclude_end? }
      }
    end
  end
end
