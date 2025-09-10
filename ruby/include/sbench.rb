require 'benchmark'

=begin EXAMPLE
def toplevel(string) string end
class String def withself; self end end

sbench 5_000_000 do
  bench 'toplevel' do toplevel "A" end
  bench 'withself' do "A".withself end
end

=end

def sbench(iterations = 10_000, &block)
  raise ArgumentError, 'called without a block', caller(1) unless block_given?

  Benchmark.bmbm do |results|
    obj = Object.new

    obj.define_singleton_method(:bench) do |name=nil, &benchblock|
      raise ArgumentError, 'called without a block', caller(1) unless block_given?

      # Allow users to omit the name, at which point the location is used. If the location is not
      # possible (maybe it's some C-level function), then just use the block's string
      name ||= benchblock.source_location&.then{"#{File.basename(_1)}:#{_2}"} || benchblock.to_s

      results.report(name) do
        iterations.times(&benchblock)
      end
    end

    obj.instance_exec(&block)
  end
end
