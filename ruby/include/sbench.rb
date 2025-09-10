require 'benchmark'

=begin EXAMPLE
def toplevel(string) string end
class String def withself; self end end

benchmark 5_000_000 do
  bench 'toplevel' do toplevel "A" end
  bench 'withself' do "A".withself end
end

=end

def benchmark(iterations = 10_000, &block)
  raise ArgumentError, 'called without a block', caller(1) unless block_given?

  Benchmark.bmbm do |results|
    obj = Object.new

    obj.define_singleton_method(:bench) do |name, &benchblock|
      raise ArgumentError, 'called without a block', caller(1) unless block_given?

      results.report(name) do
        iterations.times(&benchblock)
      end
    end

    obj.instance_exec(&block)
  end
end
