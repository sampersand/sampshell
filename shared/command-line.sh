if type clear >/dev/null 2>&1; then
	cls () {
		clear && printf %s $'\ec\e[3J'
	}
else
	cls () {
		printf %s $'\ec\e[3J'
	}
fi

