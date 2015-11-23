#!/bin/sh

if [ -z "$HOME" ]; then
	echo '$HOME is empty, aborting'
	exit 1
fi

root=$(dirname $(readlink -f "$0"))
configs=$root/configs
scripts=$root/scripts
vendor=$root/vendor

install() {
	if command -v $1 >/dev/null 2>&1; then
		echo -n "$1... "
		"install_$(echo $1 | tr -s '-' '_')"
		echo "done"
	fi
}

install_bash() {
	ln -sf $configs/bash/bashrc $HOME/.bashrc
	ln -sf $configs/bash/aliases $HOME/.bash_aliases
	ln -sf $configs/bash/ps1 $HOME/.bash_ps1
}

install_compton() {
	ln -sf $configs/compton.conf $HOME/.config/compton.conf
}

install_dunst() {
	ln -sfT $configs/dunst $HOME/.config/dunst
}

install_git() {
	ln -sf $configs/git/config $HOME/.gitconfig
	ln -sf $configs/git/ignore_global $HOME/.gitignore_global
}

install_i3() {
	[ -d $HOME/.config/i3 ] || mkdir $HOME/.config/i3
	ln -sf $configs/i3/i3.conf $HOME/.config/i3/config
}

install_i3blocks() {
	[ -d $vendor/i3blocks ] || git clone https://github.com/vivien/i3blocks $vendor/i3blocks
	[ -d $HOME/.config/i3blocks ] || mkdir $HOME/.config/i3blocks
	ln -sf $configs/i3/i3blocks.conf $HOME/.config/i3blocks/config
	ln -sfT $vendor/i3blocks/scripts $HOME/.config/i3blocks/scripts
}

install_i3status() {
	[ -d $HOME/.config/i3status ] || mkdir $HOME/.config/i3status
	ln -sf $configs/i3/i3status.conf $HOME/.config/i3status/config
}

install_irssi() {
	[ -d $HOME/.irssi ] || mkdir -p $HOME/.irssi
	ln -sf $configs/irssi/default.theme $HOME/.irssi/default.theme
}

install_moc() {
	[ -d $HOME/.moc ] || mkdir -p $HOME/.moc
	ln -sfT $configs/moc/config $HOME/.moc/config
}

install_mutt() {
	ln -sfT $configs/muttrc $HOME/.muttrc
}

install_nano() {
	ln -sf $configs/nanorc $HOME/.nanorc
}

install_rtorrent() {
	ln -sf $configs/rtorrent.rc $HOME/.rtorrent.rc
}

install_subl() {
	ln -sfT $configs/sublime-text $HOME/.config/sublime-text-3/Packages/User
	ln -sf $scripts/sublp $HOME/bin/sublp
}

install_tmux() {
	ln -sf $configs/tmux.conf $HOME/.tmux.conf
}

install_urxvt() {
	if [ ! -d $vendor/urxvt-perls ]; then
		git clone https://github.com/muennich/urxvt-perls $vendor/urxvt-perls
	fi
	if [ ! -d $vendor/urxvt-font-size ]; then
		git clone https://github.com/majutsushi/urxvt-font-size $vendor/urxvt-font-size
	fi

	[ -d $HOME/.urxvt/ext ] || mkdir -p $HOME/.urxvt/ext
	ln -sf "$vendor/urxvt-perls/url-select" $HOME/.urxvt/ext/url-select
	ln -sf "$vendor/urxvt-perls/clipboard" $HOME/.urxvt/ext/clipboard
	ln -sf "$vendor/urxvt-perls/keyboard-select" $HOME/.urxvt/ext/keyboard-select
	ln -sf "$vendor/urxvt-font-size/font-size" $HOME/.urxvt/ext/font-size
}

