# Defines a bunch of nice conversions methods top-level for basic-objects
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

    private def to_helper(to_method, value, methods: [], hash: false, &block)
      BlankSlate.blank {
        define_method(to_method) { value }
        __with_Kernel_method__(*methods)
        if hash
          define_method(:hash) { value.__send__(:hash) }
          define_method(:eql?) { |x| value.__send__(:eql?, x) }
        end
        class_exec(&block) if block
      }
    end

    def i(...)    = to_helper(:to_i, ...)
    def int(...)  = to_helper(:to_int, ...)
    def s(...)    = to_helper(:to_s, ...)
    def str(...)  = to_helper(:to_str, ...)

    # Supports `a(1, 2, 3)` as a convenient shorthand for `a([1, 2, 3])`. However,
    # to
    def a(*ary, **kw, &b)
      if ary.length == 1
        to_helper(:to_a, Array(ary[0]), **kw, &b)
      else
        to_helper(:to_a, ary, **kw, &b)
      end
    end
    def ary(*ary, **kw, &b)
      if ary.length == 1
        to_helper(:to_ary, Array(ary[0]), **kw, &b)
      else
        to_helper(:to_ary, ary, **kw, &b)
      end
    end

    # Supports `h('a' => 'b')` as a convenient shorthand for `h({'a' => 'b'})`,
    # but the shorthand version doesn't allow you to set methods.
    def h(hash = nil, **kw, &b)
      if hash
        to_helper(:to_h, hash, **kw, &b)
      else
        to_helper(:to_h, kw, &b)
      end
    end

    def hash(hash = nil, **kw, &b)
      if hash
        to_helper(:to_hash, hash, **kw, &b)
      else
        to_helper(:to_hash, kw, &b)
      end
    end

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
