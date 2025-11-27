# frozen_string_literal: true

require 'optparse'

class OptParse2 < OptParse
end

OptParse2.new do |op|
  op.on '-f', '--foo', 'do foo'
  op.required_arg 'file', 'file name'
