whoami=$(whoami)

if [ $whoami = 'vagrant' ]; then
    color='34' # blue
elif [ -n "$SSH_CLIENT" ]; then
	if [ $whoami = 'root' ]; then
	    color='31' # red
	else
	    color='33' # yellow
	fi
else
    color='32' # green
fi

PS1='${debian_chroot:+($debian_chroot)}\[\033[01;'$color'm\]\u@\h\[\033[00m\] \w'

if command -v __git_ps1 >/dev/null 2>&1; then
	# GIT_PS1_SHOWDIRTYSTATE=true
	# GIT_PS1_SHOWUNTRACKEDFILES=true
	GIT_PS1_SHOWUPSTREAM="auto"
	# GIT_PS1_SHOWCOLORHINTS=true
    PS1=$PS1'$(__git_ps1 " (%s)")'
fi

if [ $whoami = 'root' ]; then
    PS1=$PS1'\n# '
else
    PS1=$PS1'\n$ '
fi