vim_common() {
	# make sure this function is only called once
	[ $vim_common_installed ] && return;
	vim_common_installed=1

	if [ ! -d $vendor/jellybeans.vim ]; then
		git clone https://github.com/nanotech/jellybeans.vim $vendor/jellybeans.vim
	fi
	ln -sf ../../../vendor/jellybeans.vim/colors/jellybeans.vim $configs/vim/colors/jellybeans.vim

	if command -v salt >/dev/null 2>&1; then
		echo -n "salt-vim... "
		if [ ! -d $vendor/salt-vim ]; then
			git clone https://github.com/saltstack/salt-vim $vendor/salt-vim
		fi
		ln -sf ../../../vendor/salt-vim/ftdetect/sls.vim $configs/vim/ftdetect/sls.vim
		ln -sf ../../../vendor/salt-vim/ftplugin/sls.vim $configs/vim/ftplugin/sls.vim
		ln -sf ../../../vendor/salt-vim/syntax/sls.vim $configs/vim/syntax/sls.vim
	fi
}

install_vim() {
	vim_common

	ln -sfT $configs/vimrc $HOME/.vimrc

	[ -d $HOME/.vim ] || mkdir $HOME/.vim
	for file in $configs/vim/*; do
		ln -sfT $file $HOME/.vim/$(basename $file)
	done
}

install_nvim() {
	vim_common

	[ -d $HOME/.config/nvim ] || mkdir $HOME/.config/nvim
	ln -sfT $configs/vimrc $HOME/.config/nvim/init.vim
	for file in $configs/vim/*; do
		ln -sfT $file $HOME/.config/nvim/$(basename $file)
	done
}

install_Xorg() {
	ln -sf $configs/x11/xsessionrc $HOME/.xsessionrc
	ln -sf $configs/x11/xresources $HOME/.Xresources
	if [ ! -f $configs/x11/xresources.local ]; then
		cp $configs/x11/xresources.local.default $configs/x11/xresources.local
	fi
	ln -sf $configs/x11/xresources.local $HOME/.Xresources.local

	[ -d $HOME/.config/fontconfig ] || mkdir -p $HOME/.config/fontconfig
	ln -sf $configs/fontconfig/fonts.conf $HOME/.config/fontconfig/fonts.conf
	if [ ! -f $configs/fontconfig/local.conf ]; then
		cp $configs/fontconfig/local.conf.default $configs/fontconfig/local.conf
	fi
	ln -sf $configs/fontconfig/local.conf $HOME/.config/fontconfig/local.conf
	rm -f $HOME/.fonts.conf

	if command -v gtk-launch >/dev/null 2>&1; then
		echo -n "GTK themes... "
		ln -sf $configs/gtkrc-2.0 $HOME/.gtkrc-2.0

		if [ ! -d $vendor/paper-gtk-theme ]; then
			git clone https://github.com/snwh/paper-gtk-theme $vendor/paper-gtk-theme
		fi
		ln -sfT $vendor/paper-gtk-theme/Paper $HOME/.themes/Paper

		if [ ! -d $vendor/zuki-themes ]; then
			git clone https://github.com/lassekongo83/zuki-themes $vendor/zuki-themes
		fi
		ln -sfT $vendor/zuki-themes/Zukiwi $HOME/.themes/Zukiwi
		ln -sfT $vendor/zuki-themes/Zukitwo $HOME/.themes/Zukitwo
		ln -sfT $vendor/zuki-themes/Zukitre $HOME/.themes/Zukitre
	fi
}


install bash
install compton
install dunst
install git
install i3
install i3blocks
install i3status
install irssi
install moc
install mutt
install nano
install rtorrent
install subl
install tmux
install urxvt
install vim
install nvim
install Xorg


echo -n "~/bin files... "
[ -d $HOME/bin ] || mkdir $HOME/bin
if [ -d /etc/apache2 ]; then
	ln -sf $scripts/a2es $HOME/bin/a2es
fi
ln -sf $scripts/art $HOME/bin/art
ln -sf $scripts/genpw $HOME/bin/genpw
ln -sf $scripts/templ $HOME/bin/templ
echo "done"
