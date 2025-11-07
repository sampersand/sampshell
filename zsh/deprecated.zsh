function __deprecated () {
	print -P "\n%F{red}\tfunction ${(qq)1} is deprecated! don't use it!%f\n" >&2
	"$@"
}
