### Git Control
# This file is for ZSH config relating to git
###

# The only git config we have is to add in a bunch of global aliases, which are
# used to reference older branches without having to type out the braces.
for i in {1..10}; do
	alias -g "@-$i=@{-$i}"
done
