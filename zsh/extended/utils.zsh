# utility functions and what have you that I've accumulated over the years
chr () ruby -- /dev/fd/3 $@ 3<<'RUBY'
puts ([]==$*?$stdin.map(&:chomp):$*).map{|w|w.bytes.map{_1.to_s 16}.join(?\s)}
RUBY
# $*.empty? and $*.replace $stdin.map(&:chomp)
# puts $*.map{|w|w.bytes.map{|b|b.to_s 16}.join(?\s)}

ord () ruby -- /dev/fd/3 $@ 3<<'RUBY'
puts ($*.empty? ? $stdin.map{_1.chomp.split} : [$*])
	.map{_1.map(&:hex).pack('C*')}
RUBY


function enable-wifi { networksetup -setairportpower en0 on }
function disable-wifi { networksetup -setairportpower en0 off }
function toggle-wifi { disable-wifi; sleep 2; enable-wifi }
