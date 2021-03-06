#!/bin/sh

# this was initially in ~/.ssh/rc but can't check for interactivity there.
# create a symlink for the SSH agent socket so that we can use the symlink path
# in tmux to avoid having to constantly update environment variables when re-
# attaching sessions. only do this in interactive sessions, because some
# additional logic to ensure that this works is in ~/.bash_logout, which is not
# invoked when using non-interactive sessions. it's safe to assume that if you
# start a non-interactive session you're not interested in using tmux anyway.
if [ -n "${SSH_AUTH_SOCK-}" ] && [ ! -L "$SSH_AUTH_SOCK" ]; then
	ln -sf $SSH_AUTH_SOCK $HOME/.ssh/ssh_auth_sock
fi
