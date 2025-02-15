#!/usr/bin/env ruby
# frozen_string_literal: true

idx = 0
$*.each do |argument|
  printf "%5d: %s\n", (idx += 1), argument.inspect
end
