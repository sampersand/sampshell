# frozen_string_literal: true

require 'optparse'
OptParse.new do |op|
  x = op.define('-q', '--foo')
  binding.irb
end
__END__
class OptParse2 < OptParse
end

OptParse2.new do |op|
  op.on '-f', '--foo', 'do foo'
  op.required_arg 'file', 'file name'
