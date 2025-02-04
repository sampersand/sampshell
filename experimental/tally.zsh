#!/bin/zsh
[[ $1 = -r ]] && { reverse=1; shift; }

# exec <<<$'a\nb\nc\nb\nd\nc\nb\na'

typeset -A ary
while IFS= read -r; do
  ary[$REPLY]+=1
done
# print -aC2 ${(kv)ary}
typeset -A counts

for k v in ${(kv)ary}; do
  echo $v
  counts[$#v]="X $counts[$#v]$'\n'($k)"
done
print -aC2 ${(v)counts}
exit
for x in ${(kO)counts}; for q in ${(f)counts[$x]}; printf "%3d: %s\n" $x $q
# for ele in ${(kO)ary}; print -- $ele: $ary[$ele]
# print -- ${(Ovk)ary}
# for ele in ${(Ovk)ary}; do
  # echo ${ary[ele]}

exit

exec ruby -sx -- "$0" "$@"
#!ruby -n

BEGIN {
  $h and abort "usage: #$0 [-r]\n-r is used to reverse the output"
  lines = Hash.new 0
}

lines[chomp] += 1

END {
  lines = lines.sort_by(&:last)
  num_digits = lines.last.last.digits.count
  lines.reverse! if $r
  lines.each do |line, count|
    printf "%#{num_digits}d\t%s\n", count, line
  end
}
