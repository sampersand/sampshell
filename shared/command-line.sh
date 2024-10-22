if type clear >/dev/null 2>&1; then
	cls () {
		clear && printf '\ec\e[3J'
	}
else
	cls () {
		printf '\ec\e[3J'
	}
fi

