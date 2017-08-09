#!/bin/bash

locate_venv() {
	dir="${1:-$PWD}"
	name="$2"
	if [ -d $dir/.tox ]; then
		if [ -n "$name" ]; then
			if [ ! -d "$dir/.tox/$name" ]; then
				echo "No tox environment $name found!"
				return
			fi
			venv=$dir/.tox/$name
		else
			venv=$(find $dir/.tox -mindepth 1 -maxdepth 1 -name 'py*' | sort | tail -1)
		fi
		venv_name="$(basename $dir)/$(basename $venv)"
	elif [ -f $dir/.virtualenv/bin/activate ]; then
		venv=$dir/.virtualenv
		venv_name=$(basename $dir)
	elif [ -f $dir/.venv/bin/activate ]; then
		venv=$dir/.venv
		venv_name=$(basename $dir)
	elif [ -f $dir/bin/activate ]; then
		venv=$dir
		venv_name=$(basename $dir)
	else
		hash=$(echo -n $dir | sha256sum | cut -d' ' -f1 | cut -c 1-8)
		venv_id="dir-$(basename $dir)-$hash"
		venv="$HOME/.local/venvs/$venv_id"
		if [ -f $venv/bin/activate ]; then
			venv_name=$(basename $dir)
		fi
	fi
	if [ -n "$venv_name" ]; then
		echo "$venv $venv_name"
	else
		return 1
	fi
}

make_venv() {
	dir="${1:=PWD}"
	hash=$(echo -n $dir | sha256sum | cut -d' ' -f1 | cut -c 1-8)
	venv_id="dir-$(basename $dir)-$hash"
	venv="$HOME/.local/venvs/$venv_id"
	if [ "$ASK" = 1 ]; then
		read -p "Create virtualenv in '$venv' using $(python3 --version)? [Y/n] "
		if [ -n "$REPLY" ] && ! [[ "$REPLY" =~ ^[Yy] ]]; then
			return 0
		fi
	fi
	echo "Creating virtualenv in $venv ..."
	if [ -n "$PY2" ]; then
		virtualenv -p python2 $venv
	else
		python3 -m venv $venv
	fi
}

cmd="$1" && shift
case "$cmd" in
	locate )
		locate_venv "$@"
		;;
	create )
		make_venv "$@"
		;;
	* )
		echo "unknown command: $cmd"
		exit 1
		;;
esac
exit $?
